# =========================================================================================
#  Copyright 2018 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
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
import json
import pprint
import time
import re
from queue import Queue
from collections import namedtuple
from io import StringIO, TextIOWrapper
import os
import sys
import tempfile
import typing as t
import traceback
import urllib.parse
from collections import OrderedDict
from datetime import datetime
from threading import Thread
from operator import itemgetter

import boto3
import isodate
import requests

try:
    import cioc  # NOQA
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from tools.toolslib import (
    Context,
    FileWriteDetector,
    get_config_item,
    email_log,
    get_bulk_connection,
)


from cioc.core import constants as const
from cioc.core import syslanguage
from cioc.core.utf8csv import UTF8CSVWriter, SQLServerBulkDialect
from cioc.web.import_.upload import process_import

if t.TYPE_CHECKING:
    from boto3_type_annotations.s3 import Client


CREATE_NO_WINDOW = 0x08000000
creationflags = 0


invalid_xml_chars = re.compile("[\x00-\x08\x0c\x0e-\x19]")

const.update_cache_values()
_time_format = "%Y-%m-%d %H:%M:%S"
LangSetting = namedtuple(
    "LangSetting", "culture file_suffix language_name sql_language"
)

_lang_settings = {
    "en-CA": LangSetting("en-CA", "", "en", syslanguage.SQLALIAS_ENGLISH),
    "fr-CA": LangSetting("fr-CA", "_frCA", "fr", syslanguage.SQLALIAS_FRENCH),
}

