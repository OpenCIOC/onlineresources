# =========================================================================================
#  Copyright 2024 KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================
from __future__ import annotations

import argparse
from collections import namedtuple, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
import datetime
from io import StringIO, TextIOWrapper
from itertools import zip_longest
from operator import itemgetter
import os
import re
import sys
import tempfile
import threading
import traceback
import urllib.parse

import boto3
import isodate
import requests

import typing as t

if t.TYPE_CHECKING:
    from mypy_boto3_s3.client import S3Client
    import pyodbc

try:
    import cioc  # NOQA

    assert cioc
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from tools.toolslib import (
    ArgsType,
    Context,
    FileWriteDetector,
    get_config_item,
    email_log,
    get_bulk_connection,
)

from cioc.core import constants as const
from cioc.core import syslanguage
from cioc.core.utf8csv import UTF8CSVWriter

CREATE_NO_WINDOW = 0x08000000
creationflags = 0

invalid_xml_chars = re.compile("[\x00-\x08\x0c\x0e-\x19]")

const.update_cache_values()
LangSetting = namedtuple(
    "LangSetting", "culture field_suffix language_name sql_language, api_key"
)

_lang_settings = [
    LangSetting("en-CA", "_en", "en", syslanguage.SQLALIAS_ENGLISH, None),
    LangSetting("fr-CA", "_fr", "fr", syslanguage.SQLALIAS_FRENCH, None),
]

_code_levels = {1: 1, 2: 2, 7: 3, 12: 4, 16: 5, 19: 6}
_code_ranges = [(0, 1), (1, 2), (3, 7), (8, 12), (13, 16), (17, 19)]
_code_fields = ["CdLvl" + str(i) for i in range(1, 7)]

FieldOrder = [
    # "TM_ID",
    "Code",
    "CREATED_DATE",
    # "CREATED_BY",
    "MODIFIED_DATE",
    # "MODIFIED_BY",
    "CdLvl1",
    "CdLvl2",
    "CdLvl3",
    "CdLvl4",
    "CdLvl5",
    "CdLvl6",
    # "CdLocal",
    "ParentCode",
    "CdLvl",
    "Term_en",
    "Term_fr",
    # "Authorized",
    # "Active",
    # "Source",
    "Definition_en",
    "Definition_fr",
    "Facet",
    "Comments_en",
    "Comments_fr",
    # "AltTerm_en",
    # "AltTerm_fr",
    # "AltDefinition_en",
    # "AltDefinition_fr",
    "BiblioRef_en",
    "BiblioRef_fr",
]

all_term_fields = [
    "code",
    "created_at",
    "updated_at",
    "parent",
]

term_field_mapping = {
    "code": "Code",
    "name": "Term%(lang_suffix)s",
    "definition": "Definition%(lang_suffix)s",
    "facet": "Facet",
    "change_comment": "Comments%(lang_suffix)s",
    "bibliographic_references": "BiblioRef%(lang_suffix)s",
    "created_at": "CREATED_DATE",
    "updated_at": "MODIFIED_DATE",
}

threadlocal = threading.local()


class TermParts(t.NamedTuple):
    terms: list[dict[str, t.Any]]
    old_codes: list[tuple[str, str]]
    see_also: list[tuple[str, str]]
    use_references: list[dict[str, str]]
    concepts: dict[str, dict[str, str]]
    concept_map: list[tuple[str, str]]
    to_delete: set[str] = set()


class CancellingThreadPoolExecutor(ThreadPoolExecutor):
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.shutdown(wait=True, cancel_futures=True)
        return False


def get_code_parts(codetxt):
    code_level = _code_levels[len(codetxt)]
    code_sections = [codetxt[start:stop] for (start, stop) in _code_ranges[:code_level]]

    code = {"CdLvl": code_level}
    code.update(zip_longest(_code_fields, code_sections))

    return code


def _to_unicode(value):
    if value is None:
        return ""

    value = str(value)
    return invalid_xml_chars.sub("", value).strip()


