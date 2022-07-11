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
from __future__ import absolute_import
import logging

# 3rd party
from pyramid.httpexceptions import HTTPInternalServerError
from pyramid.view import view_config

from formencode import validators, ForEach

# this app
from cioc.core import i18n, validators as ciocvalidators
from cioc.web.admin import viewbase
import six

log = logging.getLogger(__name__)

_ = i18n.gettext


def make_headers(extra_headers=None):
    tmp = dict(extra_headers or {})
    return tmp


def make_internal_server_error(message):
    error = HTTPInternalServerError()
    error.content_type = "text/plain"
    error.text = six.text_type(message)
    return error


class BillingInfoSchema(ciocvalidators.RootSchema):
    StartRange = ciocvalidators.ISODateConverter()
    EndRange = ciocvalidators.ISODateConverter()
    IncludeCIC = validators.Bool()
    IncludeVOL = validators.Bool()
    OnlyAgencyCodes = ForEach(ciocvalidators.AgencyCodeValidator())
    ExcludeAgencyCodes = ForEach(ciocvalidators.AgencyCodeValidator())


class BillingInfoSchemaFull(BillingInfoSchema):
    BaseFee = ciocvalidators.Decimal(not_empty=True)
    CostPerUser = ciocvalidators.Decimal(not_empty=True)
    CostPerBaseRecord = ciocvalidators.Decimal(not_empty=True)
    CostPerLangRecord = ciocvalidators.Decimal(not_empty=True)
    CostPerDeletedRecord = ciocvalidators.Decimal(not_empty=True)
    CostPerAccess = ciocvalidators.Decimal(not_empty=True)
    CostPerProfile = ciocvalidators.Decimal(not_empty=True)
    Discount = ciocvalidators.Decimal(not_empty=True)


@view_config(route_name="admin_billinginfo", renderer="json")
class BillingInfo(viewbase.AdminViewBase):
    def __init__(self, request):
        super(BillingInfo, self).__init__(request, require_login=False)

    def __call__(self):
        request = self.request

        if request.method != "POST":
            return make_internal_server_error("request must be post")

        if request.POST.get("billingpassword") != request.dboptions.BillingInfoPassword:
            return make_internal_server_error("invalid billing password")

        model_state = request.model_state
        if request.POST.get("full"):
            full = True
            model_state.schema = BillingInfoSchemaFull()
        else:
            full = False
            model_state.schema = BillingInfoSchema()

        if not model_state.validate():
            return make_internal_server_error(
                "Validation Errors:\n"
                + "\n".join(x + ":" + y for x, y in model_state.form.errors.items())
            )

        argnames = [
            x
            for x in model_state.schema.fields.keys()
            if x not in ["OnlyAgencyCodes", "ExcludeAgencyCodes"]
        ]
        args = [model_state.value(x) for x in argnames]
        only = model_state.value("OnlyAgencyCodes")
        if only:
            only = ",".join(only)
        else:
            only = None

        exclude = model_state.value("ExcludeAgencyCodes")
        if exclude:
            exclude = ",".join(exclude)
        else:
            exclude = None

        with request.connmgr.get_connection("admin") as conn:
            sql = "sp_STP_UsageCalculation{} ?, @OnlyAgencyCodes=?, @ExcludeAgencyCodes=?, {}"
            sql = sql.format(
                "_Fee" if full else "", ",".join("@%s = ?" % x for x in argnames)
            )

            meta = None
            cursor = conn.execute(sql, request.dboptions.MemberID, only, exclude, *args)
            if full:
                meta = self.dict_from_row(cursor.fetchone())
                cursor.nextset()

            data = [self.dict_from_row(x) for x in cursor.fetchall()]

        return {"success": True, "data": data, "meta": meta}
