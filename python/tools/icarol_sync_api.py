import argparse
import os
import operator
import sys
import traceback
import typing as t
from io import StringIO
from dataclasses import dataclass, field

from simple_icarol_api import ICarolClient, model
from lxml import etree

try:
    import cioc  # NOQA
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))


from cioc.core import constants as const

if t.TYPE_CHECKING:
    from pyodbc import Connection, Row


const.update_cache_values()

from tools.toolslib import (
    ArgsType,
    Context,
    FileWriteDetector,
    get_config_item,
    email_log,
)


@dataclass
class ProgramAtSiteInfo:
    site_num: str
    site_id: t.Optional[int] = None
    program_at_site_name: t.Optional[str] = None
    program_at_site_id: t.Optional[int] = None


@dataclass
class RecordInfo:
    record: model.ResourceDetails
    related_sites: list[ProgramAtSiteInfo]


@dataclass
class MyArgsType(ArgsType):
    client: ICarolClient = field(default_factory=lambda: ICarolClient("localhost", ""))
    dbinfo: list[model.DatabaseInfo] = field(default_factory=list)
    dbid: int = -1
    fields: model.ResourceDefinition = field(default_factory=model.ResourceDefinition)
    idmap: dict[tuple[str, str], t.Optional[int]] = field(default_factory=dict)
    id_generator: t.Optional[t.Iterator[int]] = field(
        default_factory=lambda: iter(range(12_000_000, 15_000_000))
    )
    skip_unknown_value_fields: t.Iterable[str] = field(default_factory=list)
    unknown_fields_value_options_shown: set[str] = field(default_factory=set)


def prepare_client(args: MyArgsType) -> None:
    host = get_config_item(args, "icarol_export_api_host", "apitest.icarol.com")
    token = get_config_item(args, "icarol_export_api_token", "")
    if not token:
        raise Exception("No API Token Configured")

    assert host

    args.client = ICarolClient(host, token)
    args.dbinfo = args.client.database_info()
    args.dbid = args.dbinfo[0].id

    args.fields = args.client.get_custom_fields(args.dbid)
    if args.test:
        print(args.fields)

    args.skip_unknown_value_fields = [
        x
        for x in get_config_item(
            args, "icarol_export_api_skip_unknown_value_fields", ""
        ).split(",")
        if x
    ]
    args.idmap = {}


def get_changes_to_send(conn: "Connection") -> list["Row"]:
    sql = "EXEC sp_CIC_iCarolExport_l"
    return conn.execute(sql).fetchall()


def parse_sub_xml(
    element: etree._Element,
) -> t.Union[list[t.Union[dict[str, t.Any], str]], dict[str, t.Any], str]:
    if element.get("_empty_list", "") == "1":
        return []

    if len(element) and element[0].tag == "item":
        return t.cast(
            list[t.Union[dict[str, t.Any], str]],
            [parse_sub_xml(sub) for sub in element],
        )
    if element.text and not element.keys() and not len(element):
        return element.text.strip()

    base = dict(element.attrib)
    for sub in element:
        base[sub.tag] = t.cast(str, parse_sub_xml(sub))

    return t.cast(dict[str, t.Any], base)


def fix_custom_fields(args: MyArgsType, records: list[dict], num: str):
    assert args.fields  # appease type system
    for record in records:
        for custom in record.get("customFields", []):
            field = args.fields.label_to_field[custom["label"]]
            custom["id"] = field.id
            skip_if_unknown = False
            if custom["label"] in (args.skip_unknown_value_fields or []):
                skip_if_unknown = True
            selected_values: list[str] = custom.get("selectedValues")
            if not selected_values:
                continue
            if skip_if_unknown:
                keep: list[str] = []
                skip: list[str] = []
                for x in selected_values:
                    if x in field.label_to_id:
                        keep.append(x)
                    else:
                        skip.append(x)

                selected_values = keep
                if skip:
                    print(
                        f"Warning: skipping unknown values for custom field '{custom['label']}' on {record['type']} {num}: {', '.join(skip)}"
                    )
                    if custom["label"] not in args.unknown_fields_value_options_shown:
                        args.unknown_fields_value_options_shown.add(custom["label"])
                        print(
                            f"Possible values for custom field '{custom['label']}' are: {field.label_to_id.keys()}"
                        )
            try:
                custom["selectedValues"] = {
                    str(field.label_to_id[x]): x for x in selected_values
                }
            except KeyError as e:
                raise Exception(
                    f"Unable to map value '{e.args[0]}' to a custom field selection for {custom['label']} on {record['type']} {num}. Possible values are: {field.label_to_id.keys()}"
                )