FieldOrder = [
    "ResourceAgencyNum",
    "ImportDate",
    "ImportStatus",
    "Refresh",
    "PublicName",
    "AlternateName",
    "OfficialName",
    "TaxonomyLevelName",
    "ParentAgency",
    "ParentAgencyNum",
    "RecordOwner",
    "UniqueIDPriorSystem",
    "MailingAttentionName",
    "MailingAddress1",
    "MailingAddress2",
    "MailingCity",
    "MailingStateProvince",
    "MailingPostalCode",
    "MailingCountry",
    "MailingAddressIsPrivate",
    "PhysicalAddress1",
    "PhysicalAddress2",
    "PhysicalCity",
    "PhysicalCounty",
    "PhysicalStateProvince",
    "PhysicalPostalCode",
    "PhysicalCountry",
    "PhysicalAddressIsPrivate",
    "OtherAddress1",
    "OtherAddress2",
    "OtherCity",
    "OtherCounty",
    "OtherStateProvince",
    "OtherPostalCode",
    "OtherCountry",
    "Latitude",
    "Longitude",
    "HoursOfOperation",
    "Phone1Number",
    "Phone1Name",
    "Phone1Description",
    "Phone1IsPrivate",
    "Phone1Type",
    "Phone2Number",
    "Phone2Name",
    "Phone2Description",
    "Phone2IsPrivate",
    "Phone2Type",
    "Phone3Number",
    "Phone3Name",
    "Phone3Description",
    "Phone3IsPrivate",
    "Phone3Type",
    "Phone4Number",
    "Phone4Name",
    "Phone4Description",
    "Phone4IsPrivate",
    "Phone4Type",
    "Phone5Number",
    "Phone5name",
    "Phone5Description",
    "Phone5IsPrivate",
    "Phone5Type",
    "PhoneFax",
    "PhoneFaxDescription",
    "PhoneFaxIsPrivate",
    "PhoneTTY",
    "PhoneTTYDescription",
    "PhoneTTYIsPrivate",
    "PhoneTollFree",
    "PhoneTollFreeDescription",
    "PhoneTollFreeIsPrivate",
    "PhoneNumberHotline",
    "PhoneNumberHotlineDescription",
    "PhoneNumberHotlineIsPrivate",
    "PhoneNumberBusinessLine",
    "PhoneNumberBusinessLineDescription",
    "PhoneNumberBusinessLineIsPrivate",
    "PhoneNumberOutOfArea",
    "PhoneNumberOutOfAreaDescription",
    "PhoneNumberOutOfAreaIsPrivate",
    "PhoneNumberAfterHours",
    "PhoneNumberAfterHoursDescription",
    "PhoneNumberAfterHoursIsPrivate",
    "EmailAddressMain",
    "WebsiteAddress",
    "AgencyStatus",
    "AgencyClassification",
    "AgencyDescription",
    "SearchHints",
    "CoverageArea",
    "CoverageAreaText",
    "Eligibility",
    "EligibilityAdult",
    "EligibilityChild",
    "EligibilityFamily",
    "EligibilityFemale",
    "EligibilityMale",
    "EligibilityTeen",
    "SeniorWorkerName",
    "SeniorWorkerTitle",
    "SeniorWorkerEmailAddress",
    "SeniorWorkerPhoneNumber",
    "SeniorWorkerIsPrivate",
    "MainContactName",
    "MainContactTitle",
    "MainContactEmailAddress",
    "MainContactPhoneNumber",
    "MainContactType",
    "MainContactIsPrivate",
    "LicenseAccreditation",
    "IRSStatus",
    "FEIN",
    "YearIncorporated",
    "AnnualBudgetTotal",
    "LegalStatus",
    "SourceOfFunds",
    "ExcludeFromWebsite",
    "ExcludeFromDirectory",
    "DisabilitiesAccess",
    "PhysicalLocationDescription",
    "BusServiceAccess",
    "PublicAccessTransportation",
    "PaymentMethods",
    "FeeStructureSource",
    "ApplicationProcess",
    "ResourceInfo",
    "DocumentsRequired",
    "LanguagesOffered",
    "LanguagesOfferedList",
    "AvailabilityNumberOfTimes",
    "AvailabilityFrequency",
    "AvailabilityPeriod",
    "ServiceNotAlwaysAvailability",
    "CapacityType",
    "ServiceCapacity",
    "NormalWaitTime",
    "TemporaryMessage",
    "TemporaryMessageAppears",
    "TemporaryMessageExpires",
    "EnteredOn",
    "UpdatedOn",
    "MadeInactiveOn",
    "InternalNotes",
    "InternalNotesForEditorsAndViewers",
    "HighlightedResource",
    "LastVerifiedOn",
    "LastVerifiedByName",
    "LastVerifiedByTitle",
    "LastVerifiedByPhoneNumber",
    "LastVerifiedByEmailAddress",
    "LastVerificationApprovedBy",
    "AvailableForDirectory",
    "AvailableForReferral",
    "AvailableForResearch",
    "PreferredProvider",
    "ConnectsToSiteNum",
    "ConnectsToProgramNum",
    "LanguageOfRecord",
    "CurrentWorkflowStepCode",
    "VolunteerOpportunities",
    "VolunteerDuties",
    "IsLinkOnly",
    "ProgramAgencyNamePublic",
    "SiteAgencyNamePublic",
    "Categories",
    "TaxonomyTerm",
    "TaxonomyTerms",
    "TaxonomyTermsNotDeactivated",
    "TaxonomyCodes",
    "Coverage",
    "Hours",
    "Custom_Public Comments",
    "Custom_Former Names",
    "Custom_Headings",
    "Custom_Legal Name",
    "Custom_Pub Codes",
    "Custom_Record Owner (controlled)",
    "Custom_SINV",
    "Custom_iCarol-managed record",
    "Custom_Facebook",
    "Custom_Instagram",
    "Custom_LinkedIn",
    "Custom_Twitter",
    "Custom_YouTube",
    "Custom_Minimum Age",
    "Custom_Maximum Age",
    "Custom_Deleted Record",
    "MailingCommunity",
    "OtherCommunity",
    "PhysicalCommunity",
]
other_known_fields = [
    "Custom_Bed Count",
    "Custom_ESDCID",
    "Custom_Elig by Family Comp",
    "Custom_Elig by Gender",
    "Custom_Elig by Target Pop",
    "Custom_FRV update yymmdd",
    "Custom_Last Updated By",
    "Custom_Non-211 Record",
    "Custom_OF Bed Count",
    "Custom_Priority Level",
    "Custom_Verification Month",
    "Custom_iCarol-completed Record",
]

