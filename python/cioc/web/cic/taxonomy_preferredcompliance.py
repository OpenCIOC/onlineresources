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

# 3rd Party Libraries
from pyramid.view import view_config, view_defaults

# CIOC Libraries
from cioc.core import i18n, validators
from cioc.web.cic.viewbase import CicViewBase

templateprefix = 'cioc.web.cic:templates/taxonomy/'

_ = i18n.gettext


class ChangesSchema(validators.RootSchema):
	AutoFixList = validators.ForEach(validators.TaxonomyCodeValidator())


@view_defaults(route_name='cic_taxonomy', match_param='action=preferredcompliance', renderer=templateprefix + 'preferredcompliance.mak')
class activationRecView(CicViewBase):
	def __init__(self, request, require_login=True):
		CicViewBase.__init__(self, request, require_login)

	@view_config()
	def preferredcompliance(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		compliancelist = []

		act_global = bool(not request.dboptions.OtherMembersActive or (request.params.get('Global') and user.cic.SuperUserGlobal))

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_TAX_Term_l_PreferredTermCompliance ?, ?', request.dboptions.MemberID, act_global)

			compliancelist = cursor.fetchall()

			cursor.close()

		data = request.model_state.form.data
		data['AutoFixList'] = set(x.Code for x in compliancelist if x.Active == 1 and x.OrphanWarning == 0)

		title = _('Taxonomy Preferred Term Compliance Report', request)
		return self._create_response_namespace(title, title, dict(compliancelist=compliancelist, act_global=act_global), no_index=True)

	@view_config(request_method="POST")
	def preferredcompliance_save(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = ChangesSchema()

		act_global = bool(not request.dboptions.OtherMembersActive or (request.params.get('Global') and user.cic.SuperUserGlobal))

		if model_state.validate():
			args = [user.Mod, request.dboptions.MemberID]

			autofix_ids = model_state.value('AutoFixList')
			if autofix_ids:
				autofix_ids = ','.join(autofix_ids)
			else:
				autofix_ids = None
			args.append(autofix_ids)

			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute('EXEC dbo.sp_TAX_Term_u_PreferredTermCompliance ?, ?, ?', *args)
				cursor.close()

			extra_args = {}
			if request.dboptions.OtherMembersActive and act_global:
				extra_args['_query'] = [('Global', 'on')]
			self._go_to_route('cic_taxonomy', action='preferredcompliance', **extra_args)

		compliancelist = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_TAX_Term_l_PreferredTermCompliance ?, ?', request.dboptions.MemberID, act_global)

			compliancelist = cursor.fetchall()

			cursor.close()

		title = _('Taxonomy Preferred Term Compliance Report', request)
		return self._create_response_namespace(title, title, dict(compliancelist=compliancelist, act_global=act_global), no_index=True)
