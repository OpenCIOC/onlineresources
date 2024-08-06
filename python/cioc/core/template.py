# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
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


# stdlib
import os
import re
import posixpath
import itertools
from datetime import datetime, timedelta
import time
import json
import glob

from xml.etree import ElementTree as ET
from urllib.parse import urlparse, parse_qs, urlunparse
from urllib.parse import urlencode
from functools import partial

import logging

# 3rd party

from markupsafe import escape, Markup
from pyramid.httpexceptions import HTTPNotFound
from pyramid.path import caller_package
from pyramid.response import Response
from pyramid.view import view_config

# this app
import cioc.core.constants as const
import cioc.core.syslanguage as syslanguage
import cioc.core.jquiicons as jquiicons
import cioc.core.clienttracker as clienttracker
from cioc.core.i18n import gettext, ngettext, format_date
from cioc.core.security import sanitize_html_passvars
from cioc.core.streamingrenderer import (
    StreamingMakoRendererFactory,
    PkgResourceTemplateLookup,
)
from cioc.core.utils import read_file


log = logging.getLogger(__name__)

_template_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "templates"))
_system_layout_dir = os.path.abspath(os.path.join(_template_dir, "layouts"))
_renderer_factories = {}
_renderer_settings = {
    ".mak": {
        "directories": [_template_dir],
        "default_filters": ["escape_silent"],
        "imports": ["from markupsafe import escape_silent"],
        "filesystem_checks": True,
    },
}


class FakeRendererHelper:
    def __init__(self, name, package=None):
        self.name = name
        self.package = package


def create_renderer_factories():
    for ext, settings in _renderer_settings.items():
        lookup = PkgResourceTemplateLookup(**settings)
        factory = StreamingMakoRendererFactory()
        factory.lookup = lookup
        _renderer_factories[ext] = factory


create_renderer_factories()


def get_renderer(template_name, package=None):
    if package is None:
        package = caller_package()

    rtype = os.path.splitext(template_name)[1]
    factory = _renderer_factories.get(rtype)
    if factory is None:
        raise ValueError(f"No such renderer factory {rtype}")

    info = FakeRendererHelper(template_name, package)
    return factory(info)


def render_template(template_name, value, system_values, request, package=None):
    if package is None:
        package = caller_package()
    renderer = get_renderer(template_name, package)
    if system_values is None:
        system_values = {
            "view": None,
            "renderer_name": template_name,  # b/c
            "renderer_info": FakeRendererHelper(package),
            "context": getattr(request, "context", None),
            "request": request,
            "req": request,
        }
    return renderer(value, system_values)


def get_view_template_info(request):
    dboptions = request.dboptions
    viewdata = request.viewdata

    DbArea = request.pageinfo.DbArea
    print_mode = request.viewdata.PrintMode
    if DbArea == const.DM_GLOBAL:
        if print_mode and dboptions.DefaultPrintTemplate:
            template_id = dboptions.DefaultPrintTemplate
        else:
            template_id = -1
    else:
        vd_dom = viewdata.cic if DbArea == const.DM_CIC else viewdata.vol
        if print_mode and vd_dom.PrintTemplate:
            template_id = vd_dom.PrintTemplate
        else:
            request.viewdata.PrintMode = False
            template_id = vd_dom.Template

    with request.connmgr.get_connection() as conn:
        # XXX const.DM_GLOBAL needs to grab default template
        preview_template_id = request.params.get("PreviewTemplateID")
        if preview_template_id:
            try:
                preview_template_id = int(preview_template_id)
            except ValueError:
                preview_template_id = None

        cursor = conn.execute(
            "EXEC sp_GBL_Template_s ?, ?, ?",
            request.MemberID,
            template_id,
            preview_template_id,
        )

        template_values = cursor.fetchone()

        cursor.nextset()

        menu_items = cursor.fetchall()

        cursor.close()

    template_values = dict(
        zip((d[0] for d in template_values.cursor_description), template_values)
    )

    template_urls = (template_values["TemplateCSSLayoutURLs"] or "").split(";")
    template_urls.extend(glob.glob(os.path.join(const._sass_dir, "*.scss")))
    template_urls.extend(
        glob.glob(os.path.join(const._sass_dir, "bootstrap", "*.scss"))
    )
    template_urls.extend(
        glob.glob(os.path.join(const._sass_dir, "bootstrap", "mixins", "*.scss"))
    )
    template_urls.extend(glob.glob(os.path.join(const._sass_dir, "jasny", "*.scss")))
    template_urls.extend(glob.glob(os.path.join(_template_dir, "jqueryui", "*.css")))

    version_dates = [
        int(os.path.getmtime(os.path.join(_system_layout_dir, x)) * 100)
        for x in template_urls
    ]
    version_dates.append(
        int(time.mktime(template_values["VersionDate"].timetuple()) * 100)
    )

    template_values["VersionDate"] = max(version_dates)
    template_values["menus"] = {
        k: list(g) for k, g in itertools.groupby(menu_items, lambda x: x.MenuType)
    }

    request.template_values = template_values