def to_csv(records, target_file, headings: t.Sequence[str | int]):
    fn = itemgetter(*headings)

    writer = UTF8CSVWriter(target_file)  # , dialect=SQLServerBulkDialect)
    out_stream = (list(map(_to_unicode, fn(x))) for x in records)
    writer.writerows(out_stream)


class CsvFileWriter:
    def __init__(self, args, headings: t.Sequence[str | int]):
        self.s3_bulk_import_bucket = args.s3_bulk_import_bucket
        self.s3_bulk_import_prefix = args.s3_bulk_import_prefix
        self.s3_client = args.s3_client
        self.headings = headings
        self.fd = tempfile.TemporaryFile(suffix=".csv")
        self.wrapped_fd = TextIOWrapper(self.fd, encoding="utf-16", newline="")
        self.file_name = os.path.basename(self.fd.name)

    def __enter__(self):
        return self

    def __exit__(self, *exc_details):
        if self.file_name:
            try:
                self.s3_client.delete_object(
                    Bucket=self.s3_bulk_import_bucket,
                    Key=self.s3_bulk_import_prefix + self.source_file,
                )
            except Exception:
                pass

    def serialize_records(self, records):
        if not self.wrapped_fd:
            raise Exception("File not opened yet")

        to_csv(records, self.wrapped_fd, self.headings)

    def close(self):
        if not self.fd.closed:
            self.wrapped_fd.flush()
            self.fd.seek(0)
            self.s3_client.upload_fileobj(
                self.fd,
                self.s3_bulk_import_bucket,
                self.source_file,
            )
            self.wrapped_fd.close()
            self.fd.close()

    @property
    def source_file(self):
        return self.s3_bulk_import_prefix + self.file_name


def push_bulk(
    args: TaxonomyArgsType,
    conn: pyodbc.Connection,
    sql: str,
    headings: t.Sequence[str | int],
    batch: t.Iterable | t.Iterator,
):
    with CsvFileWriter(args, headings) as writer:
        writer.serialize_records(batch)
        writer.close()
        cursor = conn.execute(
            sql,
            *(("/" + args.s3_bulk_import_bucket + "/" + writer.source_file,)),
        )

    return cursor


def init_threadpool_thread():
    session = threadlocal.session = requests.Session()
    session.headers.update({"Accept": "application/json"})


@dataclass
class TaxonomyArgsTypeBase(ArgsType):
    skip_import: bool = False
    capture_changes: bool = False
    use_capture: bool = False


def botos3_factory() -> S3Client:
    return boto3.client("s3")


@dataclass
class TaxonomyArgsType(TaxonomyArgsTypeBase):
    session: requests.Session = field(default_factory=requests.Session)
    s3_client: S3Client = field(default_factory=botos3_factory)
    host: str = ""
    s3_bulk_import_bucket: str = ""
    s3_bulk_import_prefix: str = ""
    languages: t.List[LangSetting] = field(default_factory=list)


def fix_datetime(obj, datetime_fields):
    for f in datetime_fields:
        d = obj[f]
        if d and d[-1] == "Z" and d[-8] == ".":
            obj[f] = d[:-4]
    return obj


def fetch_with_get(url, api_key):
    response = threadlocal.session.get(
        url, headers={"Authorization": f"Bearer {api_key}"}
    )
    response.raise_for_status()
    return response.json()