def parse_related_records(
    args: MyArgsType, record: dict[str, t.Any], num: str
) -> RecordInfo:
    related_sites = []
    agency_related = []
    for related in record.pop("related", []):
        related_num = related.pop("uniquePriorID")
        external_id = related.get("id")
        name = related.pop("name", None)
        if external_id is None:
            try:
                external_id = related["id"] = args.idmap[(related_num, related["type"])]
            except KeyError:
                raise Exception(
                    f"Can't build relationship to {related['type']} {related_num} for {record['type']} {num} because there is no known ICarol ID"
                )
        else:
            external_id = related["id"] = int(external_id, 10)

        if related["type"] == "Agency":
            agency_related.append(related)
        else:
            related_sites.append(ProgramAtSiteInfo(related_num, external_id, name))

    if agency_related:
        record["related"] = agency_related

    return RecordInfo(
        model.ResourceDetails(databaseID=args.dbid, **record), related_sites
    )


def parse_change_to_model(
    args: MyArgsType, datachange: str, num: str
) -> list[RecordInfo]:
    xdoc = etree.fromstring(datachange)

    records = t.cast(list[dict[str, t.Any]], parse_sub_xml(xdoc))
    fix_custom_fields(args, records, num)

    return [parse_related_records(args, x, num) for x in records]


def make_program_at_site(
    args: MyArgsType,
    name: str,
    agency_id: int,
    site_id: int,
    program_id: int,
    program_at_site_id: model.APIOptional[int] = model.unset_value,
) -> int:
    program_at_site = model.ResourceDetails(
        databaseID=args.dbid,
        id=program_at_site_id,
        names=[model.ResourceName(value=name, purpose="Primary")],
        type="ProgramAtSite",
        status="Active",
        related=[
            model.RelatedRecordInfo(id=agency_id),
            model.RelatedRecordInfo(id=site_id),
            model.RelatedRecordInfo(id=program_id),
        ],
    )
    if program_at_site_id is not model.unset_value and program_at_site_id is not None:
        if not args.test:
            args.client.update_resource(program_at_site_id, program_at_site)
    else:
        if not args.test:
            result = args.client.create_resource(program_at_site)
            program_at_site_id = result["id"]
        else:
            program_at_site_id = next(args.id_generator)

    if args.test:
        print(program_at_site.to_dict())

    return program_at_site_id


def update_program_at_sites(
    args: MyArgsType,
    record_id: int,
    agency_id: int,
    external_ids: list[str],
    related_sites: list[ProgramAtSiteInfo],
    num: str,
):
    program_at_site_ids = {
        site_num: id for site_num, id in (x.split("/") for x in external_ids)
    }

    linked_site_nums = set()
    for prog_at_site in related_sites:
        try:
            site_id = (
                prog_at_site.site_id or args.idmap[(prog_at_site.site_num, "Site")]
            )
        except KeyError:
            # TODO should this one just skip this program_at_site. We've already synced a program
            # so this would leak a program?
            print(
                f"Can't build relationship to Site {prog_at_site.site_num} for Program {num} because there is no known ICarol ID",
                file=sys.stderr,
            )
        program_at_site_id = program_at_site_ids.get(
            prog_at_site.site_num, model.unset_value
        )
        try:
            prog_at_site.program_at_site_id = make_program_at_site(
                args,
                prog_at_site.program_at_site_name,
                agency_id,
                site_id,
                record_id,
                program_at_site_id,
            )
        except Exception as e:
            if prog_at_site.program_at_site_id is model.unset_value:
                prog_at_site.program_at_site_id = None

            traceback.print_exc(file=sys.stderr)
            print(
                f"Failed to create/update ProgramAtSite {prog_at_site.site_num}/{prog_at_site.program_at_site_id} for Program {num} due to an error.",
                "This may have leaked a ProgramAtSite record.",
                e,
                file=sys.stderr,
            )

        linked_site_nums.add(prog_at_site.site_num)

    deleted_site_links = [
        (site_num, id)
        for site_num, id in program_at_site_ids.items()
        if site_num not in linked_site_nums
    ]
    for site_num, prog_at_site_id in deleted_site_links:
        if not args.test:
            try:
                args.client.delete_resource(prog_at_site_id)
            except Exception:
                print(
                    f"Failed to delete ProgramAtSite {site_num}/{prog_at_site_id} for Program {num} due to an error.",
                    "This may have leaked a ProgramAtSite record.",
                    traceback.format_exc(chain=False),
                    file=sys.stderr,
                )
        else:
            print(f"would delete program at site {prog_at_site_id} for {site_num}")