class RenderInfo:
    def __init__(
        self,
        request,
        page_name,
        doc_title,
        no_cache,
        no_index,
        print_table,
        add_to_header="",
        focus="",
        show_message=False,
    ):
        self.request = request
        self.page_name = page_name
        self.doc_title = doc_title
        self.no_cache = no_cache
        self.no_index = no_index
        self.print_table = print_table
        self.add_to_header = add_to_header
        self.focus = focus

        self.show_message = show_message
        self.list_script_loaded = False

        session = self.request.session

        self.ct_launched = clienttracker.has_been_launched(request)
        list_vals = session.get(request.pageinfo.DbAreaS + "RecordList") or ""
        if list_vals:
            list_vals = list_vals.split(",")
            list_vals = json.dumps(list_vals)
        else:
            list_vals = "[]"

        self.my_list_values = list_vals

        # session detection
        self.has_session = session.get("session_test") == "ok"
        session["session_test"] = "ok"

        self.ct_list_mode = False

        get_view_template_info(request)

    def render_header(self):
        namespace = self.get_html_template_namespace()
        return render_template("header.mak", namespace, None, self.request)

    def render_footer(self, bottomjs=None):
        namespace = self.get_html_template_namespace()
        if bottomjs:
            namespace["bottomjs"] = bottomjs
        return render_template("footer.mak", namespace, None, self.request)

    def get_html_template_namespace(self):
        def _(s, *args, **kwargs):
            return gettext(s, self.request, *args, **kwargs)

        def _format_date(d, if_none=None):
            if d is None and if_none is not None:
                return if_none
            return format_date(d, self.request)

        def _ngettext(s, p, n, *args, **kwargs):
            return ngettext(s, p, n, self.request, *args, **kwargs)

        namespace = {
            "request": self.request,
            "_": _,
            "ngettext": _ngettext,
            "renderinfo": self,
            "const": const,
            "makeLayoutHeader": LayoutHeader(self.request, self),
            "makeLayoutFooter": LayoutFooter(self.request, self),
            "format_date": _format_date,
            "active_cultures": syslanguage.active_cultures(),
            "culture_map": syslanguage.culture_map(),
            "sanitize_html": sanitize_html,
        }

        if hasattr(self.request, "model_state"):
            namespace["model_state"] = self.request.model_state
            namespace["renderer"] = self.request.model_state.renderer

        return namespace


def _set_long_expires(response):
    expire = datetime.utcnow() + timedelta(365 * 10)  # ten years
    response.headers["Expires"] = expire.strftime("%a, %d %b %Y %H:%M:%S GMT")
    response.headers["Cache-Control"] = "public"


sass = None


@view_config(route_name="template_css")
def render_css(request):
    """Pyramid view to render the dynamic css for a design template"""

    global sass
    if sass is None:
        import sass

    template_info = get_css_template_info(request)
    template_values = template_info["template_values"]

    if not template_values:
        return HTTPNotFound()

    css_values = fixup_css_values(template_values)
    if template_values["Background"] is not None:
        css_values["Background"] = '"%s"' % template_values["Background"]

    base_template = template_values["SASSOveride"] or ""
    base_template += "".join(
        "$" + k + ":" + (v or "null") + " !default;\n" for k, v in css_values.items()
    )
    base_template += '@import "defaults";\n'

    # need to split css into 2 files because otherwise we are too big for IE9 and under
    if request.matchdict["which"] == "basic":
        base_template += '@import "bootstrap";\n'

        jqui_css = inline_css_file(
            os.path.join(_template_dir, "jqueryui", "jquery.ui.all.css")
        )
        css = apply_css_values(jqui_css, css_values)

        css = base_template + css
    elif request.matchdict["which"] == "printlist":
        css = base_template + '@import "ciocprintlist";\n'

    else:
        # theme
        base_template += (
            '@import "ciocthemesetup";\n @import "ciocbasic";\n@import "theme";\n'
        )
        css = apply_css_values(template_info["layout_css"] or "", css_values)
        css = base_template + css

    args = {"string": css, "include_paths": [const._sass_dir]}

    if not request.matchdict["debug"]:
        args["output_style"] = "compressed"
    else:
        args["source_comments"] = False

    css = sass.compile(**args)

    response = Response(css.encode("utf-8"), content_type="text/css")

    _set_long_expires(response)

    return response


_jqui_icon = jquiicons.jQueryUIIcons(
    os.path.join(_template_dir, "jqueryui", "images", "ui-icons_222222_256x240.png")
)


@view_config(route_name="jquery_icons")
def render_icons(request):
    """Pyramid view to render PNG for icons in a particular colour"""
    colour = request.matchdict["colour"]
    image = _jqui_icon.get_icon_string(colour)

    response = Response(image, content_type="image/png")

    _set_long_expires(response)

    return response


