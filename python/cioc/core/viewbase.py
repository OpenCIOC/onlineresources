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

from __future__ import absolute_import
import xml.etree.cElementTree as ET

from pyramid.renderers import render_to_response, render
from pyramid.httpexceptions import HTTPFound

from cioc.core import pageinfo, template, asset, modelstate, security
from cioc.core.rootfactories import BasicRootFactory

import logging
from six.moves import zip

log = logging.getLogger(__name__)


def init_page_info(request, domain, db_area):
    if not hasattr(request, "pageinfo"):
        request.pageinfo = pageinfo.PageInfo(request, domain, db_area)


_page_whitelist = []


class ViewBase(object):
    """Base class for views."""

    __autoexpose__ = None

    def __init__(self, request, require_login=False):
        self.request = request
        request.model_state = modelstate.ModelState(request)

        self.require_login = require_login

        request.pageinfo.fetch()

        request.assetmgr = asset.AssetManager(request)

        if security.is_basic_security_failure(request, require_login):
            self._security_failure()

    def _render_to_response(
        self,
        template_name,
        page_name,
        doc_title,
        namespace=None,
        no_cache=False,
        no_index=False,
        print_table=True,
        focus="",
        show_message=False,
    ):

        args = self._create_response_namespace(
            page_name,
            doc_title,
            namespace,
            no_cache,
            no_index,
            print_table,
            focus,
            show_message,
        )

        return render_to_response(template_name, args, self.request)

    def _create_response_namespace(
        self,
        page_name,
        doc_title,
        namespace=None,
        no_cache=False,
        no_index=False,
        print_table=True,
        focus="",
        show_message=False,
    ):

        ri = template.RenderInfo(
            self.request,
            page_name,
            doc_title,
            no_cache,
            no_index,
            print_table,
            focus=focus,
            show_message=show_message,
        )
        args = ri.get_html_template_namespace()

        args["model_state"] = self.request.model_state
        args.update(namespace or {})

        return args

    def _render(self, template_name, args):
        return render(template_name, args, self.request)

    def _security_failure(self):
        self._go_to_page("~/security_failure.asp")

    def _go_to_page(self, url, httpvals=None, exclude_keys=None):
        redirect(self.request, url=url, httpvals=httpvals, exclude_keys=exclude_keys)

    def _go_to_route(self, route_name, exclude_keys=None, **kw):
        redirect(self.request, route_name=route_name, exclude_keys=exclude_keys, **kw)

    def _error_page(self, ErrMsg, title=None):
        pageinfo = self.request.pageinfo
        error_page(self.request, ErrMsg, pageinfo.Domain, pageinfo.DbArea, title)

    @staticmethod
    def dict_from_row(row):
        return {t[0]: value for (t, value) in zip(row.cursor_description, row)}

    @staticmethod
    def _dict_list_from_xml(txt, base_element):
        if txt:
            xml = ET.fromstring(txt.encode("utf8"))
        else:
            return []

        items = []
        for item_el in xml.findall("./" + base_element):
            item = {}
            items.append(item)

            for el in item_el:
                item[el.tag] = el.text

        return items

    @staticmethod
    def _culture_dict_from_xml(txt, base_element):
        items = ViewBase._dict_list_from_xml(txt, base_element)
        return dict((x["Culture"].replace("-", "_"), x) for x in items)

    @staticmethod
    def _list_from_xml(txt, base_element):
        if txt:
            xml = ET.fromstring(txt.encode("utf8"))
        else:
            return []

        return [x.text for x in xml.findall("./" + base_element)]


def security_failure(request):
    go_to_page(request, "~/security_failure.asp")


def go_to_page(request, url, httpvals=None, exclude_keys=None):
    redirect(request, url=url, httpvals=httpvals, exclude_keys=exclude_keys)


def go_to_route(request, route_name, exclude_keys=None, **kw):
    redirect(request, route_name=route_name, exclude_keys=exclude_keys, **kw)


class ErrorPage(Exception, BasicRootFactory):
    def __init__(self, request, ErrMsg, domain, db_area, title=None):
        self.ErrMsg = ErrMsg
        self.title = title

        BasicRootFactory.__init__(self, request, domain, db_area)


def error_page(request, ErrMsg, domain, db_area, title=None):
    raise ErrorPage(request, ErrMsg, domain, db_area, title)


def redirect(
    request, url=None, route_name=None, exclude_keys=None, httpvals=None, **kw
):
    if route_name:
        url = request.passvars.route_url(route_name, exclude_keys, **kw)
    else:
        url = request.host_url + request.passvars.makeLink(url, httpvals, exclude_keys)

    raise HTTPFound(location=url)
