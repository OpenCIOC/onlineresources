import io
import os
import sys
import typing as t
from dataclasses import dataclass, field

from pyramid.decorator import reify
import pyodbc

try:
    import cioc  # NOQA
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import constants as const, request, config, email
from cioc.core.connection import ConnectionError

import typing as t

if t.TYPE_CHECKING:
    from functools import cached_property as reify

const.update_cache_values()

dts_file_template = os.path.join(
    os.environ.get("CIOC_UDL_BASE", r"d:\UDLS"), "%s", "cron_job_runner.UDL"
)


@dataclass
class ArgsType:
    configfile: str
    config_prefix: str = ""
    test: bool = False
    email: bool = False
    config: dict = field(default_factory=dict)


class ContextBase:
    params: dict[str, str]
    args: ArgsType

    def __init__(self, args):
        self.params = {}
        self.args = args


class Context(request.CiocRequestMixin, ContextBase):
    @reify
    def config(self) -> dict:
        return config.get_config(self.args.configfile, const._app_name or "")


class fakerequest:
    def __init__(self, config):
        self.config = config
        config["mailer.manager"] = "immediate"

    class dboptions:
        TrainingMode = False
        NoEmail = False
        DefaultEmailCIC = None
        DefaultEmailVOL = None
        DefaultEmailNameCIC = None
        DefaultEmailNameVOL = None

    class pageinfo:
        DbArea = const.DM_CIC


class FileWriteDetector:
    __dirty: bool
    __obj: t.TextIO

    def __init__(self, obj):
        self.__obj = obj
        self.__dirty = False

    def is_dirty(self) -> bool:
        return self.__dirty

    def write(self, string: str) -> t.Optional[int]:
        self.__dirty = True
        return self.__obj.write(string)

    def __getattr__(self, key: str):
        return getattr(self.__obj, key)


io.TextIOBase.register(FileWriteDetector)


class DefaultClass:
    def __getitem__(self, parameters):
        if not isinstance(parameters, tuple):
            parameters = (parameters,)

        return t.Union[(type(DEFAULT),) + parameters]

    def __repr__(self):
        return "unset_value"


DEFAULT = OptionalValue = DefaultClass()
del DefaultClass


@t.overload
def get_config_item(args: ArgsType, key: str, default: str) -> str: ...


@t.overload
def get_config_item(args: ArgsType, key: str, default: None) -> t.Optional[str]: ...


@t.overload
def get_config_item(args: ArgsType, key: str) -> str: ...


def get_config_item(
    args: ArgsType, key: str, default: OptionalValue[str, None] = DEFAULT
):
    config_prefix = args.config_prefix
    config = args.config
    if default is DEFAULT:
        return config.get(config_prefix + key, config[key])

    return args.config.get(config_prefix + key, config.get(key, default))


def email_log(
    args: ArgsType,
    outputstream: io.StringIO,
    is_error: bool,
    config_base: str,
    *,
    to: t.Optional[str] = None,
):
    try:
        author = get_config_item(
            args, f"{config_base}_notify_from", const.CIOC_ADMIN_EMAIL
        )
        _to = [
            x.strip()
            for x in (
                to
                or get_config_item(
                    args, f"{config_base}_notify_emails", const.CIOC_ADMIN_EMAIL
                )
                or ""
            ).split(",")
        ]
        email.send_email(
            fakerequest(args.config),
            author,
            _to,
            "Import from iCarol%s" % (" -- ERRORS!" if is_error else ""),
            outputstream.getvalue().replace("\r", "").replace("\n", "\r\n"),
        )
    except Exception as e:
        raise Exception(
            f"unable to send email log: {outputstream.getvalue()},{str(e)}",
            e,
        )


def get_bulk_connection(language) -> pyodbc.Connection:
    dts = dts_file_template % const._app_name
    with open(dts, "rb") as dts_file:
        # the [1:] is there to drop the bom from the start of the file
        connstr = dts_file.read().decode("utf_16").replace("\r", "").split("\n")

    line = ""
    for line in connstr:
        if line and line.startswith((";", "[")):
            continue

        break

    assert line

    settings = dict(x.split("=") for x in line.split(";"))
    settings = [
        ("Driver", "{ODBC Driver 17 for SQL Server}"),
        ("Server", settings["Data Source"]),
        ("Database", settings["Initial Catalog"]),
        ("UID", settings["User ID"]),
        ("PWD", settings["Password"]),
    ]
    connstr = ";".join("=".join(x) for x in settings)

    try:
        conn = pyodbc.connect(connstr, autocommit=True, unicode_results=True)
        conn.execute("SET LANGUAGE '" + language + "'")
    except pyodbc.Error as e:
        raise ConnectionError(e)

    return conn