def get_css_template_info(request):
    """get the css template values from the database"""
    template_id = int(request.matchdict["templateid"])
    with request.connmgr.get_connection() as conn:
        cursor = conn.execute(
            "EXEC sp_GBL_Template_s_css ?, ?", request.dboptions.MemberID, template_id
        )
        values = cursor.fetchone()

        cursor.nextset()

        layout_css = cursor.fetchall()
        cursor.close()

    for layout in layout_css:
        if layout.SystemLayout and layout.LayoutCSSURL:
            try:
                layout.LayoutCSS = read_file(
                    os.path.join(_system_layout_dir, layout.LayoutCSSURL)
                )
            except OSError:
                log.error("Error Loading template css")

    layout_css = "\n".join(x.LayoutCSS for x in layout_css) + (values.ExtraCSS or "")

    return {
        "template_values": dict(zip((d[0] for d in values.cursor_description), values))
        if values
        else None,
        "layout_css": layout_css,
    }


_jquery_sections = [
    "Content",
    "Header",
    "Default",
    "Hover",
    "Active",
    "Highlight",
    "Error",
]
_jquery_defaults = [
    (x % y, "")
    for x in ["bgImgUrl%s", "bg%sXPos", "bg%sYPos", "bg%sRepeat"]
    for y in _jquery_sections + ["Overlay", "Shadow"]
] + [
    ("ffDefault", "inherit"),
    ("fsDefault", "1em"),
    ("bgColorError", "inherit"),
]
_jquery_prefixes = ["fc", "bgColor", "borderColor", "iconColor"]
_jquery_variables = [p + s for s in _jquery_sections for p in _jquery_prefixes] + [
    "fsDefault",
    "cornerRadius",
]

_cioc_sections = ["Title", "Footer", "Menu", "Info"]
_cioc_variables_like_jquery = [p + s for p in _jquery_prefixes for s in _cioc_sections]
_cioc_variables = [
    "Background",
    "BackgroundColour",
    "bgColorLogo",
    "FontFamily",
    "FontColour",
    "FieldLabelColour",
    "MenuFontColour",
    "MenuBgColour",
    "TitleFontColour",
    "TitleBgColour",
    "LinkColour",
    "ALinkColour",
    "VLinkColour",
    "AlertColour",
    "bgColorInfo",
    "fcInfo",
    "fcLabel",
    "BannerRepeat",
    "BannerHeight",
    "ContainerFluid",
    "ContainerContrast",
    "SmallTitle",
]
_all_variables = frozenset(
    _jquery_variables + _cioc_variables + _cioc_variables_like_jquery
)


def fixup_css_values(values):
    """construct required jquery ui values from those passed in value dictionary"""

    # take a copy so that we don't modify the original dictionary
    retval = dict(_jquery_defaults)
    retval.update(
        (k, str(v) if v is not None else "null")
        for k, v in values.items()
        if k in _all_variables
    )

    icon_template = "url(/styles/d/%d/images/ui-icons_%s_256x240.png)"
    icon_update = int(_jqui_icon.get_mtime())

    icon_values = (
        (section, (retval["iconColor" + section] or "000000").replace("#", ""))
        for section in _jquery_sections + _cioc_sections
    )
    retval.update(
        ("icons" + section, icon_template % (icon_update, colour))
        for (section, colour) in icon_values
    )

    if retval["BannerHeight"] != "null":
        retval["BannerHeight"] = retval["BannerHeight"] + "px"

    return retval


# CSS Functions
_css_values_re = re.compile(r"\s+\S+\/\*\{([^\\*\/]+)\}\*\/")


def apply_css_values(css, values):
    """Apply template values as exist in jQueryUI 1.8 base/theme.css file"""
    values = {k.upper(): k for k in values.keys()}

    def repl(matchobj):
        key = matchobj.group(1).upper()
        if key in values:
            return " $%s" % values[key]

        return matchobj.group(0)

    return _css_values_re.sub(repl, css)


def inline_css_file(fname):
    """inline any imported css files from file given in fname"""
    out = []
    _inline_css_file(os.path.dirname(fname), out, fname)

    return "".join(out)


def compress_css(body):
    """basic css minifier that works with css hacks"""
    body = body.replace("\n", " ")
    body = body.replace("\r", " ")
    body = body.replace("\t", " ")
    body = re.sub(r"/\*.+?\*/", "", body)
    body = re.sub(r"/\s\s+/", " ", body)
    body = re.sub(r"\s*({|}|\[|\]|=|~|\+|>|\||;|:|,)\s*", r"\1", body)

    return body.strip()


_import_re = re.compile(r'@import\s+(?:url\()?"([^"]+)"\)?;')
_url_re = re.compile(r'url\(["\']?([^"\'\)]+)["\']?\)')


