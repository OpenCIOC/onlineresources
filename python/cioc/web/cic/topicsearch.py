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
from __future__ import absolute_import
import logging
from six.moves import map
log = logging.getLogger(__name__)

# Python Libraries

# 3rd Party Libraries
from pyramid.httpexceptions import HTTPNotFound
from pyramid.view import view_config, view_defaults
from markupsafe import Markup
from formencode import validators, ForEach, Schema

# CIOC Libraries
from cioc.core import i18n, validators as ciocvalidators
from cioc.web.cic.viewbase import CicViewBase

templateprefix = 'cioc.web.cic:templates/topicsearch/'

_ = i18n.gettext

search_fields = {
	'A': ['AgeGroup'],
	'G1': ['GHID', 'GHType', 'GHID_GRP'],
	'G2': ['GHID_2', 'GHType_2', 'GHID_GRP_2'],
	'C': ['CMID', 'CMType'],
	'L': ['LNID'],
}


class SearchValidators(Schema):
	allow_extra_fields = True
	filter_extra_fields = True
	if_key_missing = None

	Step = validators.Int(min=1, max=6, if_invalid=None)
	AgeGroup = ciocvalidators.IDValidator(if_invalid=None)
	LNID = ciocvalidators.IDValidator(if_invalid=None)
	CMID = ForEach(ciocvalidators.IDValidator(if_invalid=None))
	CMType = ciocvalidators.String(if_invalid=None)
	GHID = ForEach(ciocvalidators.IDValidator(), if_invalid=None)
	GHType = validators.String(if_invalid=None)
	GHID_GRP = ForEach(ciocvalidators.IDValidator(), if_invalid=None)
	GHID_2 = ForEach(ciocvalidators.IDValidator(), if_invalid=None)
	GHType_2 = validators.String(if_invalid=None)
	GHID_GRP_2 = ForEach(ciocvalidators.IDValidator(), if_invalid=None)


class NOT_FROM_DB(object):
	pass


