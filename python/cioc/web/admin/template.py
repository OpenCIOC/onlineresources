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
from itertools import groupby
from operator import attrgetter, itemgetter
from cgi import escape

from formencode import Schema, validators, ForEach, Any, Pipe, variabledecode
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const

from cioc.core.i18n import gettext as _
from cioc.web.admin.viewbase import AdminViewBase

templateprefix = 'cioc.web.admin:templates/template/'

colour_fields = (
	'BackgroundColour', 'FontColour', 'bgColorLogo',
	'fcLabel', 'FieldLabelColour',
	'LinkColour', 'ALinkColour', 'VLinkColour',
	'fcTitle', 'bgColorTitle', 'borderColorTitle', 'iconColorTitle',
	'fcContent', 'bgColorContent', 'borderColorContent', 'iconColorContent',
	'fcHeader', 'bgColorHeader', 'borderColorHeader', 'iconColorHeader',
	'fcFooter', 'bgColorFooter', 'borderColorFooter', 'iconColorFooter',
	'fcMenu', 'bgColorMenu', 'borderColorMenu', 'iconColorMenu',
	'fcDefault', 'bgColorDefault', 'borderColorDefault', 'iconColorDefault',
	'fcHover', 'bgColorHover', 'borderColorHover', 'iconColorHover',
	'fcActive', 'bgColorActive', 'borderColorActive', 'iconColorActive',
	'fcHighlight', 'bgColorHighlight', 'borderColorHighlight', 'iconColorHighlight',
	'AlertColour', 'fcError', 'bgColorError', 'borderColorError', 'iconColorError',
	'fcInfo', 'bgColorInfo', 'borderColorInfo', 'iconColorInfo',

	# deprecated colours
	'MenuFontColour', 'MenuBgColour',
	'TitleFontColour', 'TitleBgColour',
)

link_fields = (
	'ShortCutIcon', 'AppleTouchIcon', 'StyleSheetUrl', 'JavaScriptTopUrl', 'JavaScriptBottomUrl', 'Background'
)


class TemplateBaseSchema(Schema):
	if_key_missing = None

	Owner = ciocvalidators.AgencyCodeValidator()
	BannerRepeat = validators.Bool()
	BannerHeight = validators.Int(min=10, max=255)
	BodyTagExtras = ciocvalidators.String(max=150)
	FontFamily = validators.String(max=100)

	ExtraCSS = ciocvalidators.UnicodeString()
	HeaderLayout = ciocvalidators.IDValidator(not_empty=True)
	FooterLayout = ciocvalidators.IDValidator(not_empty=True)
	SearchLayoutCIC = ciocvalidators.IDValidator()
	SearchLayoutVOL = ciocvalidators.IDValidator()

	HeaderSearchLink = validators.Bool()
	HeaderSearchIcon = validators.Bool()
	HeaderSuggestLink = validators.Bool()
	HeaderSuggestIcon = validators.Bool()

	ContainerFluid = validators.Bool()
	ContainerContrast = validators.Bool()
	SmallTitle = validators.Bool()

	cornerRadius = ciocvalidators.String(max=10)
	fsDefault = ciocvalidators.String(max=10)

	FullSSLCompatible = validators.Bool()
	UseFontAwesome = validators.Bool()
	PreviewTemplate = validators.Bool()

	chained_validators = [
		ciocvalidators.RequireIfAny('SearchLayoutCIC', missing='SearchLayoutVOL'),
		ciocvalidators.RequireIfAny('SearchLayoutVOL', missing='SearchLayoutCIC')
	]

	# NOTE some field validators added dynamically below

all_fields = tuple(TemplateBaseSchema.fields.iterkeys()) + colour_fields + link_fields

for field in colour_fields:
	TemplateBaseSchema.add_field(field, ciocvalidators.HexColourValidator())

for field in link_fields:
	TemplateBaseSchema.add_field(field, Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150)))


class TemplateDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=150)
	Logo = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	LogoAltText = ciocvalidators.UnicodeString(max=200)
	LogoLink = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	LogoMobile = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	Banner = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	CopyrightNotice = ciocvalidators.UnicodeString(max=255)
	headerGroup1 = ciocvalidators.UnicodeString(max=100)
	headerGroup2 = ciocvalidators.UnicodeString(max=100)
	headerGroup3 = ciocvalidators.UnicodeString(max=100)
	footerGroup1 = ciocvalidators.UnicodeString(max=100)
	footerGroup2 = ciocvalidators.UnicodeString(max=100)
	footerGroup3 = ciocvalidators.UnicodeString(max=100)
	cicsearchGroup1 = ciocvalidators.UnicodeString(max=100)
	cicsearchGroup2 = ciocvalidators.UnicodeString(max=100)
	cicsearchGroup3 = ciocvalidators.UnicodeString(max=100)
	volsearchGroup1 = ciocvalidators.UnicodeString(max=100)
	volsearchGroup2 = ciocvalidators.UnicodeString(max=100)
	volsearchGroup3 = ciocvalidators.UnicodeString(max=100)
	Agency = ciocvalidators.UnicodeString(max=255)
	Address = ciocvalidators.UnicodeString(max=255)
	Phone = ciocvalidators.UnicodeString(max=255)
	Email = ciocvalidators.UnicodeString(max=150)
	Web = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	Facebook = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	Twitter = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	Instagram = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	LinkedIn = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	YouTube = Pipe(ciocvalidators.URLWithProto(add_http=True, require_tld=False), validators.MaxLength(150))
	TermsOfUseLink = ciocvalidators.UnicodeString(max=150)
	TermsOfUseLabel = ciocvalidators.UnicodeString(max=100)
	FooterNotice = ciocvalidators.UnicodeString(max=3000)
	FooterNotice2 = ciocvalidators.UnicodeString(max=2000)
	FooterNoticeContact = ciocvalidators.UnicodeString(max=2000)
	HeaderNotice = ciocvalidators.UnicodeString(max=2000)
	HeaderNoticeMobile = ciocvalidators.UnicodeString(max=1000)

	chained_validators = [
		ciocvalidators.RequireIfAny('Name', present=("LogoLink", "Logo", "CopyrightNotice", "LogoMobile", "LogoAltText", "Banner", "Agency", "Address", "Phone", "Email", "Web", "Facebook", "Twitter", "Instagram", "LinkedIn", "YouTube"))
	]


class MenuItemSchema(Schema):
	if_key_missing = None

	delete = validators.Bool()
	MenuID = Any(ciocvalidators.IDValidator(), validators.OneOf(['NEW']))
	Link = ciocvalidators.String(max=150)
	Display = ciocvalidators.UnicodeString(max=200)
	MenuGroup = ciocvalidators.Int(min=1, max=3)
	chained_validators = [
		ciocvalidators.RequireIfAny('Display', present=("Link",)),
		ciocvalidators.RequireIfAny('Link', present=("Display",)),
	]


class MenuTypes(Schema):
	if_key_missing = None

menu_types = ['header', 'footer', 'cicsearch', 'volsearch']
menu_item_list_validator = ciocvalidators.CultureDictSchema(ForEach(MenuItemSchema()))
for field in menu_types:
	MenuTypes.add_field(field, menu_item_list_validator)

for field in menu_types:
	for group in range(1, 4):
		TemplateDescriptionSchema.add_field('%sGroup%d' % (field, group), ciocvalidators.UnicodeString(max=100))


class TemplateSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	template = TemplateBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(TemplateDescriptionSchema())
	menus = MenuTypes()