def _inline_css_file(root_dir, out, fname, relative="."):
    """recurse into file, inline any imports and fix up url() directives"""
    input = open(os.path.join(root_dir, relative, fname))
    for line in input:
        if relative != ".":
            line = _url_re.sub(r'url("' + relative + r'/\1")', line)

        while True:
            match = _import_re.search(line)
            if match:
                out.append(line[: match.start()])
                line = line[match.end() :]
                req_fname = match.group(1)

                # check url safety
                req_fname = req_fname.replace("\\", "/")
                if "://" in req_fname or ".." in req_fname or req_fname.startswith("/"):
                    # safety: parent directory or or absolute url
                    # XXX allow '..' if it does not go past root directory
                    out.append(match.group(0))
                else:
                    req_fname = posixpath.normpath(posixpath.join(relative, req_fname))
                    rel = posixpath.dirname(req_fname) or "."
                    _inline_css_file(root_dir, out, posixpath.basename(req_fname), rel)
            else:
                break

        if line:
            out.append(line)


def _html_operator_for(matchobj, key, inner, val, values):
    if not val or not hasattr(val, "__iter__"):
        return ""

    retval = []
    val = list(val)
    total = len(val)

    for count, ns in enumerate(val):
        new_values = values.copy()
        new_values.update(ns)
        new_values["COUNT"] = count
        new_values["TOTAL"] = total

        retval.append(apply_html_values(inner, new_values))

    return "".join(retval)


def _html_operator_if(matchobj, key, inner, val, values):
    if val:
        return apply_html_values(inner, values)
    return ""


def _html_operator_ifany(matchobj, key, inner, val, values):
    if any(val):
        return apply_html_values(inner, values)
    return ""


def _html_operator_ifall(matchobj, key, inner, val, values):
    if all(val):
        return apply_html_values(inner, values)
    return ""


def _html_operator_ifnot(matchobj, key, inner, val, values):
    if not val:
        return apply_html_values(inner, values)
    return ""


def _html_operator_ifnotany(matchobj, key, inner, val, values):
    if not any(val):
        return apply_html_values(inner, values)
    return ""


def _html_operator_ifnotall(matchobj, key, inner, val, values):
    if not all(val):
        return apply_html_values(inner, values)
    return ""


def _html_operator_fn(matchobj, key, inner, val, values):
    inner = apply_html_values(inner, values)
    if not callable(val):
        return inner

    return val(inner)


_html_many_operator = {"IFANY", "IFALL", "IFNOTANY", "IFNOTALL"}
_html_operator = {
    "IF": _html_operator_if,
    "FOR": _html_operator_for,
    "FN": _html_operator_fn,
    "IFNOT": _html_operator_ifnot,
    "IFANY": _html_operator_ifany,
    "IFALL": _html_operator_ifall,
    "IFNOTANY": _html_operator_ifnotany,
    "IFNOTALL": _html_operator_ifnotall,
}

_html_block_re = re.compile(
    r"\[(IF|FOR|FN|IFNOT|IFANY|IFALL|IFNOTANY|IFNOTALL):([^]\s]+)\](.*?)\[END\1:\2\]",
    re.I | re.DOTALL,
)
_html_values_re = re.compile(r"\[([^]\s]+)\]")


def apply_html_values(text, values):
    values = {k.upper(): v for k, v in values.items()}

    def block_repl(matchobj):
        oper = matchobj.group(1).upper()
        key = matchobj.group(2).upper()
        inner = matchobj.group(3)

        oper_fn = _html_operator.get(oper)
        if not oper_fn:
            return matchobj.group(0)

        if oper in _html_many_operator:
            keys = key.split(",")
            if not all(k in values for k in keys):
                return matchobj.group(0)

            vals = []
            for key in keys:
                val = values[key]
                if callable(val):
                    val = values[key] = val()
                vals.append(val)

            val = vals
        else:
            if key not in values:
                return matchobj.group(0)

            val = values[key]
            if oper != "FN" and callable(val):
                val = values[key] = val()

        return oper_fn(matchobj, key, inner, val, values)

    def repl(matchobj):
        key = matchobj.group(1).upper()
        if key in values:
            val = values[key]
            if callable(val):
                val = values[key] = val()
            return str(val)

        return matchobj.group(0)

    retval = _html_block_re.sub(block_repl, text)
    return _html_values_re.sub(repl, retval)


def row_to_dict(row):
    return dict(zip((d[0] for d in row.cursor_description), row))


def encode_link_values(row):
    if not isinstance(row, dict):
        row = row_to_dict(row)
    row["Link"] = escape(row["Link"])
    return row


_domain_root = {const.DM_CIC: "", const.DM_VOL: "volunteer/"}


