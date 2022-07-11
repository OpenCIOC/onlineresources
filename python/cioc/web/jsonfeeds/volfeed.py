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
import logging

# 3rd party
from pyramid.view import view_config

# this app
from cioc.core import i18n, validators as ciocvalidators
from cioc.web.vol import viewbase
from cioc.core.format import textToHTML

_ = i18n.gettext

log = logging.getLogger(__name__)


class APISchema(ciocvalidators.RootSchema):
    if_key_missing = None
    key = ciocvalidators.UUIDValidator(not_empty=True)


class PosAPISchema(APISchema):
    duties = ciocvalidators.Bool()
    loc = ciocvalidators.Bool()


class OrgAPISchema(PosAPISchema):
    num = ciocvalidators.NumValidator(not_empty=True)


class CodeAPISchema(PosAPISchema):
    code = ciocvalidators.CodeValidator(not_empty=True)


class BaseFeedView(viewbase.VolViewBase):
    extra_args = []

    def get_proc_args(self):
        model_state = self.request.model_state
        return [model_state.value("key")] + [
            model_state.value(x) for x in self.extra_args
        ]

    def __call__(self):
        request = self.request

        model_state = request.model_state
        model_state.method = None
        model_state.schema = self.schema

        if not model_state.validate():
            api_key = None
            error_msg = _("Invalid Request", request)
            error_details = model_state.form.errors
            request.response.status_code = 400
            return {"error": error_msg, "error_details": error_details}

        api_key = model_state.value("key")
        error_msg = None

        args = self.get_proc_args()

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                """
                DECLARE @RC as int
                EXECUTE @RC = %s ?, %s
                SELECT @RC as [Return]
                """
                % (self.stored_proc, ",".join("?" * len(args))),
                request.viewdata.vol.ViewType,
                *args
            )

        results = cursor.fetchall()

        cursor.nextset()
        key_error = cursor.fetchone()
        cursor.close()

        if key_error.Return == -1:
            request.response.status_code = 403
            error_msg = _("Invalid API Token", request)

        return {"error": error_msg, "recordset": self.process_results(results)}


@view_config(route_name="jsonfeeds_volnewest", renderer="json")
class JsonFeedsVolNewestOpps(BaseFeedView):
    schema = PosAPISchema
    stored_proc = "dbo.sp_VOL_WhatsNew_Feed"
    extra_args = ["duties", "loc"]

    def process_results(self, results):
        return [
            {
                "id": row.VNUM,
                "search": "/volunteer/record/" + row.VNUM,
                "name": row.ORG_NAME_FULL,
                "title": row.POSITION_TITLE,
                "duties": textToHTML(row.DUTIES),
                "location": row.LOCATION,
                "date": row.LAST_UPDATED,
            }
            for row in results
        ]


@view_config(route_name="jsonfeeds_volpopularinterests", renderer="json")
class JsonFeedsVolPopularInterests(BaseFeedView):
    schema = APISchema
    stored_proc = "dbo.sp_VOL_PopularInterest_Feed"

    def process_results(self, results):
        return [
            {
                "id": row.AI_ID,
                "search": "/volunteer/results.asp?AIID=" + str(row.AI_ID),
                "name": row.InterestName,
                "count": row.UsageCount,
            }
            for row in results
        ]


@view_config(route_name="jsonfeeds_volpopularorgs", renderer="json")
class JsonFeedsVolPopularOrgs(BaseFeedView):
    schema = APISchema
    stored_proc = "dbo.sp_VOL_PopularOrg_Feed"

    def process_results(self, results):
        return [
            {
                "id": row.NUM,
                "search": "/volunteer/results.asp?NUM=" + row.NUM,
                "name": row.ORG_NAME_FULL,
                "count": row.OpCount,
            }
            for row in results
        ]


@view_config(route_name="jsonfeeds_volorg", renderer="json")
class JsonFeedsVolOrgOpps(BaseFeedView):
    schema = OrgAPISchema
    stored_proc = "dbo.sp_VOL_SpecificOrg_Feed"
    extra_args = ["num", "duties", "loc"]

    def process_results(self, results):
        return [
            {
                "id": row.VNUM,
                "search": "/volunteer/record/" + row.VNUM,
                "name": row.ORG_NAME_FULL,
                "title": row.POSITION_TITLE,
                "duties": textToHTML(row.DUTIES),
                "location": row.LOCATION,
                "date": row.LAST_UPDATED,
            }
            for row in results
        ]


@view_config(route_name="jsonfeeds_volinterest", renderer="json")
class JsonFeedsVolInterestOpps(BaseFeedView):
    schema = CodeAPISchema
    stored_proc = "dbo.sp_VOL_SpecificInterest_Feed"
    extra_args = ["code", "duties", "loc"]

    def process_results(self, results):
        return [
            {
                "id": row.VNUM,
                "search": "/volunteer/record/" + row.VNUM,
                "name": row.ORG_NAME_FULL,
                "title": row.POSITION_TITLE,
                "duties": row.DUTIES,
                "location": row.LOCATION,
                "date": row.LAST_UPDATED,
            }
            for row in results
        ]
