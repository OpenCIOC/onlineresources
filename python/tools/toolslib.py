import io
import os
import sys
import typing as t
from dataclasses import dataclass

from pyramid.decorator import reify

try:
    import cioc  # NOQA
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import constants as const, request, config, email

const.update_cache_values()


@dataclass
class ArgsType:
    configfile: str
    config_prefix: str = ""
    test: bool = False
    email: bool = False
    config: t.Optional[dict] = None


class ContextBase(object):
    params: dict[str, str]
    args: ArgsType

    def __init__(self, args):
        self.params = {}
        self.args = args


class Context(request.CiocRequestMixin, ContextBase):
    @reify
    def config(self) -> dict:
        return config.get_config(self.args.configfile, const._app_name)


class fakerequest(object):
    def __init__(self, config):
        self.config = config
        config["mailer.manager"] = "immediate"

    class dboptions(object):
        TrainingMode = False
        NoEmail = False
        DefaultEmailCIC = None
        DefaultEmailVOL = None
        DefaultEmailNameCIC = None
        DefaultEmailNameVOL = None

    class pageinfo(object):
        DbArea = const.DM_CIC


class FileWriteDetector(object):
    __dirty: bool
    __obj: t.TextIO

    def __init__(self, obj):
        self.__obj = obj
        self.__dirty = False

    def is_dirty(self) -> bool:
        return self.__dirty

    def write(self, string: str) -> None:
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


def get_config_item(
    args: ArgsType, key: str, default: OptionalValue[str, None] = DEFAULT
) -> t.Optional[str]:
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
        to = [
            x.strip()
            for x in (
                to
                or get_config_item(
                    args, f"{config_base}_notify_emails", const.CIOC_ADMIN_EMAIL
                )
            ).split(",")
        ]
        email.send_email(
            fakerequest(args.config),
            author,
            to,
            "Import from iCarol%s" % (" -- ERRORS!" if is_error else ""),
            outputstream.getvalue().replace("\r", "").replace("\n", "\r\n"),
        )
    except Exception as e:
        raise Exception(
            "unable to send email log: {},{}".format(outputstream.getvalue(), str(e)),
            e,
        )