class LayoutHeader:
    """utility class to render header portion of template from layout/template settings"""

    def __init__(self, request, renderinfo):
        self.request = request
        self.renderinfo = renderinfo

    def __call__(self):
        request = self.request
        passvars = request.passvars
        pageinfo = request.pageinfo
        dboptions = request.dboptions

        namespace = {}

        template_values = self.request.template_values
        header_layout_template = template_values["HeaderLayoutHTML"]
        if (
            template_values["HeaderSystemLayout"]
            and template_values["HeaderLayoutHTMLURL"]
        ):
            header_layout_template = read_file(
                os.path.join(_system_layout_dir, template_values["HeaderLayoutHTMLURL"])
            )

        if not header_layout_template:
            return ""

        site_menu = []
        new_search_link = "/"
        suggest_link = None

        PathToStart = pageinfo.PathToStart

        menu_groups = {}
        for key, group in itertools.groupby(
            template_values["menus"].get("header", []), lambda x: x.MenuGroup
        ):
            menu_groups[key] = list(group)

        if len(list(menu_groups.keys())) >= 3 and request.user:
            search_menu = menu_groups.setdefault(4, [])
        else:
            search_menu = site_menu

        domain_root = _domain_root.get(pageinfo.DbArea)
        vd_dom = None
        if domain_root is not None:
            vd_dom = (
                request.viewdata.cic
                if pageinfo.DbArea == const.DM_CIC
                else request.viewdata.vol
            )
            if template_values["HeaderSearchLink"]:
                icon = ""
                if template_values["HeaderSearchIcon"]:
                    if request.user:
                        icon = '<span class="glyphicon glyphicon-menu-hamburger" aria-hidden="true"></span> '
                    else:
                        icon = '<span class="glyphicon glyphicon-search" aria-hidden="true"></span> '
                search_menu.append(
                    {
                        "Link": passvars.makeLink("~/" + domain_root),
                        "Display": icon
                        + (
                            gettext("Main Menu", request)
                            if request.user
                            else gettext("Search", request)
                        ),
                    }
                )

            if template_values["HeaderSuggestLink"]:
                icon = ""
                if template_values["HeaderSuggestIcon"]:
                    if pageinfo.DbArea == const.DM_CIC:
                        icon = '<span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span> '
                    else:
                        icon = '<span class="glyphicon glyphicon-pushpin" aria-hidden="true"></span> '

                if pageinfo.DbArea == const.DM_VOL:
                    label = gettext("Suggest Opportunity")
                else:
                    label = gettext("Suggest Record", request)
                site_menu.append(
                    {
                        "Link": passvars.makeLink(
                            PathToStart + domain_root + "feedback.asp"
                        ),
                        "Display": icon + label,
                    }
                )

            if request.user and request.user.dom:
                if not (
                    request.pageinfo.DbArea == const.DM_CIC and not dboptions.UseCIC
                ):
                    search_menu.append(
                        {
                            "Link": passvars.makeLink(
                                "".join(
                                    (pageinfo.PathToStart, domain_root, "advsrch.asp")
                                )
                            ),
                            "Display": gettext("Advanced Search", request),
                        }
                    )
                search_menu.append(
                    {
                        "Link": passvars.makeLink(
                            "".join((pageinfo.PathToStart, domain_root, "recentsearch"))
                        ),
                        "Display": gettext("Recent Searches", request),
                    }
                )

            if pageinfo.DbArea != const.DM_GLOBAL:
                new_search_link = passvars.makeLink(pageinfo.PathToStart + domain_root)
                suggest_link = passvars.makeLink(
                    pageinfo.PathToStart + domain_root + "feedback.asp"
                )

        site_menu.extend(encode_link_values(x) for x in menu_groups.get(None, []))

        site_bar_menu = ""
        site_bar_items = None
        view_info_text = None
        help_link = None
        if (
            (
                "SITE_BAR_MENU" in header_layout_template
                or "SITE_BAR_ITEMS" in header_layout_template
            )
            and request.user
            and not request.viewdata.PrintMode
        ):
            site_bar_menu = []
            if vd_dom:
                view_info_text = "{}{} {}".format(
                    gettext("View", request),
                    gettext(":", request),
                    vd_dom.ViewName,
                )
                site_bar_menu.append("<li><a>%s</a></li>" % view_info_text)

            menu_items = []
            if domain_root is None:  # const.DM_GLOBAL
                menu_items.append(
                    (passvars.makeLink("~/"), gettext("CIC Menu", request))
                )
                if dboptions.UseVOL:
                    menu_items.append(
                        (
                            passvars.makeLink("~/volunteer/"),
                            gettext("Volunteer Menu", request),
                        )
                    )

                if request.user.SuperUser:
                    icon = '<span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> '
                    menu_items.append(
                        (
                            passvars.makeLinkAdmin("setup.asp"),
                            icon + gettext("Setup", request),
                        )
                    )
            else:
                user_dom = request.user.dom
                if pageinfo.DbArea == const.DM_VOL:
                    menu_items.append(
                        (passvars.makeLink("~/"), gettext("CIC Menu", request))
                    )

                if (
                    user_dom.CanEditRecord
                    or user_dom.CanAddRecord
                    or user_dom.FeedbackAlert
                ):
                    icon = '<span class="glyphicon glyphicon-comment" aria-hidden="true"></span> '
                    menu_items.append(
                        (
                            passvars.makeLink(
                                PathToStart + domain_root + "revfeedback.asp"
                            ),
                            icon + gettext("Feedback", request),
                        )
                    )

                icon = (
                    '<span class="glyphicon glyphicon-file" aria-hidden="true"></span> '
                )
                if user_dom.CanAddRecord:
                    if pageinfo.DbArea == const.DM_VOL:
                        label = gettext("New Opportunity")
                    else:
                        label = gettext("New Record", request)

                    menu_items.append(
                        (
                            passvars.makeLink(
                                PathToStart + domain_root + "entryform.asp"
                            ),
                            icon + label,
                        )
                    )

                else:
                    if pageinfo.DbArea == const.DM_VOL:
                        label = gettext("Suggest Opportunity")
                    else:
                        label = gettext("Suggest Record", request)

                    menu_items.append(
                        (
                            passvars.makeLink(
                                PathToStart + domain_root + "feedback.asp"
                            ),
                            icon + label,
                        )
                    )

            reminders = 0
            past_due = 0
            if request.user.Reminders:
                try:
                    xml = ET.fromstring(request.user.Reminders.encode("utf-8"))
                except Exception:
                    xml = {}

                try:
                    reminders = int(xml.get("Total") or "0", 10)
                except ValueError:
                    reminders = 0

                try:
                    past_due = int(xml.get("PastDue") or "0", 10)
                except ValueError:
                    past_due = 0

            # log.debug('Notice Count, past_due, reminders: %s, %s, %s', request.user.NoticeCount, past_due, reminders)
            if request.user.NoticeCount or past_due:
                icon = Markup(
                    '<span class="ui-state-error" style="background-color: transparent; border: none;"><span class="ui-icon ui-icon-alert" style="display: inline-block; background-color: transparent; border: none;">%s</span></span> '
                ) % (gettext("Some reminders are past due or require action.", request))
            elif reminders:
                icon = Markup(
                    '<img src="'
                    + request.pageinfo.PathToStart
                    + 'images/remind.gif" style="vertical-align: text-top"> '
                )
            else:
                icon = ""

            menu_items.append(
                (passvars.makeLink("~/reminders"), gettext("Reminders", request), icon)
            )

            icon = '<span class="glyphicon glyphicon-user" aria-hidden="true"></span> '
            menu_items.append(
                (passvars.makeLinkAdmin("account.asp"), icon + request.user.Login)
            )

            icon = (
                '<span class="glyphicon glyphicon-log-out" aria-hidden="true"></span> '
            )
            menu_items.append(
                (
                    passvars.makeLink(PathToStart + "logout.asp"),
                    icon + gettext("Logout", request),
                )
            )

            names = ["LINK", "DISPLAY", "NOTICE"]
            site_bar_items = [
                dict(
                    map(
                        lambda y, z: (y, z),
                        names,
                        (escape(x[0]), "".join(reversed(x[1:]))),
                    )
                )
                for x in menu_items
            ]
            item_tmpl = '<li><a href="%(LINK)s">%(DISPLAY)s</a></li>'
            site_bar_menu.extend(
                item_tmpl % {"LINK": x["LINK"], "DISPLAY": x["DISPLAY"]}
                for x in site_bar_items
            )
            if pageinfo.HasHelp:
                icon = '<span class="glyphicon glyphicon-question-sign" aria-hidden="true"></span> '
                help_link = passvars.makeLinkAdmin(
                    "pagehelp", {"Page": pageinfo.ThisPageFull}
                )
                site_bar_menu.append(
                    '<li><a href="%s" target="pHelp" onClick="openWinL(\'%s\', \'pHelp\')">%s</a></li>'
                    % (
                        escape(help_link),
                        escape(help_link.replace("'", "\\'")),
                        escape(gettext("Page Help", request)),
                    )
                )
                help_link = escape(help_link)

            site_bar_menu = "".join(site_bar_menu).join(("<ul>", "</ul>"))

        mylist = ""
        if domain_root is not None:
            mylist = (
                '<a id="myListLink" href="%s" class="ListUI" style="display:none;">'
                '<span aria-hidden="true" class="glyphicon glyphicon-list-alt"></span> %s'
                ' (<span id="myListCount"></span>)</a>'
            ) % (
                passvars.makeLink(
                    "".join((pageinfo.PathToStart, domain_root, "viewlist.asp"))
                ),
                gettext("View List", request),
            )

        container_fluid = template_values["ContainerFluid"]
        container_contrast = template_values["ContainerContrast"]
        small_title = template_values["SmallTitle"]

        logolink = template_values["LogoLink"]
        logo = template_values["Logo"]
        logomobile = template_values["LogoMobile"]
        banner = template_values["Banner"]
        nologo = not template_values["LogoMobile"] and not template_values["Logo"]
        anylogo = not not (logo or logomobile)
        logo_alt_text = escape(
            template_values["LogoAltText"] or template_values["LogoLink"]
        )
        logo_alt_text = re.sub(r"https?:\/\/(www\.)?", "", logo_alt_text or "")

        header_notice = template_values["HeaderNotice"]
        header_notice_mobile = template_values["HeaderNoticeMobile"]

        contact_email = template_values["Email"]
        contact_email_label = None
        if contact_email:
            if "@" in contact_email:
                contact_email_label = contact_email
                contact_email = "mailto:" + contact_email
            else:
                contact_email_label = gettext("Email", request)

        namespace = template_values.copy()
        namespace.update(
            {
                "CONTAINER_FLUID": container_fluid,
                "CONTAINER_CONTRAST": container_contrast,
                "SMALL_TITLE": small_title,
                "HELP_LINK": help_link,
                "HOME": gettext("Home", request),
                "LOGO": logo if logo else None,
                "LOGOLINK": logolink if logolink else None,
                "LOGOMOBILE": logomobile if logomobile else None,
                "LOGO_ALT_TEXT_ORIG": template_values["LogoAltText"]
                if not logolink
                else None,
                "LOGO_ALT_TEXT": logo_alt_text,
                "HAS_LOGO": anylogo,
                "NO_LOGO": nologo,
                "HEADER_NOTICE": header_notice,
                "HEADER_NOTICE_MOBILE": header_notice_mobile,
                "CONTACT_EMAIL": contact_email,
                "CONTACT_EMAIL_LABEL": contact_email_label,
                "CONTACT_US_TEXT": gettext("Contact Us", request),
                "MY_LIST": mylist,
                "NEW_SEARCH": new_search_link,
                "NOT_PRINT_MODE": not request.viewdata.PrintMode,
                "PAGE_HELP_TITLE": gettext("Page Help", request),
                "PAGE_NAME": self.renderinfo.page_name,
                "PAGE_TITLE": '<span id="page_name">%s</span>'
                % self.renderinfo.page_name,
                "PRINT_MODE": request.viewdata.PrintMode,
                "QUICK_BAR": not not (request.user and (site_menu or site_bar_menu)),
                "QUICK_LINKS_TITLE": gettext("Quick Links:", request),
                "SITE_BAR_ITEMS": site_bar_items,
                "SITE_BAR_MENU": site_bar_menu,
                "SITE_MENU": site_menu,
                "SITE_MENU_GROUP_1": [
                    encode_link_values(x) for x in menu_groups.get(1, [])
                ],
                "SITE_MENU_GROUP_2": [
                    encode_link_values(x) for x in menu_groups.get(2, [])
                ],
                "SITE_MENU_GROUP_3": [
                    encode_link_values(x) for x in menu_groups.get(3, [])
                ],
                "SITE_MENU_GROUP_4": [
                    encode_link_values(x) for x in menu_groups.get(4, [])
                ],
                "HEADERGROUP4": gettext("Search", request),
                "SUGGEST_LINK": suggest_link,
                "VIEW_NAME": view_info_text,
                "VIEW_TITLE": pageinfo.DbAreaTitle,
                "VIEW_TAG_LINE": vd_dom and vd_dom.TagLine,
                "CIC_SEARCH_TIPS": passvars.makeLink("~/search_help.asp"),
                "VOL_SEARCH_TIPS": passvars.makeLink("~/volunteer/search_help.asp"),
                "NOT_LOGGED_IN": not request.user,
                "MAKE_LINK": make_linkify_fn(request),
                "TOGGLE_MENU_TEXT": gettext("Toggle Menu", request),
            }
        )

        return apply_html_values(header_layout_template, namespace)