def sync_record(
    args: MyArgsType,
    record_num: str,
    external_id: t.Optional[str],
    olscode: str,
    datachange: str,
) -> t.Optional[str]:
    try:
        record_languages = parse_change_to_model(args, datachange, record_num)
    except Exception:
        print(
            f"Failed to create/update {olscode} {record_num}/{external_id} due to an error.",
            traceback.format_exc(chain=False),
            file=sys.stderr,
        )
        return external_id

    record_id, *external_ids = (external_id or "").split(";")
    if record_id:
        record_id = int(record_id, 10)
    else:
        record_id = None

    for record_lang in record_languages:
        isnew = record_id is None
        record = record_lang.record
        try:
            if not isnew:
                record.id = record_id
                if not args.test:
                    args.client.update_resource(record.id, record)
            else:
                if not args.test:
                    result = args.client.create_resource(record)
                    record_id = result["id"]
                else:
                    record_id = next(args.id_generator)

            if args.test:
                print(isnew, record.to_dict())

        except Exception as e:
            traceback.print_exc(file=sys.stderr)
            print(
                f"Failed to create/update {record.type} {record_num}/{record_id} due to an error.",
                "This may have leaked record.",
                e,
                record.to_dict(),
                file=sys.stderr,
            )

    if record_id:
        args.idmap[(record_num, record.type)] = record_id

        related_sites = record_languages[0].related_sites
        if olscode in ("SERVICE", "TOPIC"):
            agency_id = record.related[0].id
            try:
                update_program_at_sites(
                    args, record_id, agency_id, external_ids, related_sites, record_num
                )
            except Exception as e:
                traceback.print_exc(file=sys.stderr)
                print(
                    "Error encountered while attempting to update program_at_site. May have leaked ids.",
                    e,
                    file=sys.stderr,
                )

        new_external_id = ";".join(
            [str(record_id)]
            + [
                f"{x.site_num}/{x.program_at_site_id}"
                for x in sorted(related_sites, key=operator.attrgetter("site_num"))
                if x.program_at_site_id
            ]
        )
        return new_external_id


def mark_change_completed(
    args: MyArgsType,
    conn: "Connection",
    record_num: str,
    external_id: t.Optional[str],
    olscode: str,
) -> None:
    if args.test:
        print(f"mark complete {record_num}, {external_id}, {olscode}")
    else:
        conn.execute(
            "EXEC sp_CIC_iCarolExport_u ?, ?, ?", record_num, olscode, external_id
        )


def sync_iteration(args: MyArgsType, conn: "Connection") -> int:
    changes = get_changes_to_send(conn)
    for change in changes:
        new_external_id = sync_record(
            args, change.NUM, change.EXTERNAL_ID, change.OLSCode, change.datachange
        )
        mark_change_completed(args, conn, change.NUM, new_external_id, change.OLSCode)

    return len(changes)


def sync(args: MyArgsType, context: Context) -> None:
    with context.connmgr.get_connection("admin") as conn:
        total_changes = 0
        change_count = -1
        while change_count:
            change_count = sync_iteration(args, conn)
            total_changes += change_count
            if args.test:
                change_count = 0

        print(f"sent {total_changes} records")


def parse_args(argv: list[str]) -> MyArgsType:
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

    args = MyArgsType(**vars(parser.parse_args(argv)))
    if args.config_prefix and not args.config_prefix.endswith("."):
        args.config_prefix += "."

    return args


def main(argv):
    args = parse_args(argv)
    context = Context(args)
    capture_io = StringIO()
    retval = 0
    try:
        args.config = context.config
    except Exception:
        sys.stderr.write("ERROR: Could not process config file:\n")
        sys.stderr.write(traceback.format_exc())
        return 2

    if args.email:
        if not get_config_item(args, "icarol_export_notify_emails", None):
            sys.stderr.write(
                "ERROR: No value for icarol_export_notify_emails set in config\n"
            )
            return 3
        else:
            sys.stdout = capture_io
            sys.stderr = sys.stdout

    sys.stderr = FileWriteDetector(sys.stderr)

    try:
        prepare_client(args)
        sync(args, context)
    except Exception:
        traceback.print_exc()

    if sys.stderr.is_dirty():
        retval = 1

    if args.email:
        email_log(
            args, capture_io, "ICarol API Sync%s", sys.stderr.is_dirty(), "icarol_export"
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