def get_terms_list_with_threadpool(
    args: TaxonomyArgsType, executor: CancellingThreadPoolExecutor
):
    init_threadpool_thread()
    base_url = f"https://{args.host}/api/v1/terms"
    count = len(args.languages)

    waiting = {}
    for lang in args.languages:
        waiting[executor.submit(fetch_with_get, base_url, lang.api_key)] = (
            base_url,
            lang,
        )

    while waiting:
        requests_in_flight = len(waiting)
        print(f"looping queued requests: {requests_in_flight=}, {count=}")
        for f in as_completed(waiting):
            data = f.result()
            fetched_url, lang = waiting.pop(f, (None, None))
            if not lang:
                raise Exception("Unexpected future completion")
            meta = data.get("meta")

            next = None
            if meta:
                page = meta.get("page")
                if page:
                    next = page.get("next")
            if next:
                count += 1
                waiting[executor.submit(fetch_with_get, next, lang.api_key)] = (
                    next,
                    lang,
                )

            terms = data.get("data")
            if terms is None:
                print(fetched_url, data)
                raise Exception("No data returned from terms API")

            for term in terms:
                term["parent"] = (
                    term["parents"][-1]["code"] if term.get("parents") else None
                )
                yield (term, lang)
                if term.get("has_children"):
                    url = (
                        base_url
                        + "?"
                        + urllib.parse.urlencode({"parent": term["code"]})
                    )
                    count += 1
                    waiting[executor.submit(fetch_with_get, url, lang.api_key)] = (
                        url,
                        lang,
                    )

    print(f"Completed fetch all terms {count=}")


def merge_termlist_parts(args: TaxonomyArgsType, parts: dict[str, dict]):
    updated_at = None
    final = {}
    for lang in reversed(args.languages):
        try:
            part = parts[lang.culture]
            updated_at = part["updated_at"] = (
                part["updated_at"]
                if updated_at is None
                else max(updated_at, part["updated_at"])
            )
            final |= part
        except KeyError:
            pass

    return final


def merge_terms_list_languages(
    args: TaxonomyArgsType, terms_iter: t.Iterable[tuple[dict, LangSetting]]
):
    lang_count = len(args.languages)
    terms = defaultdict(dict)
    for term, lang in terms_iter:
        parts = terms[term["code"]]
        parts[lang.culture] = term
        if len(parts) != lang_count:
            continue

        yield merge_termlist_parts(args, parts)
        del terms[term["code"]]

    if terms:
        print("there were terms with only one language. count=", len(terms))

    for code, parts in terms.items():
        print(f"unmatched term {code=}, {parts=}")
        yield merge_termlist_parts(args, parts)


def fetch_and_merge_term_languages(
    args: TaxonomyArgsType, url: str, _use_ref_template, _term_template
) -> TermParts:
    parts = []
    for lang in args.languages:
        api_key = lang.api_key
        response = threadlocal.session.get(
            url, headers={"Authorization": f"Bearer {api_key}"}
        )
        response.raise_for_status()
        parts.append((lang, response.json()))

    term = _term_template.copy()
    use_references = []
    concepts = defaultdict(dict)

    for lang, part in reversed(parts):
        suffix = {"lang_suffix": lang.field_suffix}
        term.update(
            (term_field_mapping[k] % suffix, v)
            for (k, v) in part.items()
            if k != "updated_at" and k in term_field_mapping
        )
        modified = term.get("MODIFIED_DATE")
        term["MODIFIED_DATE"] = (
            part["updated_at"]
            if modified is None
            else max(part["updated_at"], modified)
        )
        use_references.extend(
            _use_ref_template | {"Code": part["code"], f"Term{lang.field_suffix}": x}
            for x in (part["use_references"] or [])
        )
        for concept in part["concepts"]:
            fn = f"ConceptName{lang.field_suffix}"
            concepts[concept["code"]][fn] = concept["name"]

    lang, part = parts[0]
    term["ParentCode"] = part["parents"][-1]["code"] if part["parents"] else None

    code = term["Code"]

    term.update(get_code_parts(code))

    old_codes = [(code, x) for x in part["old_codes"]]
    see_also = [(code, x["code"]) for x in part["see_also_references"]]
    concept_map = [(code, x) for x in concepts]
    return TermParts([term], old_codes, see_also, use_references, concepts, concept_map)