AllRecordsFieldOrder = [
    "ResourceAgencyNum",
    "ParentAgencyNum",
    "ConnectsToSiteNum",
    "ConnectsToProgramNum",
    "UniqueIDPriorSystem",
    "PublicName",
    "TaxonomyLevelName",
    "iCarolManaged",
    "RecordOwner",
    "UpdatedOn",
]


class ICarolFetchContext(Context):
    s3_client: Client

    def __init__(self, args, s3_client):
        super().__init__(args)
        self.s3_client = s3_client


def prepare_session(args):
    session = requests.Session()
    session.headers.update({"Accept": "application/json"})
    args.session = session
    args.host = get_config_item(args, "o211_import_api_host")
    args.key = get_config_item(args, "o211_import_api_key", "")


def parse_args(argv):
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
        "--modified-since", dest="modified_since", action="store", default=None
    )
    parser.add_argument(
        "--fetch-mechanism", dest="fetch_mechanism", action="store", default=None
    )
    parser.add_argument("--only-lang", dest="only_lang", action="append", default=[])
    parser.add_argument(
        "--skip-fetch", dest="skip_fetch", action="store_true", default=False
    )
    parser.add_argument(
        "--skip-import", dest="skip_import", action="store_true", default=False
    )

    args = parser.parse_args(argv)
    if args.config_prefix and not args.config_prefix.endswith("."):
        args.config_prefix += "."

    if args.modified_since and args.modified_since != "any":
        try:
            args.modified_since = isodate.parse_datetime(args.modified_since)
        except:
            parser.error("invalid date format must be like 2018-10-10T15:45:00")

    return args


def pager(iterable, page_size=10):
    page = []
    count = 0
    for x in iterable:
        count += 1
        page.append(x)
        if count >= page_size:
            yield page
            count = 0
            page = []

    if page:
        yield page


def get_record_list(args, modifiedSince=None, lang="en"):
    url = "https://" + args.host + "/api/records/"
    params = {"key": args.key, "service": "0", "lang": lang}

    if args.extra_criteria:
        params.update(args.extra_criteria)

    if modifiedSince:
        params["updatedOn"] = modifiedSince

    url = url + "?" + urllib.parse.urlencode(params)

    response = args.session.get(url)
    response.raise_for_status()
    data = response.json(object_pairs_hook=OrderedDict)
    if isinstance(data, dict):
        error = data.get("Error")
        if error:
            raise Exception("Request Error: %s" % error)
        raise Exception("Response dictionary not list: %r" % data)

    return data


def get_records(args, id, lang="en"):
    url = "https://" + args.host + "/api/record/"
    if not isinstance(id, list):
        id = [id]

    id_str = list(map(str, id))
    params = {"id": ",".join(id_str), "key": args.key, "service": "0", "lang": lang}
    url = url + "?" + urllib.parse.urlencode(params)
    start = time.time()
    response = args.session.get(url)
    duration = time.time() - start
    if args.test:
        print(f"requested {len(id)} records in {duration}s")
    response.raise_for_status()
    tmp = {
        x["ResourceAgencyNum"]: x
        for x in json.loads(
            response.text,
            object_pairs_hook=OrderedDict,
        )
    }
    result = [tmp[x] for x in id]
    return result


def fetch_record_batches(args, record_ids, lang):
    for page in pager(record_ids, 500):
        yield from get_records(args, page, lang.language_name)


def _to_unicode(value):
    if value is None:
        return ""

    value = str(value)
    return invalid_xml_chars.sub("", value).strip()


def to_csv(records, target_file, headings):
    fn = itemgetter(*headings)

    writer = UTF8CSVWriter(target_file)  # , dialect=SQLServerBulkDialect)
    out_stream = (list(map(_to_unicode, fn(x))) for x in records)
    writer.writerows(out_stream)


