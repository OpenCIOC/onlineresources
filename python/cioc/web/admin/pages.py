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


# std library
import logging
from wsgiref.validate import validator

# 3rd party libs
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators, constants as const
from cioc.core.i18n import gettext as _
from cioc.web.admin.viewbase import AdminViewBase, get_domain

log = logging.getLogger(__name__)


class PageSchemaBase(validators.RootSchema):
    if_key_missing = None

    Owner = validators.AgencyCodeValidator()
    Slug = validators.SlugValidator(not_empty=True, max=50)
    Title = validators.UnicodeString(max=200, not_empty=True)
    PageContent = validators.UnicodeString(not_empty=True)
    PublishAsArticle = validators.Bool()
    DisplayPublishDate = validators.DateConverter()
    Author = validators.UnicodeString(max=200)
    Category = validators.UnicodeString(max=200)
    PreviewText = validators.UnicodeString()
    ThumbnailImageURL = validators.URLWithProto(max=255)

templateprefix = "cioc.web.admin:templates/pages/"


@view_defaults(route_name="admin_pages", renderer=templateprefix + "edit.mak")
class PagesView(AdminViewBase):
    @view_config(route_name="admin_pages_index", renderer=templateprefix + "index.mak")
    def index(self):
        request = self.request

        domain = self.get_domain()

        with request.connmgr.get_connection("admin") as conn:
            pages = conn.execute(
                "EXEC dbo.sp_GBL_Page_l ?, ?, ?",
                request.dboptions.MemberID,
                domain.id,
                request.user.Agency,
            ).fetchall()

        title = _("Pages (%s)", request) % _(domain.label, request)
        return self._create_response_namespace(
            title, title, dict(pages=pages, domain=domain), no_index=True
        )

    @view_config(match_param="action=edit", request_method="POST")
    @view_config(match_param="action=add", request_method="POST")
    def save(self):
        request = self.request
        user = request.user

        domain = self.get_domain()

        if request.params.get("Delete"):
            query = [("PageID", request.params.get("PageID")), ("DM", domain.id)]
            self._go_to_route("admin_pages", action="delete", _query=query)

        is_add = request.matchdict.get("action") == "add"

        model_state = request.model_state

        extra_validators = {}
        pageid_validator = {}
        if is_add:
            extra_validators["Culture"] = validators.ActiveCulture(not_empty=True)
        else:
            pageid_validator["PageID"] = validators.IDValidator(not_empty=True)

        schema = validators.RootSchema(
            page=PageSchemaBase(**extra_validators),
            views=validators.ForEach(validators.IDValidator()),
            **pageid_validator
        )
        model_state.schema = schema
        model_state.form.variable_decode = True

        if model_state.validate():
            page_id = model_state.value("PageID")

            args = [
                page_id,
                user.Mod,
                request.dboptions.MemberID,
                domain.id,
                user.Agency,
                model_state.value("page.Culture"),
                model_state.value("page.Slug"),
                model_state.value("page.Title"),
                model_state.value("page.Owner"),
                model_state.value("page.PageContent"),
                ",".join(map(str, model_state.value("views", []))),
                model_state.value("page.PublishAsArticle"),
                model_state.value("page.Author"),
                model_state.value("page.DisplayPublishDate"),
                model_state.value("page.Category"),
                model_state.value("page.PreviewText"),
                model_state.value("page.ThumbnailImageURL"),
            ]

            with request.connmgr.get_connection("admin") as conn:
                sql = """
                DECLARE @ErrMsg as nvarchar(500),
                @RC as int,
                @PageID as int

                SET @PageID = ?

                EXECUTE @RC = dbo.sp_GBL_Page_u @PageID OUTPUT, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

                SELECT @RC as [Return], @ErrMsg AS ErrMsg, @PageID as PageID
                """
                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                page_id = result.PageID

                if is_add:
                    msg = _("The Page was successfully added.", request)
                else:
                    msg = _("The Page was successfully updated.", request)

                query = [("InfoMsg", msg), ("PageID", page_id), ("DM", domain.id)]
                self._go_to_route("admin_pages", action="edit", _query=query)

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:

            if model_state.is_error("PageID"):
                self._error_page(_("Invalid Page ID", request))

            page_id = model_state.value("PageID")

            ErrMsg = _("There were validation errors.")

        page = None

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_GBL_Page_s ?, ?, ?, ?",
                request.dboptions.MemberID,
                user.Agency,
                domain.id,
                page_id,
            )

            page = cursor.fetchone()

            cursor.nextset()

            views = cursor.fetchall()

            cursor.close()

            if not page and not is_add:
                self._error_page(_("Page Not Found", request))

        title = _("Page (%s)", request) % _(domain.label, request)
        data = model_state.form.data
        data["views"] = request.POST.getall("views")

        return self._create_response_namespace(
            title,
            title,
            dict(
                PageID=page_id,
                page=page,
                is_add=is_add,
                views=views,
                domain=domain,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=edit")
    @view_config(match_param="action=add")
    def edit(self):
        request = self.request

        domain = self.get_domain()

        is_add = request.matchdict.get("action") == "add"

        model_state = request.model_state
        model_state.method = None
        model_state.schema = validators.RootSchema(
            PageID=validators.IDValidator(not_empty=not is_add), if_key_missing=None
        )

        if not model_state.validate():
            self._error_page(
                _("Unable to load page: %s", request)
                % model_state.renderer.errorlist("PageID")
            )
        page_id = model_state.value("PageID")

        page = None
        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_GBL_Page_s ?, ?, ?, ?",
                request.dboptions.MemberID,
                request.user.Agency,
                domain.id,
                page_id,
            )

            page = cursor.fetchone()

            cursor.nextset()

            views = cursor.fetchall()

            if not is_add and not page:
                self._error_page(_("Page Not Found", request))

        data = model_state.form.data
        data["page"] = page
        data["views"] = {str(v.ViewType) for v in views if v.Selected}

        title = _("Page (%s)", request) % _(domain.label, request)
        return self._create_response_namespace(
            title,
            title,
            dict(PageID=page_id, page=page, is_add=is_add, views=views, domain=domain),
            no_index=True,
        )

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request

        domain = self.get_domain()

        model_state = request.model_state

        model_state.validators = {"PageID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        PageID = model_state.form.data["PageID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        extra_values = [("DM", domain.id)]

        title = _("Delete Page (%s)", request) % _(domain.label, request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="PageID",
                id_value=PageID,
                route="admin_pages",
                action="delete",
                extra_values=extra_values,
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request

        domain = self.get_domain()

        model_state = request.model_state

        model_state.validators = {"PageID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        PageID = model_state.form.data["PageID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
            DECLARE @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_GBL_Page_d ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
            """

            cursor = conn.execute(
                sql, request.dboptions.MemberID, request.user.Agency, domain.id, PageID
            )
            result = cursor.fetchone()
            cursor.close()

        query = [("DM", domain.id)]

        if not result.Return:
            self._go_to_route(
                "admin_pages_index",
                _query=[("InfoMsg", _("Page was successfully deleted.", request))]
                + query,
            )

        if result.Return == 3:
            self._error_page(_("Unable to delete Page: ", request) + result.ErrMsg)

        self._go_to_route(
            "admin_pages",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Page: ") + result.ErrMsg),
                ("PageID", PageID),
            ]
            + query,
        )

    def get_domain(self):
        user = self.request.user
        if not user.SuperUser or user.WebDeveloper:
            self._security_failure()

        domain = get_domain(self.request.params)
        if domain is None:
            self._error_page(_("Invalid Domain", self.request))

        if (
            domain.id == const.DM_CIC
            and not user.cic.SuperUser
            and not user.cic.WebDeveloper
        ) or (
            domain.id == const.DM_VOL
            and not user.vol.SuperUser
            and not user.vol.WebDeveloper
        ):
            self._security_failure()

        return domain