@view_defaults(route_name='cic_topicsearch')
class TopicSearch(CicViewBase):
	def __init__(self, request, require_login=False):
		CicViewBase.__init__(self, request, require_login)

	@view_config(route_name='cic_topicsearch_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		cic_view = request.viewdata.cic

		with request.connmgr.get_connection() as conn:
			topicsearches = conn.execute('EXEC dbo.sp_CIC_View_ls_TSrch ?', cic_view.ViewType).fetchall()

		title = _('List of Available Topic Searches', request)
		return self._create_response_namespace(title, title, dict(topicsearches=topicsearches), no_index=True)

	@view_config(route_name='cic_topicsearch', renderer=templateprefix + 'searchform.mak')
	def searchform(self):
		cursor = None

		request = self.request
		cic_view = request.viewdata.cic

		topicsearch_tag = request.matchdict.get('tag')
		model_state = request.model_state
		model_state.method = None
		model_state.schema = SearchValidators

		if not model_state.validate():
			for key in model_state.form.errors:
				del model_state.form.data[key]

		search_step = model_state.value('Step', None)
		age_group_id = model_state.value('AgeGroup', None)
		language_id = model_state.value('LNID', None)
		community_ids = [x for x in model_state.value('CMID', None) or [] if x]
		community_type = model_state.value('CMType', None)
		heading1_ids = [x for x in model_state.value('GHID', None) or [] if x]
		heading2_ids = [x for x in model_state.value('GHID_2', None) or [] if x]
		group1_ids = [x for x in model_state.value('GHID_GRP', None) or [] if x]
		group2_ids = [x for x in model_state.value('GHID_GRP_2', None) or [] if x]

		community_ids = ','.join(map(str, community_ids)) if community_ids else None
		heading1_ids = ','.join(map(str, heading1_ids)) if heading1_ids else None
		group1_ids = ','.join(map(str, group1_ids)) if group1_ids else None
		heading2_ids = ','.join(map(str, heading2_ids)) if heading2_ids else None
		group2_ids = ','.join(map(str, group2_ids)) if group2_ids else None

		log.debug('heading1_ids %s', heading1_ids)

		sql = '''
			DECLARE
				@GHIDList1 varchar(max),
				@GHIDList2 varchar(max),
				@GHGroupList1 varchar(max),
				@GHGroupList2 varchar(max),
				@CMIDList varchar(max),
				@AgeGroupID int,
				@LN_ID int,
				@ViewType int

			SET @GHIDList1 = ?
			SET @GHIDList2 = ?
			SET @GHGroupList1 = ?
			SET @GHGroupList2 = ?
			SET @CMIDList = ?
			SET @AgeGroupID = ?
			SET @LN_ID = ?
			SET @ViewType = ?

			EXEC dbo.sp_CIC_View_s_TSrch @ViewType, ?, ?, @GHIDList1=@GHIDList1 OUTPUT, @GHGroupList1=@GHGroupList1 OUTPUT, @GHIDList2=@GHIDList2 OUTPUT, @GHGroupList2=@GHGroupList2 OUTPUT, @CMIDList=@CMIDList OUTPUT, @CMType=?, @AgeGroupID=@AgeGroupID OUTPUT, @LN_ID=@LN_ID OUTPUT

			SELECT @GHIDList1 AS GHID, @GHIDList2 AS GHID_2, @CMIDList AS CMID, @AgeGroupID AS AgeGroup, @LN_ID AS LNID, @GHGroupList1 AS GHID_GRP, @GHGroupList2 AS GHID_GRP_2

			EXEC dbo.sp_CIC_View_s_BSrch @ViewType
			'''

		with request.connmgr.get_connection() as conn:
			cursor = conn.execute(sql, heading1_ids, heading2_ids, group1_ids, group2_ids, community_ids, age_group_id, language_id, cic_view.ViewType, topicsearch_tag, search_step, community_type)

			topicsearch = cursor.fetchone()

			cursor.nextset()

			criteria = cursor.fetchall()

			cursor.nextset()

			formitems = cursor.fetchall()

			cursor.nextset()

			headings1 = cursor.fetchall()

			cursor.nextset()

			headings2 = cursor.fetchall()

			cursor.nextset()

			communities = cursor.fetchall()

			cursor.nextset()

			agegroups = cursor.fetchall()

			cursor.nextset()

			languages = cursor.fetchall()

			cursor.nextset()

			validated_params = cursor.fetchone()

			cursor.nextset()

			search_info = cursor.fetchone()

			cursor.close()

		searches = {
			'A': agegroups,
			'G1': headings1,
			'G2': headings2,
			'C': communities,
			'L': languages
		}

		if topicsearch is None:
			return HTTPNotFound()

		hidden_fields = [('Step', topicsearch.Step)]
		for searched_item in criteria:
			for i, field in enumerate(search_fields[searched_item.SearchType]):
				values = getattr(validated_params, field, NOT_FROM_DB)
				if values is NOT_FROM_DB:
					value = model_state.value(field)
					if value is None:
						continue
					if not isinstance(value, list):
						hidden_fields.append((field, value))
						continue
					values = value
				elif values is None:
					continue
				else:
					values = str(values).split(',')

				for value in values:
					hidden_fields.append((field, value))

		searched_for_items = [(x.SearchType, searches[x.SearchType]) for x in criteria]
		log.debug('searched_for_items %s', searched_for_items)
		joiner = Markup('</i>%s<i>') % _(' or ')
		searched_for_items = {search_type: joiner.join([x.Name for x in rs]) for search_type, rs in searched_for_items}

		title = _(topicsearch.SearchTitle, request)
		return self._create_response_namespace(title, title, dict(topicsearch=topicsearch, topicsearch_tag=topicsearch_tag, criteria=criteria, formitems=formitems, headings1=headings1, headings2=headings2, communities=communities, agegroups=agegroups, languages=languages, searches=searches, searched_for_items=searched_for_items, search_info=search_info, hidden_fields=hidden_fields, located_near=[]), no_index=True)