class CsvFileWriter:
    def __init__(self, context, headings):
        self.s3_bulk_import_bucket = context.s3_bulk_import_bucket
        self.s3_bulk_import_prefix = context.s3_bulk_import_prefix
        self.s3_client = context.s3_client
        self.fd = None
        self.file_name = None
        self.headings = headings

    def __enter__(self):
        self.fd = tempfile.TemporaryFile(suffix=".csv")
        self.wrapped_fd = TextIOWrapper(self.fd, encoding="utf-16", newline="")
        self.file_name = os.path.basename(self.fd.name)
        return self

    def __exit__(self, type, value, tb):
        if self.file_name:
            try:
                self.s3_client.delete_object(
                    Bucket=self.s3_bulk_import_bucket,
                    Key=self.s3_bulk_import_prefix + self.source_file,
                )
            except Exception:
                pass

    def serialize_records(self, records):
        if not self.fd:
            raise Exception("File not opened yet")

        to_csv(records, self.wrapped_fd, self.headings)

    def close(self):
        if self.fd:
            self.wrapped_fd.flush()
            self.fd.seek(0)
            self.s3_client.upload_fileobj(
                self.fd,
                self.s3_bulk_import_bucket,
                self.source_file,
            )
            self.wrapped_fd.close()
            self.wrapped_fd = None
            self.fd.close()
            self.fd = None

    @property
    def source_file(self):
        return self.s3_bulk_import_prefix + self.file_name


# class ParquetFileWriter:
#     def __init__(self, context, headings):
#         self.s3_bulk_import_bucket = context.s3_bulk_import_bucket
#         self.s3_bulk_import_prefix = context.s3_bulk_import_prefix
#         self.s3_client = context.s3_client
#         self.fd = None
#         self.file_name = None
#         self.headings = headings
#         self.schema = pa.schema([(x, pa.string()) for x in headings])

#     def __enter__(self):
#         self.fd = tempfile.TemporaryFile(suffix=".parquet")
#         self.file_name = os.path.basename(self.fd.name)
#         return self

#     def __exit__(self, type, value, tb):
#         if self.file_name and False:
#             try:
#                 self.s3_client.delete_object(
#                     Bucket=self.s3_bulk_import_bucket,
#                     Key=self.s3_bulk_import_prefix + self.source_file,
#                 )
#             except Exception:
#                 pass

#     def serialize_records(self, records):
#         if not self.fd:
#             raise Exception("File not opened yet")

#         fn = itemgetter(*self.headings)

#         out_stream = (list(map(_to_unicode, fn(x))) for x in records)
#         tbl = pa.table(out_stream, schema=self.schema)
#         pq.write_table(tbl, self.fd)

#     def close(self):
#         if self.fd:
#             self.fd.seek(0)
#             self.s3_client.upload_fileobj(
#                 self.fd,
#                 self.s3_bulk_import_bucket,
#                 self.source_file,
#             )
#             self.fd.close()
#             self.fd = None

#     @property
#     def source_file(self):
#         return self.s3_bulk_import_prefix + self.file_name


def push_bulk(context, conn, sql, headings, batch, *args):
    with CsvFileWriter(context, headings) as writer:
        writer.serialize_records(batch)
        writer.close()
        cursor = conn.execute(
            sql,
            *(args + ("/" + context.s3_bulk_import_bucket + "/" + writer.source_file,)),
        )

    return cursor


def push_to_database(context, lang, queue):
    sql = """
    EXEC sp_CIC_iCarolImport_Incremental ?, ?
    """
    next_modified = context.args.next_modified_since
    with get_bulk_connection(language=lang.sql_language) as conn:
        while True:
            batch = queue.get()
            if batch is None:
                queue.task_done()
                return

            try:
                push_bulk(context, conn, sql, FieldOrder, batch, next_modified)
            except Exception:
                traceback.print_exc()
            queue.task_done()


def push_all_records(conext, lang, all_records):
    sql = """
    EXEC sp_CIC_iCarolImport_AllRecords ?
    """
    with get_bulk_connection(language=lang.sql_language) as conn:
        cursor = push_bulk(conext, conn, sql, AllRecordsFieldOrder, all_records)
        stats = cursor.fetchall()
        cursor.nextset()
        results = cursor.fetchall()
        return stats, results