class LayoutFooter:
    """utility class to render footer portion of template from layout/template settings"""

    def __init__(self, request, renderinfo):
        self.request = request
        self.renderinfo = renderinfo
        self.section = "Footer"

    def __call__(self):
        request = self.request

        pageinfo = request.pageinfo
        passvars = request.passvars

        template_values = self.request.template_values
        layout_template = template_values["FooterLayoutHTML"]

        if (
            template_values["FooterSystemLayout"]
            and template_values["FooterLayoutHTMLURL"]
        ):
            layout_template = read_file(
                os.path.join(_system_layout_dir, template_values["FooterLayoutHTMLURL"])
            )
        if not layout_template:
            return ""

        menu_groups = {}
        for key, group in itertools.groupby(
            template_values["menus"].get("footer", []), lambda x: x.MenuGroup
        ):
            menu_groups[key] = list(group)

        container_fluid = template_values["ContainerFluid"]
        container_contrast = template_values["ContainerContrast"]

        footer_menu = [encode_link_values(x) for x in menu_groups.get(None, [])]

        contact_agency = template_values["Agency"]
        contact_address = template_values["Address"]
        contact_phone = template_values["Phone"]
        contact_email = template_values["Email"]
        contact_web = template_values["Web"] or ""
        contact_facebook = template_values["Facebook"]
        contact_twitter = template_values["Twitter"]
        contact_instagram = template_values["Instagram"]
        contact_linkedin = template_values["LinkedIn"]
        contact_youtube = template_values["YouTube"]
        terms_of_use_link = template_values["TermsOfUseLink"]
        terms_of_use_label = template_values["TermsOfUseLabel"] or gettext(
            "Terms of Use", request
        )
        footer_notice = template_values["FooterNotice"]
        footer_notice2 = template_values["FooterNotice2"]
        footer_noticecontact = template_values["FooterNoticeContact"]

        contact_email_label = None
        if contact_email:
            if "@" in contact_email:
                contact_email_label = contact_email
                contact_email = "mailto:" + contact_email
            else:
                contact_email_label = gettext("Email", request)

        new_search_link = "/"
        suggest_link = None

        domain_root = _domain_root.get(pageinfo.DbArea)
        if domain_root is not None and pageinfo.DbArea != const.DM_GLOBAL:
            new_search_link = passvars.makeLink(pageinfo.PathToStart + domain_root)
            suggest_link = passvars.makeLink(
                pageinfo.PathToStart + domain_root + "feedback.asp"
            )

        namespace = {
            "CONTAINER_FLUID": container_fluid,
            "CONTAINER_CONTRAST": container_contrast,
            "FOOTER_MENU": footer_menu,
            "FOOTER_NOTICE": footer_notice,
            "FOOTER_NOTICE_2": footer_notice2,
            "FOOTER_NOTICE_CONTACT": footer_noticecontact,
            "FOOTER_MENU_OR_NOTICE": footer_menu or footer_notice,
            "CONTACT_AGENCY": contact_agency,
            "CONTACT_ADDRESS": contact_address,
            "CONTACT_PHONE": contact_phone,
            "CONTACT_EMAIL": contact_email,
            "CONTACT_EMAIL_LABEL": contact_email_label,
            "CONTACT_WEB": contact_web,
            "CONTACT_WEB_LABEL": re.sub(r"https?://", "", contact_web or ""),
            "CONTACT_FACEBOOK": contact_facebook,
            "CONTACT_TWITTER": contact_twitter,
            "CONTACT_INSTAGRAM": contact_instagram,
            "CONTACT_LINKEDIN": contact_linkedin,
            "CONTACT_YOUTUBE": contact_youtube,
            "TERMS_OF_USE_LINK": terms_of_use_link,
            "TERMS_OF_USE_LABEL": terms_of_use_label,
            "NEW_SEARCH": new_search_link,
            "NOT_PRINT_MODE": not request.viewdata.PrintMode,
            "PRINT_MODE": request.viewdata.PrintMode,
            "SUGGEST_LINK": suggest_link,
            "NOT_LOGGED_IN": not request.user,
            "MAKE_LINK": make_linkify_fn(request),
            "FOOTER_MENU_GROUP_1": [
                encode_link_values(x) for x in menu_groups.get(1, [])
            ],
            "FOOTER_MENU_GROUP_2": [
                encode_link_values(x) for x in menu_groups.get(2, [])
            ],
            "FOOTER_MENU_GROUP_3": [
                encode_link_values(x) for x in menu_groups.get(3, [])
            ],
        }

        namespace["HAS_CONTACT_SECTION"] = any(
            namespace[x]
            for x in [
                "FOOTER_NOTICE_CONTACT",
                "CONTACT_AGENCY",
                "CONTACT_ADDRESS",
                "CONTACT_PHONE",
                "CONTACT_EMAIL",
                "CONTACT_WEB",
                "CONTACT_FACEBOOK",
                "CONTACT_TWITTER",
                "CONTACT_INSTAGRAM",
                "CONTACT_LINKEDIN",
                "CONTACT_YOUTUBE",
            ]
        )

        return apply_html_values(layout_template, namespace)


def sanitize_html(html):
    if not html:
        return html

    return sanitize_html_passvars(html)


def _linkify(passvars, data):
    params = dict(passvars)
    try:
        parsed = urlparse(data)
    except ValueError:
        return data

    params.update(parse_qs(parsed.query, True))
    params = urlencode(params, True)
    return escape(urlunparse(parsed._replace(query=params)))


def make_linkify_fn(request):
    passvars = {k: [v] for k, v in request.passvars._get_http_items()}
    return partial(_linkify, passvars)
