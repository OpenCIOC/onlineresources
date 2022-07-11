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


# Logging
import logging

log = logging.getLogger(__name__)

# Python Libraries
from itertools import chain
from collections import namedtuple

# 3rd Party Libraries
from pyramid.view import view_config, view_defaults

# CIOC Libraries
from cioc.core import i18n, validators
from cioc.web.cic.viewbase import CicViewBase

templateprefix = "cioc.web.cic:templates/taxonomy/"

_ = i18n.gettext


class OptionsSchema(validators.RootSchema):
    GlobalActivations = validators.Bool()
    InactivateUnused = validators.Bool()
    IncludeShared = validators.Bool()
    RollupLowLevelTerms = validators.Bool()
    ExcludeYBranch = validators.Bool()
    RecommendActivations = validators.Bool()


Options = namedtuple(
    "Options",
    "GlobalActivations InactivateUnused IncludeShared RollupLowLevelTerms ExcludeYBranch RecommendActivations",
)
_default_options = Options(False, True, True, False, True, True)


class ChangesSchema(validators.RootSchema):
    InactivateRollupIDList = validators.ForEach(validators.TaxonomyCodeValidator())
    RecommendActivationIDList = validators.ForEach(validators.TaxonomyCodeValidator())


@view_defaults(
    route_name="cic_taxonomy",
    match_param="action=activationrec",
    renderer=templateprefix + "activationrec.mak",
)
class activationRecView(CicViewBase):
    def __init__(self, request, require_login=True):
        CicViewBase.__init__(self, request, require_login)

    @view_config()
    def activationrec(self):
        request = self.request
        user = request.user

        if not user.cic.SuperUser:
            self._security_failure()

        globaltermchanges = []
        localtermchanges = []
        activationsuggestions = []

        options = self._get_options()

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_TAX_Term_ActivationFix ?, ?, ?, ?, ?, ?, ?, 0, NULL, NULL",
                None if options.GlobalActivations else request.dboptions.MemberID,
                user.Mod,
                *options[1:]
            )

            globaltermchanges = cursor.fetchall()

            if not options.GlobalActivations:
                cursor.nextset()
                localtermchanges = cursor.fetchall()

            if options.RecommendActivations:
                cursor.nextset()
                activationsuggestions = cursor.fetchall()

            cursor.close()

        data = request.model_state.form.data
        data["InactivateRollupIDList"] = {
            x.Code
            for x in chain(globaltermchanges, localtermchanges)
            if not x.PreferredTerm
        }
        if options.RecommendActivations:
            data["RecommendActivationIDList"] = {
                x.Code for x in activationsuggestions if x.PreferredTerm
            }

        data.update(options._asdict())

        title = _("Taxonomy Activation Recommendation Report", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                globaltermchanges=globaltermchanges,
                localtermchanges=localtermchanges,
                activationsuggestions=activationsuggestions,
                options=options,
            ),
            no_index=True,
        )

    @view_config(request_method="POST")
    def activationrec_save(self):
        request = self.request
        user = request.user

        if not user.cic.SuperUser:
            self._security_failure()

        options = self._get_options()

        model_state = request.model_state
        model_state.schema = ChangesSchema()

        if model_state.validate():
            args = [
                None if options.GlobalActivations else request.dboptions.MemberID,
                user.Mod,
            ]
            args.extend(options[1:])
            args.append(True)

            inactive_ids = model_state.value("InactivateRollupIDList")
            if inactive_ids:
                inactive_ids = ",".join(inactive_ids)
            else:
                inactive_ids = None
            args.append(inactive_ids)

            activate_ids = model_state.value("RecommendActivationIDList")
            if activate_ids:
                activate_ids = ",".join(activate_ids)
            else:
                activate_ids = None

            args.append(activate_ids)

            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    "EXEC dbo.sp_TAX_Term_ActivationFix ?, ?, ?, ?, ?, ?, ?, ?, ?, ?",
                    *args
                )
                cursor.close()

            query = {k: v for k, v in options._asdict().items() if v}
            query["mod"] = "on"
            self._go_to_route("cic_taxonomy", action="activationrec", _query=query)

        globaltermchanges = []
        localtermchanges = []
        activationsuggestions = []

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_TAX_Term_ActivationFix ?, ?, ?, ?, ?, ?, ?, 0, NULL, NULL",
                request.dboptions.MemberID,
                user.Mod,
                *options[1:]
            )

            globaltermchanges = cursor.fetchall()

            cursor.nextset()
            localtermchanges = cursor.fetchall()

            if options.RecommendActivations:
                cursor.nextset()
                activationsuggestions = cursor.fetchall()

            cursor.close()

        raise Exception
        title = _("Taxonomy Activation Recommendation Report", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                globaltermchanges=globaltermchanges,
                localtermchanges=localtermchanges,
                activationsuggestions=activationsuggestions,
                options=options,
                ErrMsg=_("There were validation errors.", request),
            ),
            no_index=True,
        )

    def _get_options(self):
        request = self.request
        if not request.params.get("mod"):
            options = _default_options

        else:
            validator = OptionsSchema()
            try:
                opts = validator.to_python(request.params)
                options = Options(**opts)
            except validators.Invalid:
                # Something went wrong. Tot he defaults
                options = _default_options

        if not request.dboptions.OtherMembersActive:
            options = options._replace(GlobalActivations=True)
        elif not request.user.cic.SuperUserGlobal:
            options = options._replace(GlobalActivations=False)

        log.debug("Options: %s", options)

        return options