def fetch_from_o211(context, lang):
    all_records = get_record_list(context.args, "any", lang.language_name)
    stats, records = push_all_records(context, lang, all_records)
    if context.args.test:
        records.sort(key=lambda x: x["UpdatedOn"])
        records = records[-60:]
        pprint.pprint(records)
        return

    for row in stats:
        if row.resurrected:
            action = (
                f"resurrected from {row.tbl} which were deleted on {row.days_deleted}"
            )
        elif row.op == "mark":
            action = f"marked for deletion from {row.tbl} with deletion days on {row.days_deleted}"
        elif row.op == "purge":
            action = f"purged from {row.tbl}"
        else:
            action = f"unexpected action: op={row.op}, tbl={row.tbl}, resurected={row.resurected}, days_deleted={row.days_deleted}"

        if row.days_imported:
            action = f"{action}. records last imported on {row.days_imported}"

        print(f"{row.num_records} records were {action}")

    queue = Queue(maxsize=2)
    thread = Thread(target=push_to_database, args=(context, lang, queue))
    thread.daemon = True
    thread.start()

    pulled_record_count = 0
    for batch in pager(
        fetch_record_batches(
            context.args, (x.ResourceAgencyNum for x in records), lang
        ),
        5000,
    ):
        pulled_record_count += len(batch)
        queue.put(batch)

    queue.put(None)
    queue.join()

    print(
        "Pulled %s changed source records in %s."
        % (pulled_record_count, lang.sql_language)
    )


def check_db_state(context):
    context.args.extra_criteria = None
    if not context.args.fetch_mechanism:
        return

    sql = "SELECT * FROM CIC_iCarolImportMeta WHERE Mechanism=?"
    with context.connmgr.get_connection("admin") as conn:
        meta_data = conn.execute(sql, context.args.fetch_mechanism).fetchone()

    if not meta_data:
        # XXX Should we do something to indicate to an operator that something is missing?
        return

    if meta_data.ExtraCriteria:
        context.args.extra_criteria = json.loads(meta_data.ExtraCriteria)

    if not context.args.modified_since:
        context.args.modified_since = meta_data.LastFetched

    # XXX Should this be observed value instead of this
    context.args.next_modified_since = datetime.now()


def format_modified_date(context):
    if context.args.modified_since is None:
        context.args.modified_since = "any"

    if context.args.modified_since == "any":
        return

    context.args.modified_since = context.args.modified_since.strftime(_time_format)


def update_db_state(context):
    if not context.args.fetch_mechanism:
        return

    sql = "EXEC dbo.sp_CIC_iCarolImportMeta_u ?, ?"
    with context.connmgr.get_connection("admin") as conn:
        conn.execute(
            sql, context.args.fetch_mechanism, context.args.next_modified_since
        )


def _generate_and_upload_import(
    context,
    member_name,
    member,
    stdout,
    stderr,
    cursor,
    extra_message="",
    extra_filename="",
):
    total_inserted = 0
    batch = cursor.fetchmany(5000)

    if not batch:
        return 0
    else:
        print(f"Processing{extra_message} Imports for {member_name}.", file=stdout)

    with tempfile.TemporaryFile() as fd:
        fd.write(
            b"""<?xml version="1.0" encoding="UTF-8"?>
        <root xmlns="urn:ciocshare-schema"><SOURCE_DB CD="ICAROL"/><DIST_CODE_LIST/><PUB_CODE_LIST/>"""
        )
        while batch:
            fd.write("".join(x.record for x in batch).encode("utf8"))
            batch = cursor.fetchmany(5000)

        fd.write(b"</root>")
        fd.seek(0)

        error_log, total_inserted = process_import(
            "icarol_import_%s%s.xml"
            % (
                extra_filename,
                context.args.next_modified_since.isoformat(),
            ),
            fd,
            member.MemberID,
            const.DM_CIC,
            const.DM_S_CIC,
            "(import system)",
            "iCarol Import%s %s"
            % (
                extra_message,
                context.args.next_modified_since.isoformat(),
            ),
            context.connmgr,
            lambda x: x,
        )

    print(
        "Import%s Complete for Member %s. %s records imported."
        % (extra_filename, member_name, total_inserted),
        file=stdout,
    )
    if error_log:
        print(
            "A problem was encountered validating%s input for Member %s, see below."
            % (extra_message.lower(), member_name),
            file=stderr,
        )

    for record, errmsg in error_log:
        if record:
            print(": ".join((record, errmsg)).encode("utf8"), file=stderr)
        else:
            print(errmsg.encode("utf8"), file=stderr)
    return total_inserted