def merge_term_languages(
    args: TaxonomyArgsType,
    code: str,
    parts: dict[str, dict],
    _use_ref_template: dict,
    _term_template: dict,
) -> TermParts:
    term = _term_template.copy()
    use_references = []
    concepts = defaultdict(dict)

    for lang in reversed(args.languages):
        part = parts[lang.culture]
        suffix = {"lang_suffix": lang.field_suffix}
        term.update(
            (term_field_mapping[k] % suffix, v)
            for (k, v) in part.items()
            if k != "updated_at" and k in term_field_mapping
        )
        modified = term.get("MODIFIED_DATE")
        term["MODIFIED_DATE"] = (
            part["updated_at"]
            if modified is None
            else max(part["updated_at"], modified)
        )

        use_references.extend(
            _use_ref_template | {"Code": part["code"], f"Term{lang.field_suffix}": x}
            for x in (part["use_references"] or [])
        )
        for concept in part["concepts"]:
            fn = f"ConceptName{lang.field_suffix}"
            concepts[concept["code"]][fn] = concept["name"]

    part = parts[args.languages[0].culture]
    term["ParentCode"] = part["parents"][-1]["code"] if part["parents"] else None

    code = term["Code"]

    term.update(get_code_parts(code))

    old_codes = [(code, x) for x in part["old_codes"]]
    see_also = [(code, x["code"]) for x in part["see_also_references"]]
    concept_map = [(code, x) for x in concepts]
    return TermParts([term], old_codes, see_also, use_references, concepts, concept_map)


def get_terms_with_threadpool(
    args: TaxonomyArgsType,
    changed_terms: list[pyodbc.Row],
    executor: CancellingThreadPoolExecutor,
) -> TermParts:
    to_delete = set()
    terms = []
    old_codes = []
    see_also = []
    use_reference = []
    concepts = {}
    concept_map = []

    _use_ref_template = {f"Term{l.field_suffix}": None for l in args.languages}
    _term_template = {k: None for k in FieldOrder}

    language_count = len(args.languages)
    pending_terms = defaultdict(dict)

    waiting = {}
    # waiting = set()
    for term in changed_terms:
        if term.ToDelete:
            to_delete.add(term.Code)
            continue

        assert term.Code
        # waiting.add(
        #     executor.submit(
        #         fetch_and_merge_term_languages,
        #         args,
        #         f"https://{args.host}/api/v1/terms/{term.Code}",
        #         _use_ref_template,
        #         _term_template,
        #     )
        # )

        for lang in args.languages:
            waiting[
                executor.submit(
                    fetch_with_get,
                    f"https://{args.host}/api/v1/terms/{term.Code}",
                    lang.api_key,
                )
            ] = (lang, term.Code)
    total = len(waiting)
    print("Requests Queued")
    for completed, f in enumerate(as_completed(waiting)):
        if not completed % 500:
            print(
                f"Processing terms: {total=}, {completed=}, remaining={total-completed}"
            )
        data: dict = f.result()
        lang, code = waiting[f]
        pending_terms[code][lang.culture] = data
        if len(pending_terms[code]) == language_count:
            result = merge_term_languages(
                args, code, pending_terms[code], _use_ref_template, _term_template
            )

            # if True:
            #     result: TermParts = f.result()

            terms.append(result.terms[0])
            old_codes.extend(result.old_codes)
            see_also.extend(result.see_also)
            use_reference.extend(result.use_references)
            concepts.update(result.concepts)
            concept_map.extend(result.concept_map)

    return TermParts(
        terms, old_codes, see_also, use_reference, concepts, concept_map, to_delete
    )


def push_all_terms(
    args: TaxonomyArgsType, conn: pyodbc.Connection, all_terms: list[dict]
) -> list[pyodbc.Row]:
    sql = """
        EXEC sp_TAX_U_Term_AllTerms ?
    """
    cursor = push_bulk(
        args,
        conn,
        sql,
        all_term_fields,
        (
            fix_datetime(x, ["created_at", "updated_at"])
            for x in sorted(all_terms, key=itemgetter("code"))
        ),
    )
    return cursor.fetchall()


