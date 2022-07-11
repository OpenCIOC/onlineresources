import sys
import os
import win32api
from markupsafe import Markup


def get_base_prefix_compat():
    return (
        getattr(sys, "base_prefix", None)
        or getattr(sys, "real_prefix", None)
        or sys.prefix
    )


def get_system_version_info():
    pth = os.path.join(os.path.dirname(win32api.__file__), "..")
    pywin32ver = open(os.path.join(pth, "pywin32.version.txt")).read().strip()
    base_prefix = get_base_prefix_compat()
    virtualenv_prefix = sys.prefix
    if sys.prefix == base_prefix:
        virtualenv_prefix = "No virtualenv used"

    return [
        ("Python Version", sys.version),
        ("pywin32 Version", pywin32ver),
        ("Base Python Location", base_prefix),
        ("Virtualenv Location", virtualenv_prefix),
    ]


def get_system_version_info_html():
    item_tmpl = Markup("<b>%s</b>: %s")

    return Markup("<br>").join(item_tmpl % x for x in get_system_version_info())