def generate_and_upload_import(context):
    sql = "EXEC sp_CIC_iCarolImport_Rollup"
    total_import_count = 0
    with context.connmgr.get_connection("admin") as conn:
        cursor = conn.execute(sql)
        members = cursor.fetchall()
        cursor.close()
        for member in members:
            stdout = StringIO()
            stderr = FileWriteDetector(stdout)
            try:
                member_name = (
                    member.DefaultEmailNameCIC or member.BaseURLCIC or member.MemberID
                )
                print(f"Generating sharing file for {member_name}.\n", file=stdout)

                cursor = conn.execute(
                    "EXEC sp_CIC_iCarolImport_CreateSharing ?", member.MemberID
                )
                total_inserted_base = _generate_and_upload_import(
                    context, member_name, member, stdout, stderr, cursor
                )
                cursor.nextset()
                (total_inserted_missed_deletes) = _generate_and_upload_import(
                    context,
                    member_name,
                    member,
                    stdout,
                    stderr,
                    cursor,
                    " Missed Deletes",
                    "_missed_deletes",
                )

                cursor.close()

                total_inserted = total_inserted_base + total_inserted_missed_deletes
                if not total_inserted:
                    print(f"No Records for {member_name}, skipping.\n", file=stdout)
                    continue

                total_import_count += total_inserted

                if context.args.email and member.ImportNotificationEmailCIC:
                    # email sending is turned on and this member has a configured email target.
                    email_log(
                        context.args,
                        stdout,
                        stderr.is_dirty(),
                        "o211_import",
                        to=member.ImportNotificationEmailCIC,
                    )

            finally:
                if stderr.is_dirty():
                    print(stdout.getvalue(), file=sys.stderr)
                else:
                    print(stdout.getvalue())

    print(f"Completed Processing Imports: {total_import_count} Records imported.")


def main(argv):
    args = parse_args(argv)

    context = ICarolFetchContext(args, boto3.client("s3"))
    retval = 0
    try:
        args.config = context.config
    except Exception:
        sys.stderr.write("ERROR: Could not process config file:\n")
        sys.stderr.write(traceback.format_exc())
        return 2

    if args.email:
        if not get_config_item(args, "o211_import_notify_emails", None):
            sys.stderr.write(
                "ERROR: No value for o211_import_notify_emails set in config\n"
            )
            return 3
        else:
            sys.stdout = StringIO()
            sys.stderr = sys.stdout

    sys.stderr = FileWriteDetector(sys.stderr)

    try:
        prepare_session(args)
        check_db_state(context)
        format_modified_date(context)
        context.s3_bulk_import_bucket = get_config_item(args, "s3_bulk_import_bucket")
        context.s3_bulk_import_prefix = get_config_item(args, "s3_bulk_import_prefix")

        langs = get_config_item(args, "o211_import_languages", "en-CA").split(",")
        for culture in langs:
            if args.only_lang and culture not in args.only_lang:
                print("Skipping ", culture)
                continue

            lang = _lang_settings.get(culture.strip(), _lang_settings["en-CA"])

            if not args.skip_fetch:
                fetch_from_o211(context, lang)
                print("\n")

        if not args.skip_import:
            generate_and_upload_import(context)

        if not args.skip_fetch:
            # we only want to update the High Water Mark when we actually fetch data.
            update_db_state(context)
    except Exception:
        traceback.print_exc()

    if sys.stderr.is_dirty():
        retval = 1

    if args.email:
        email_log(args, sys.stdout, sys.stderr.is_dirty(), "o211_import")

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