@view_defaults(route_name='admin_template')
class Template(AdminViewBase):

	@view_config(route_name='admin_template_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not (user.SuperUser or user.WebDeveloper):
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_Template_l_Admin ?', request.dboptions.MemberID)
			templates = cursor.fetchall()
			cursor.close()

		title = _('Manage Templates', request)
		return self._create_response_namespace(title, title, dict(templates=templates), no_index=True)

	@view_config(match_param='action=edit', request_method="POST", renderer=templateprefix + 'edit.mak')
	@view_config(match_param='action=add', request_method="POST", renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request
		user = request.user

		if not (user.SuperUser or user.WebDeveloper):
			self._security_failure()

		action = request.matchdict.get('action')
		is_add = action == 'add'

		if not is_add and request.params.get('Delete'):
			return self._go_to_route('admin_template', action='delete',
							_query=[('TemplateID', request.params.get('TemplateID'))])

		extra_validators = {}
		model_state = request.model_state
		if not is_add:
			extra_validators['TemplateID'] = ciocvalidators.IDValidator()

		model_state.schema = TemplateSchema(**extra_validators)
		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect
			if not is_add:
				TemplateID = model_state.form.data['TemplateID']
			else:
				TemplateID = None

			args = [TemplateID, user.Mod, request.dboptions.MemberID, user.Agency, user.cic.SuperUser, user.vol.SuperUser]
			template = model_state.form.data['template']

			kwargs = ", ".join(k.join(("@", "=?")) for k in all_fields)
			args.extend(template.get(k) for k in all_fields)

			root = ET.Element('DESCS')

			for culture, data in model_state.form.data['descriptions'].iteritems():
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in data.iteritems():
					if value:
						ET.SubElement(desc, name).text = unicode(value)

			args.append(ET.tostring(root))

			root = ET.Element('MENUS')
			for menu_type, data in model_state.form.data['menus'].iteritems():
				for culture, menu_item_list in data.iteritems():
					for i, menu_item in enumerate(menu_item_list):
						if menu_item.get('delete') or (not menu_item.get('Link') and not menu_item.get('Display')):
							# deletion
							continue

						menu = ET.SubElement(root, 'MENU')
						ET.SubElement(menu, "Culture").text = culture.replace('_', '-')
						ET.SubElement(menu, "MenuType").text = menu_type
						ET.SubElement(menu, "DisplayOrder").text = unicode(i)
						for name, value in menu_item.iteritems():
							if name == 'MenuID' and value == 'NEW':
								continue

							if value:
								ET.SubElement(menu, name).text = unicode(value)

			args.append(ET.tostring(root))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@TemplateID as int

				SET @TemplateID = ?

				EXECUTE @RC = dbo.sp_GBL_Template_u @TemplateID OUTPUT, ?, ?, ?, ?, ?, %s, @Descriptions=?, @MenuItems=?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @TemplateID as TemplateID
				''' % (kwargs)

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				TemplateID = result.TemplateID

				if is_add:
					msg = _('The Template has been successfully added.', request)
				else:
					msg = _('The Template has been successfully updated.', request)

				self.request.dboptions._invalidate()
				self._go_to_route('admin_template', action='edit', _query=(('InfoMsg', msg), ("TemplateID", TemplateID)))

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			if model_state.is_error('layout.TemplateID'):
				self._error_page(_('Invalid Template ID', request))
			ErrMsg = _('There were validation errors.')
			log.debug('validation errors: %s', model_state.form.errors)

		layouts = []
		template = None
		with request.connmgr.get_connection('admin') as conn:
			if not is_add:
				template = conn.execute('EXEC dbo.sp_GBL_Template_sf ?, ?, ?', request.dboptions.MemberID, user.Agency, model_state.value('TemplateID')).fetchone()
			layouts = conn.execute('EXEC dbo.sp_GBL_Template_Layout_l ?, ?, ?', request.dboptions.MemberID, user.Agency, None if is_add else ','.join(str(getattr(template, x)) for x in ['HeaderLayout', 'FooterLayout', 'SearchLayoutCIC', 'SearchLayoutVOL'] if getattr(template, x, None))).fetchall()

		layoutdict = {}
		for group, items in groupby(layouts, attrgetter('LayoutType')):
			layoutdict[group] = list(items)

		views = None
		menus = variabledecode.variable_decode(request.POST).get('menus') or {}
		if not is_add:
			views = self._get_status_info(template)

		title = _('Manage Templates', request)
		return self._create_response_namespace(
			title, title,
			dict(
				action=action, TemplateID=model_state.value('TemplateID'),
				template=template, layouts=layoutdict, views=views, menus=menus, ErrMsg=ErrMsg
			), no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	@view_config(match_param='action=add', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not (user.SuperUser or user.WebDeveloper):
			self._security_failure()

		action = request.matchdict.get('action')
		is_add = action == 'add'

		model_state = request.model_state
		model_state.validators = {
			'TemplateID': ciocvalidators.IDValidator(not_empty=not is_add)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid TemplateID

			self._error_page(_('Invalid ID', request))

		TemplateID = model_state.form.data.get('TemplateID')

		template = None
		template_descriptions = {}
		layouts = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_GBL_Template_sf ?, ?, ?', request.dboptions.MemberID, user.Agency, TemplateID)
			template = cursor.fetchone()
			if template:
				cursor.nextset()
				for lng in cursor.fetchall():
					template_descriptions[lng.Culture.replace('-', '_')] = lng

			cursor.close()

			layouts = conn.execute('EXEC dbo.sp_GBL_Template_Layout_l ?, ?, ?', request.dboptions.MemberID, user.Agency, None if is_add else ','.join(str(getattr(template, x)) for x in ['HeaderLayout', 'FooterLayout', 'SearchLayoutCIC', 'SearchLayoutVOL'] if getattr(template, x, None))).fetchall()

		if not is_add and not template:
			# not found
			self._error_page(_('Template Not Found', request))

		model_state.form.data['template'] = template
		model_state.form.data['descriptions'] = template_descriptions

		layoutdict = {}
		for group, items in groupby(layouts, attrgetter('LayoutType')):
			layoutdict[group] = list(items)

		menus = self._get_menus(template)
		model_state.form.data['menus'] = menus

		views = None
		if is_add:
			if template:
				template.SystemTemplate = False
			for desc in template_descriptions.itervalues():
				desc.Name = None

			for menu_group in menus.itervalues():
				for menu_lang in menu_group.itervalues():
					for menu_item in menu_lang:
						menu_item['MenuID'] = 'NEW'
		else:
			views = self._get_status_info(template)

		title = _('Manage Templates', request)
		return self._create_response_namespace(title, title,
			dict(
				action=action, template=template,
				template_descriptions=template_descriptions,
				TemplateID=TemplateID, layouts=layoutdict, views=views, menus=menus
			), no_index=True)

	def _get_view_links(self, related_views, dm):
		if not related_views:
			return []

		passvars = self.request.passvars
		agency = self.request.user.Agency
		views = []

		xml = ET.fromstring(related_views.encode('utf8'))
		MemberID = unicode(self.request.dboptions.MemberID)
		for view in xml.findall('./VIEW'):
			attrib = view.attrib
			if view.get('Owner', agency) == agency and view.get('MemberID', MemberID) == MemberID:
				views.append('<a href="%s">%s</a>' %
						(escape(passvars.route_path('admin_view', action='edit', _query=[('DM', dm),
							('ViewType', view.get('ViewType'))]), True),
							escape(view.get('ViewName'), True)))

			else:
				views.append(escape(attrib.get('ViewName')))

		return views

	def _get_status_info(self, template):
		return self._get_view_links(template.RELATED_VIEW_CIC, const.DM_CIC) + self._get_view_links(template.RELATED_VIEW_VOL, const.DM_VOL)

	def _get_menus(self, template):
		if not template or not template.MENUS:
			return {}

		xml = ET.fromstring(template.MENUS.encode('utf8'))
		menus = []
		for menu_el in xml.findall('./MENU'):
			menu = {}
			menus.append(menu)

			for el in menu_el:
				menu[el.tag] = el.text

		retval = {}

		for menu_type, menu_group in groupby(menus, itemgetter('MenuType')):
			mt = retval[menu_type] = {}
			for culture, menu_items in groupby(menu_group, itemgetter('Culture')):
				mt[culture.replace('-', '_')] = list(menu_items)

		return retval

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not (user.SuperUser or user.WebDeveloper):
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'TemplateID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		TemplateID = model_state.form.data['TemplateID']

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Manage Templates', request)
		return self._create_response_namespace(title, title, dict(id_name='TemplateID', id_value=TemplateID, route='admin_template', action='delete'), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not (user.SuperUser or user.WebDeveloper):
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'TemplateID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		TemplateID = model_state.form.data['TemplateID']

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_Template_d ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, TemplateID, request.dboptions.MemberID, user.Agency)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('admin_template_index', _query=[('InfoMsg', _('The Template has been successfully deleted.', request))])

		if result.Return == 3:
			self._error_page(_('Unable to delete Template: ', request) + result.ErrMsg)

		self._go_to_route('admin_template', action='edit', _query=[('ErrMsg', _('Unable to delete Template: ') + result.ErrMsg), ('TemplateID', TemplateID)])