def fetch_cultures(
    args: TaxonomyArgsType, code: str, executor: CancellingThreadPoolExecutor
) -> list[str]:
    waiting = set()
    for lang in args.languages:
        waiting.add(
            executor.submit(
                fetch_with_get,
                f"https://{args.host}/api/v1/terms/{code}",
                lang.api_key,
            )
        )
    cultures = []
    for f in as_completed(waiting):
        result = f.result()
        cultures.append(result["locale"])

    return cultures


def fetch_updated_terms_from_211hsis(args, conn) -> tuple[TermParts, list[str]]:
    with CancellingThreadPoolExecutor(initializer=init_threadpool_thread) as executor:
        all_terms = list(
            merge_terms_list_languages(
                args, get_terms_list_with_threadpool(args, executor)
            )
        )
        updated_terms = push_all_terms(args, conn, all_terms)
        print("fetched", len(updated_terms), "updated terms")
        term_parts = get_terms_with_threadpool(args, updated_terms, executor)
        cultures = fetch_cultures(args, all_terms[0]["code"], executor)
    return term_parts, cultures


def prepare_session(args: TaxonomyArgsTypeBase) -> TaxonomyArgsType:
    session = requests.Session()
    session.headers.update({"Accept": "application/json"})

    languages = []
    for language in _lang_settings:
        key = get_config_item(args, f"tax_import_api_key_{language.language_name}", "")
        if not key:
            continue
        languages.append(language._replace(api_key=key))

    return TaxonomyArgsType(
        **{
            "session": session,
            "host": get_config_item(args, "tax_import_api_host", "211hsis.org"),
            "s3_bulk_import_bucket": get_config_item(args, "s3_bulk_import_bucket"),
            "s3_bulk_import_prefix": get_config_item(args, "s3_bulk_import_prefix"),
            "s3_client": boto3.client("s3"),
            "languages": languages,
            **vars(args),
        }
    )


def parse_args(argv) -> TaxonomyArgsTypeBase:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config", dest="configfile", action="store", default=const._config_file
    )
    parser.add_argument(
        "--test", dest="test", action="store_const", const=True, default=False
    )
    parser.add_argument(
        "--email", dest="email", action="store_const", const=True, default=False
    )
    parser.add_argument(
        "--config-prefix", dest="config_prefix", action="store", default=""
    )
    parser.add_argument(
        "--skip-import", dest="skip_import", action="store_true", default=False
    )
    parser.add_argument(
        "--capture-changes", dest="capture_changes", action="store_true", default=False
    )
    parser.add_argument(
        "--use-capture", dest="use_capture", action="store_true", default=False
    )

    args = parser.parse_args(argv)
    if args.config_prefix and not args.config_prefix.endswith("."):
        args.config_prefix += "."

    return TaxonomyArgsTypeBase(**vars(args))


def delete_terms(args: TaxonomyArgsType, conn: pyodbc.Connection, terms: set[str]):
    sql = "EXEC sp_TAX_U_Term_d ?"
    push_bulk(args, conn, sql, [0, 1], ((x, None) for x in sorted(terms)))


def import_terms(args: TaxonomyArgsType, conn: pyodbc.Connection, terms: list[dict]):
    sql = "EXEC sp_TAX_U_Term_iu ?"
    push_bulk(
        args,
        conn,
        sql,
        FieldOrder,
        (
            fix_datetime(x, ["CREATED_DATE", "MODIFIED_DATE"])
            for x in sorted(terms, key=itemgetter("Code"))
        ),
    )


def import_old_codes(
    args: TaxonomyArgsType, conn: pyodbc.Connection, old_codes: list[tuple[str, str]]
):
    sql = "EXEC sp_TAX_U_oldCode_id ?"
    push_bulk(args, conn, sql, list(range(2)), old_codes)


def import_see_also(
    args: TaxonomyArgsType, conn: pyodbc.Connection, see_also: list[tuple[str, str]]
):
    sql = "EXEC sp_TAX_U_SeeAlso_id ?"
    push_bulk(args, conn, sql, list(range(2)), see_also)


