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


import logging
log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET
#import elementtree.ElementTree as ET

from formencode import Schema, validators, foreach, variabledecode, Any
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/'


class FieldGroupDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=100)


class FieldGroupBaseSchema(Schema):
	if_key_missing = None

	DisplayFieldGroupID = Any(ciocvalidators.IDValidator(), validators.OneOf(['NEW']))
	DisplayOrder = validators.Int(min=0, max=256, not_empty=True)
	delete = validators.Bool()

	Descriptions = ciocvalidators.CultureDictSchema(FieldGroupDescriptionSchema(), record_cultures=True, allow_extra_fields=True, fiter_extra_fields=False)


class PostSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	pre_validators = [viewbase.cull_extra_cultures('Descriptions', 'group')]
	group = foreach.ForEach(FieldGroupBaseSchema())


@view_defaults(route_name='admin_view', match_param="action=fieldgroup", renderer=templateprefix + 'fieldgroup.mak')
class FieldGroup(viewbase.AdminViewBase):

	@view_config()
	def index(self):
		request = self.request
		user = request.user

		log.debug('before basic info: %s', user)
		ViewType, domain, shown_cultures = self._basic_info()
		log.debug('after basic info')

		groups = []
		viewinfo = None
		with request.connmgr.get_connection('admin') as conn:
			log.debug('before execute')
			cursor = conn.execute('EXEC sp_%s_View_DisplayFieldGroup_lf ?, ?, ?' % domain.str, request.dboptions.MemberID, user.Agency, ViewType)
			log.debug('cursor')

			viewinfo = cursor.fetchone()
			log.debug('viewinfo')
			if viewinfo:

				cursor.nextset()
				log.debug('nextset')

				groups = cursor.fetchall()

			log.debug('before close')
			cursor.close()

		if not viewinfo:  # not a valid view
			log.debug('redirect')
			self._error_page(_('View Not Found', request))

		log.debug('descriptions')
		for group in groups:
			group.Descriptions = self._culture_dict_from_xml(group.Descriptions, 'DESC')

		log.debug('record_cultures')
		#raise Exception

		record_cultures = syslanguage.active_record_cultures()

		request.model_state.form.data['group'] = groups

		title = _('Field Groups (%s)', request) % viewinfo.ViewName

		return self._create_response_namespace(
			title,
			title,
			dict(
				groups=groups, record_cultures=record_cultures, ViewType=ViewType,
				domain=domain, shown_cultures=shown_cultures
			),
			no_index=True,
			print_table=False
		)

	@view_config(request_method="POST")
	def save(self):
		request = self.request
		user = request.user

		ViewType, domain, shown_cultures = self._basic_info()

		model_state = request.model_state
		model_state.schema = PostSchema()

		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect

			root = ET.Element('GROUPS')
			for i, group in enumerate(model_state.form.data['group']):
				if not group.get('DisplayFieldGroupID'):
					continue

				if group.get('delete'):
					continue

				if all(not v for k, v in group.iteritems() if not (k == 'DisplayFieldGroupID' and v == 'NEW')):
					continue

				group_el = ET.SubElement(root, 'GROUP')
				ET.SubElement(group_el, 'CNT').text = unicode(i)

				for key, value in group.iteritems():
					if key == 'DisplayFieldGroupID' and value == 'NEW':
						value = -1

					if key != 'Descriptions':
						if value is not None:
							ET.SubElement(group_el, key).text = unicode(value)
						continue

					descs = ET.SubElement(group_el, 'DESCS')
					for culture, data in value.iteritems():
						culture = culture.replace('_', '-')
						if culture not in shown_cultures:
							continue

						desc = ET.SubElement(descs, 'DESC')
						ET.SubElement(desc, 'Culture').text = culture
						for key, value in data.iteritems():
							if value:
								ET.SubElement(desc, key).text = value

			args = [ViewType, user.Mod, request.dboptions.MemberID, user.Agency, ET.tostring(root)]

			#raise Exception
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXECUTE @RC = dbo.sp_%s_View_DisplayFieldGroup_u ?, ?, ?, ?, ?, @ErrMsg OUTPUT  

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % domain.str

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self._go_to_route('admin_view', action="fieldgroup",
						_query=[('InfoMsg', _('The Field Groups were successfully updated.', request)), 
							('ShowCultures', shown_cultures ), 
							('DM', domain.id), ('ViewType', ViewType)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')


		groups = []
		with request.connmgr.get_connection('admin') as conn:
			groups = conn.execute('EXEC sp_%s_View_DisplayFieldGroup_lf ?, ?, ?, 1' % domain.str, request.dboptions.MemberID, user.Agency, ViewType).fetchall()

		#errors = model_state.form.errors
		#raise Exception()
		# XXX should we refetch the basic info?

		groups = variabledecode.variable_decode(request.POST)['group']
		model_state.form.data['group'] = groups

		record_cultures = syslanguage.active_record_cultures()

		title = _('Change Field Groups', request)
		return self._create_response_namespace(title, title,
				dict(groups=groups, record_cultures=record_cultures,
					domain=domain, shown_cultures=shown_cultures, 
					ViewType=ViewType, ErrMsg=ErrMsg),
				no_index=True, print_table=False)


	def _basic_info(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()


		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			return self._go_to_page('~/admin/setup.asp')

		if (domain.id == const.DM_CIC and not user.cic.SuperUser) or \
				(domain.id == const.DM_VOL and not user.vol.SuperUser):

			self._security_failure()

		validator = ciocvalidators.IDValidator(not_empty=True)
		try:
			ViewType = validator.to_python(request.params.get('ViewType'))
		except validators.Invalid, e:
			self._error_page(_('Invalid View Type: ', request) + e.message) 

		return ViewType, domain, shown_cultures
