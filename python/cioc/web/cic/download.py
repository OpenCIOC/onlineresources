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
import zipfile
import tempfile
import os
import unicodedata
import logging

# 3rd party
from pyramid.httpexceptions import HTTPUnauthorized, HTTPInternalServerError
from pyramid.response import Response
from pyramid.exceptions import NotFound
from pyramid.view import view_config

# this app
from cioc.core import constants as const, viewbase, i18n
from cioc.core.webobfiletool import FileIterator, FileIterable
from cioc.core.rootfactories import BasicRootFactory


log = logging.getLogger(__name__)

_ = i18n.gettext

mime_types = {
    ".xml": "text/xml",
    ".ent": "text/plain",
    ".zip": "application/zip",
    ".htm": "application/vnd.ms-excel",
    ".csv": "text/csv",
}


def make_headers(extra_headers=None):
    tmp = dict(extra_headers or {})
    return tmp


def make_401_error(message, realm="CIOC RPC"):
    error = HTTPUnauthorized(
        headers=make_headers({"WWW-Authenticate": 'Basic realm="%s"' % realm})
    )
    error.content_type = "text/plain"
    error.text = message
    return error


def make_internal_server_error(message):
    error = HTTPInternalServerError()
    error.content_type = "text/plain"
    error.text = message
    return error


def get_mimetype(ext):
    return mime_types.get(ext, "application/octet-stream")


def strip_accents(s):
    return "".join(
        c for c in unicodedata.normalize("NFD", s) if unicodedata.category(c) != "Mn"
    )


class DownloadRootFactory(BasicRootFactory):
    def __init__(self, request):
        self.allow_api_login = True
        request.context = self

        if request.params.get("api") and not request.user:
            raise make_401_error("Authentication Required")

        self.filename = filename = request.matchdict.get("filename")
        log.debug("Filename: %r", filename)

        if filename.lower().endswith("vol.zip"):
            domain = const.DM_VOL
        else:
            domain = const.DM_CIC

        BasicRootFactory.__init__(self, request, domain, domain)


@view_config(route_name="download")
class DownloadView(viewbase.ViewBase):
    def __init__(self, request, require_login=True):
        viewbase.ViewBase.__init__(self, request, require_login=True)

    def __call__(self):
        make_zip = False

        request = self.request
        user = request.user
        filename = request.context.filename

        download_dir = os.path.join(const._app_path, "download")
        fnamelower = filename.lower()

        need_super = False
        user_dom = None
        if fnamelower.endswith("cic.zip"):
            need_super = True
            user_dom = user.cic
        elif fnamelower.endswith("vol.zip"):
            need_super = True
            user_dom = user.vol

        if need_super:
            if not user_dom.SuperUser:
                self._security_failure()

        else:
            username = filename.rsplit("_", 1)
            if len(username) != 2 or username[0] != user.Login.replace(" ", "_"):
                self._security_failure()

        if "/" in filename or "\\" in filename or ".." in filename or ":" in filename:
            self._security_failure()

        root, ext = os.path.splitext(filename)
        root2, ext2 = os.path.splitext(root)
        if ext.lower() == ".zip" and ext2:
            make_zip = True
            filename = root

        fullpath = None
        if fnamelower.endswith("cic.zip") or fnamelower.endswith("vol.zip"):
            fullpath = os.path.join(
                download_dir,
                str(request.dboptions.MemberID).join(os.path.splitext(filename)),
            )
        else:
            fullpath = os.path.join(download_dir, filename)

        relativepath = os.path.relpath(fullpath, download_dir)

        if (
            ".." in relativepath
            or "/" in relativepath
            or "\\" in relativepath
            or ":" in relativepath
        ):
            self._security_failure()

        if not os.path.exists(fullpath):
            raise NotFound(_("File not found", request))

        if make_zip:
            file = tempfile.TemporaryFile()
            zip = zipfile.ZipFile(file, "w", zipfile.ZIP_DEFLATED)
            zip.write(fullpath, strip_accents(filename))
            zip.close()
            length = file.tell()
            file.seek(0)

            res = Response(content_type="application/zip", charset=None)
            res.app_iter = FileIterator(file)
            res.content_length = length
            res.last_modified = os.path.getmtime(fullpath)

        else:
            res = Response(content_type=get_mimetype(ext), conditional_response=True)
            res.app_iter = FileIterable(fullpath)
            res.content_length = os.path.getsize(fullpath)
            res.last_modified = os.path.getmtime(fullpath)
            res.etag = "{}-{}-{}".format(
                os.path.getmtime(fullpath),
                os.path.getsize(fullpath),
                hash(fullpath),
            )

        res.headers["Content-Disposition"] = "attachment;filename=" + strip_accents(
            request.context.filename
        )
        return res