def import_use_references(
    args: TaxonomyArgsType,
    conn: pyodbc.Connection,
    use_references: list[dict[str, str]],
):
    sql = "EXEC sp_TAX_U_Unused_id ?"
    push_bulk(
        args,
        conn,
        sql,
        ["Code"] + [f"Term{l.field_suffix}" for l in args.languages],
        use_references,
    )


def import_concepts(
    args: TaxonomyArgsType, conn: pyodbc.Connection, concepts: dict[str, dict[str, str]]
):
    sql = "EXEC sp_TAX_U_RelatedConcept_iu ?"
    headings = ["Code"] + [f"ConceptName{l.field_suffix}" for l in args.languages]
    tmpl = {x: None for x in headings}
    push_bulk(
        args,
        conn,
        sql,
        headings,
        ({**tmpl, "Code": k, **v} for k, v in sorted(concepts.items())),
    )


def import_concept_map(
    args: TaxonomyArgsType, conn: pyodbc.Connection, concept_map: list[tuple[str, str]]
):
    sql = "EXEC sp_TAX_U_TM_RC_iud ?"
    push_bulk(args, conn, sql, list(range(2)), concept_map)


def capture_changes(updated: TermParts, cultures: list[str]):
    import pickle

    with open(__file__.replace(".py", ".capture"), "wb") as fd:
        pickle.dump((updated, cultures), fd)


def load_changes() -> tuple[TermParts, list[str]]:
    import pickle

    with open(__file__.replace(".py", ".capture"), "rb") as fd:
        data = pickle.load(fd)

    if not isinstance(data, tuple) or not len(data) == 2:
        raise Exception("Invalid capture format")

    updated, cultures = data

    if not isinstance(updated, TermParts):
        raise Exception("Invalid capture format")

    if (
        not isinstance(cultures, list)
        or not len(cultures) > 1
        or not isinstance(cultures[0], str)
    ):
        raise Exception("Invalid capture format")

    return updated, cultures


def update_db_state(context, cultures):
    with context.connmgr.get_connection("admin") as conn:
        conn.execute("EXEC sp_TAX_U_Metadata_iu ?", ",".join(cultures))


def run_update_taxonomy(args: TaxonomyArgsType, context):
    with get_bulk_connection(_lang_settings[0].sql_language) as conn:
        if args.capture_changes or not args.use_capture:
            updated, cultures = fetch_updated_terms_from_211hsis(args, conn)
            if args.capture_changes:
                capture_changes(updated, cultures)

        else:  # use capture case
            updated, cultures = load_changes()

        if not args.skip_import:
            delete_terms(args, conn, updated.to_delete)
            import_terms(args, conn, updated.terms)
            import_old_codes(args, conn, updated.old_codes)
            import_see_also(args, conn, updated.see_also)
            import_use_references(args, conn, updated.use_references)
            import_concepts(args, conn, updated.concepts)
            import_concept_map(args, conn, updated.concept_map)
            update_db_state(context, cultures)


def main(argv):
    args = parse_args(argv)

    context = Context(args)
    retval = 0
    fakestdout = StringIO()
    try:
        args.config = context.config
    except Exception:
        sys.stderr.write("ERROR: Could not process config file:\n")
        sys.stderr.write(traceback.format_exc())
        return 2

    if args.email:
        sys.stdout = fakestdout
        sys.stderr = sys.stdout

    sys.stderr = FileWriteDetector(sys.stderr)

    try:
        taxargs = prepare_session(args)
        run_update_taxonomy(taxargs, context)

    except Exception:
        traceback.print_exc()

    if sys.stderr.is_dirty():
        retval = 1

    if args.email:
        email_log(
            args,
            fakestdout,
            f"Tax import for {const._app_name}%s",
            sys.stderr.is_dirty(),
            "tax_import",
        )

    return retval


if __name__ == "__main__":
    normalstdout = sys.stdout
    normalstderr = sys.stderr
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:
        sys.stdout = normalstdout
        sys.stderr = normalstderr

        raise
