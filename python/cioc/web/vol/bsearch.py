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
import os
import itertools
from functools import partial

from markupsafe import Markup
from pyramid.view import view_config
from pyramid.decorator import reify
from webhelpers2.html import tags

from cioc.core import template, i18n, volprofileuser, constants as const
from cioc.web.vol.viewbase import VolViewBase
from cioc.core.browselist import makeAlphaList, makeAlphaListItems
from cioc.core.format import textToHTML
from cioc.core.modelstate import convert_options
from cioc.core.utils import read_file
import six
from six.moves import map
from six.moves import zip

_system_layout_dir = template._system_layout_dir
encode_link_values = template.encode_link_values

gettext = i18n.gettext

_option_templ = u'''<option value="{ID}">{Name}</option>'''
_whats_new_item_templ = u'''<dt class="position-title"><a href="%s">{POSITION_TITLE}</a> ({LAST_UPDATED})</dt> <dd class="organization-name">{ORG_NAME_FULL}</dd>'''
_popular_interest_item_templ = Markup('''<li><a href="%s">{InterestName}</a>&nbsp;<span class="badge">{UsageCount}</span></li>''')
_popular_org_item_templ = u'''<li><a href="%s">{ORG_NAME_FULL}</a>&nbsp;<span class="badge">{OpCount}</span></li>'''
_spotlight_template = u'''
<p class="update-date">{LAST_UPDATED}</p>
<h2 class="position-title">{POSITION_TITLE}</h2>
<p class="organization-name">{ORG_NAME_FULL}</p>'''
_spotlight_location_template = '''<h3><span class="glyphicon glyphicon-map-marker" aria-hidden="true"></span> %s</h3>
<p>{LOCATION}</p>'''
_spotlight_duties_template = '''<h3><span class="glyphicon glyphicon-ok-circle" aria-hidden="true"></span> %s</h3>
<p>{DUTIES}</p>
'''

def _generic_feed(request, item_template, sp, sp_args):
	with request.connmgr.get_connection() as conn:
		cursor = conn.execute('EXEC %s %s' % (sp, ','.join('?' * len(sp_args))), sp_args)
		cols = [t[0] for t in cursor.description]

		items = cursor.fetchall()

		return u''.join(item_template.format(**dict(zip(cols, x))) for x in items)

def make_commitmentlength_option_list(request):
	item_template = _option_templ
	return partial(_generic_feed, request, item_template, 'sp_VOL_CommitmentLength_OptionList', [request.MemberID])


def make_suitability_option_list(request):
	item_template = _option_templ
	return partial(_generic_feed, request, item_template, 'sp_VOL_Suitability_OptionList', [request.MemberID])


def make_community_option_list(request):
	item_template = _option_templ
	return partial(_generic_feed, request, item_template, 'sp_VOL_Community_OptionList', [request.viewdata.ViewType])


def make_whats_new_feed(request):
	item_template = _whats_new_item_templ % request.passvars.makeVOLDetailsLink('{VNUM}')
	return partial(_generic_feed, request, item_template, 'sp_VOL_WhatsNew_Feed', [request.viewdata.ViewType])


def make_popular_interest_feed(request):
	item_template = _popular_interest_item_templ % request.passvars.makeLink('~/volunteer/results.asp', 'AIID={AI_ID}')
	return partial(_generic_feed, request, item_template, 'sp_VOL_PopularInterest_Feed', [request.viewdata.ViewType])


def make_popular_org_feed(request):
	item_template = _popular_org_item_templ % request.passvars.makeLink('~/volunteer/results.asp', 'NUM={NUM}')
	return partial(_generic_feed, request, item_template, 'sp_VOL_PopularOrg_Feed', [request.viewdata.ViewType])


class SpotlightFeed(object):
	def __init__(self, request):
		self.request = request

	@reify
	def data(self):
		with self.request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_VOL_Spotlight_Feed ?', self.request.viewdata.ViewType)
			cols = [t[0] for t in cursor.description]

			return dict(zip(cols, cursor.fetchone()))

	def spotlight_content(self):
		request = self.request
		data = self.data
		tmpl = _spotlight_template
		if data['LOCATION']:
			tmpl += _spotlight_location_template % gettext('Location', request)
			data['LOCATION'] = textToHTML(data['LOCATION'])

		if data['DUTIES']:
			tmpl += _spotlight_duties_template % gettext('Duties', request)
			data['DUTIES'] = textToHTML(data['DUTIES'])

		return tmpl.format(**data)

	def spotlight_details_link(self):
		return self.request.passvars.makeVOLDetailsLink(self.data['VNUM'])


class LayoutSearch(object):
	def __init__(self, request, template_values, search_info, viewslist, menu_items_custom):
		self.request = request
		self.template_values = template_values
		self.search_info = search_info
		self.viewslist = viewslist
		self.menu_items_custom = menu_items_custom

	def __call__(self, search_form, search_menu, **kwargs):
		if not self.template_values:
			return ''

		request = self.request
		search_info = self.search_info
		_ = lambda x: gettext(x, request)

		browse_by_org = ''
		browse_by_org_items = []
		if search_info.BSrchBrowseByOrg:
			browse_by_org = u'''<tr><th class="RevTitleBox" colspan="2">%s</th></tr>
						<tr><td align="center" colspan="2">%s</td></tr>''' \
						% (_('Browse Organizations with Opportunities'),
							makeAlphaList(True, "browsebyorg.asp", "MenuText", request))
			browse_by_org_items = makeAlphaListItems(True, 'browsebyorg.asp', request)

		browse_by_interest = ''
		browse_op_items = []
		if search_info.BSrchBrowseByInterest:
			browse_op_items = makeAlphaListItems(False, 'browsebyinterest.asp', request)
			browse_by_interest = u'''
				<tr><th class="RevTitleBox" colspan="2">%s</th></tr>
				<tr><td align="center" colspan="2">%s</td></tr>
				''' % (_('Browse by Area of Interest'), makeAlphaList(False, "browsebyinterest.asp", "MenuText", request))

		browse = browse_by_org + browse_by_interest

		viewdata = request.viewdata.vol

		# main menu:
		Culture = request.language.Culture
		user = request.user
		passvars = request.passvars
		makeLink = passvars.makeLink
		vol_user = user and user.vol

		menu_groups = {}
		for key, group in itertools.groupby(self.menu_items_custom, lambda x: x.MenuGroup):
			menu_groups[key] = list(group)

		menu_items_custom = [encode_link_values(x) for x in menu_groups.get(None, [])]

		other_langs = []
		if user or self.menu_items_custom:
			for key, val in six.iteritems(viewdata.Cultures):
				if key == Culture:
					continue
				httpvals = {}
				if key != passvars.DefaultCulture:
					httpvals['Ln'] = key
				other_langs.append(dict(Link=makeLink('~/volunteer/', httpvals, ('Ln',)), Display=val))

		cic_link = None
		cic_link_text = None
		if user and Culture in request.viewdata.cic.Cultures:
			cic_link = makeLink('~/')
			cic_link_text = _("CIC Menu")

		search_menu_items = []
		change_view = None

		if user:
			if vol_user and user.SavedSearchQuota:
				icon = u'<span class="glyphicon glyphicon-floppy-save" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('savedsearch.asp'), icon + _('Saved Search')))

			if vol_user.CanDeleteRecord:
				icon = u'<span class="glyphicon glyphicon-remove" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('delete_manage.asp'), icon + _('Deleted Records')))

			if vol_user.CanManageReferrals:
				icon = u'<span class="glyphicon glyphicon-send" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('referral.asp'), icon + _('Referrals')))

			if vol_user.CanManageMembers:
				icon = u'<span class="glyphicon glyphicon-certificate" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('member.asp'), icon + _('Members')))

			if request.dboptions.UseVolunteerProfiles and vol_user.CanAccessProfiles:
				icon = u'<span class="glyphicon glyphicon-list-alt" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('profiles.asp'), icon + _('Volunteer Profiles')))

			if vol_user.CanViewStats:
				icon = u'<span class="glyphicon glyphicon-stats" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('stats.asp'), icon + _('Statistics')))

			makeLinkAdmin = passvars.makeLinkAdmin

			if vol_user.CanManageUsers:
				icon = u'<span class="glyphicon glyphicon-lock" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('users.asp'), icon + _('Manage Users')))

			if vol_user.SuperUser:
				icon = u'<span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('download.asp', dict(DM=const.DM_VOL)), icon + _('Download')))
				icon = u'<span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('setup.asp'), icon + _('Setup')))

			if vol_user.WebDeveloper:
				icon = u'<span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('setup_webdev.asp'), icon + _('Setup')))

			icon = u'<span class="glyphicon glyphicon-user" aria-hidden="true"></span> '
			search_menu_items.append((makeLinkAdmin('account.asp'), icon + _('My Account')))

			icon = u'<span class="glyphicon glyphicon-log-out" aria-hidden="true"></span> '
			search_menu_items.append((makeLink('~/logout.asp'), icon + _('Logout')))

			search_menu_items = [dict(Link=l, Display=d) for l, d in search_menu_items]

			if self.viewslist:
				cv_select = tags.select('UseVOLVw', None,
							convert_options([('', '')] + list(map(tuple, self.viewslist))))

				cv_params = ''.join(tags.hidden(n, value=v) for n, v in
						six.iteritems(request.params) if n != 'UseVOLVw')

				cv_submit = tags.submit(None, value=_('Change View'))

				cv_namespace = dict(
					action=request.path, params=cv_params,
					title=_('Change View:'), select=cv_select,
					submit=cv_submit)
				change_view = '''
				<form action="%(action)s">
				<div style="display:none;">
				%(params)s
				</div>
				%(title)s
				<br>%(select)s %(submit)s
				</form>''' % cv_namespace

		vol_search_menu = search_menu().strip()
		spotlight = None
		if search_info.HighlightOpportunity:
			spotlight = SpotlightFeed(request)

		namespace = {
			'BASIC_SEARCH': search_form if search_info.BSrchKeywords else None,
			'BASIC_SEARCH_SECTION': vol_search_menu and search_info.BSrchKeywords,
			'BROWSE': browse,
			'BROWSE_OP_ITEMS': browse_op_items,
			'BROWSE_OP_URL': makeLink('browsebyinterest.asp'),
			'BROWSE_ORG_ITEMS': browse_by_org_items,
			'BROWSE_ORG_URL': makeLink('browsebyorg.asp'),
			'CHANGE_VIEW': change_view,
			'CIC_LINK': cic_link,
			'CIC_LINK_TEXT': cic_link_text,
			'CUSTOM_MENU_ITEMS': menu_items_custom,
			'CUSTOM_MENU_ITEMS_GROUP_1': [encode_link_values(x) for x in menu_groups.get(1, [])],
			'CUSTOM_MENU_ITEMS_GROUP_2': [encode_link_values(x) for x in menu_groups.get(2, [])],
			'CUSTOM_MENU_ITEMS_GROUP_3': [encode_link_values(x) for x in menu_groups.get(3, [])],
			'WHATS_NEW_FEED': make_whats_new_feed(request) if search_info.BSrchWhatsNew else '',
			'WHATS_NEW_URL': makeLink('whatsnew.asp'),
			'POPULAR_INTEREST_FEED': make_popular_interest_feed(request) if search_info.BSrchBrowseByInterest else '',
			'POPULAR_ORG_FEED': make_popular_org_feed(request) if search_info.BSrchBrowseByOrg else '',
			'DURATION_OPTIONS': make_commitmentlength_option_list(request) if search_info.BSrchCommitmentLength else '',
			'COMMUNITY_OPTIONS': make_community_option_list(request) if search_info.BSrchCommunity or not search_info.BSrchCommitmentLength or not search_info.BSrchBrowseByOrg else '',
			'SUITABILITY_OPTIONS': make_suitability_option_list(request) if search_info.BSrchSuitableFor else '',
			'SPOTLIGHT_FEED': spotlight and spotlight.spotlight_content,
			'SPOTLIGHT_LINK': spotlight and spotlight.spotlight_details_link,
			'LOGGED_IN': not not user,
			'MENU_MESSAGE': search_info.MenuMessage,
			'MENU_TITLE': _('Main Menu'),
			'NOT_LOGGED_IN': not user,
			'OTHER_LANGS': other_langs,

			'SEARCH': gettext('Search', request),

			'SEARCH_ALERT_TITLE': search_info.SearchAlertTitle,
			'SEARCH_ALERT_GLYPH': search_info.SearchAlertGlyph,
			'SEARCH_ALERT': search_info.SearchAlertMessage,

			'SEARCH_LEFT_TITLE': search_info.SearchLeftTitle,
			'SEARCH_LEFT_GLYPH': search_info.SearchLeftGlyph,
			'SEARCH_LEFT_CONTENT': search_info.SearchLeftMessage,

			'SEARCH_CENTRE_TITLE': search_info.SearchCentreTitle,
			'SEARCH_CENTRE_GLYPH': search_info.SearchCentreGlyph,
			'SEARCH_CENTRE_CONTENT': search_info.SearchCentreMessage,

			'SEARCH_RIGHT_TITLE': search_info.SearchRightTitle,
			'SEARCH_RIGHT_GLYPH': search_info.SearchRightGlyph,
			'SEARCH_RIGHT_CONTENT': search_info.SearchRightMessage,

			'SEARCH_MENU': not not (search_info.MenuMessage or user or self.menu_items_custom),
			'SEARCH_MENU_ITEMS': search_menu_items,
			'SEARCH_PROMPT': (search_info.SearchPromptOverride or (_('Looking for Volunteer Opportunities%s?') % '[IN_COMMUNITY]')).replace('[IN_COMMUNITY]', ('' if not viewdata.AreaServed else ' '.join(('', _('in'), viewdata.AreaServed)))),

			'SEARCH_KEYWORD_TITLE': search_info.KeywordSearchTitle or gettext('Keyword Search', request),
			'SEARCH_KEYWORD_GLYPH': search_info.KeywordSearchGlyph or 'search',
			'SEARCH_OTHER_TITLE': search_info.OtherSearchTitle or gettext('Explore', request),
			'SEARCH_OTHER_GLYPH': search_info.OtherSearchGlyph or 'hand-right',
			'SEARCH_OTHER_MESSAGE': search_info.OtherSearchMessage,
			
			'VOL_SEARCH_MENU': vol_search_menu,
			'WHATS_NEW_ENABLED': search_info.BSrchWhatsNew,
			'BROWSE_INTERESTS_ENABLED': search_info.BSrchBrowseByInterest,
			'BROWSE_ORGS_ENABLED': search_info.BSrchBrowseByOrg,
			'HAS_SEARCH_AREA': search_info.BSrchKeywords or vol_search_menu or browse,
			'SEARCH_FORM_START': kwargs['searchform_start'],
			'HAS_KEYWORD_SEARCH': not not search_info.BSrchKeywords,
			'KEYWORD_SEARCH_BOX': kwargs['searchform_keyword'],
			'KEYWORD_SEARCH_IN': kwargs['searchform_in_values'],
			'PROFILE_LINKS': kwargs['searchform_profilelinks'],
			'MAKE_LINK': template.make_linkify_fn(request),
			'VIEWS_LIST': [{'VIEWTYPE': six.text_type(x.ViewType), 'VIEWNAME': x.ViewName} for x in self.viewslist] if self.viewslist else [],
			'CHANGE_VIEW_TITLE': _('Change View'),
		}
		namespace['HAS_LEFT_CONTENT'] = any(namespace[x] for x in ['SEARCH_ALERT', 'SEARCH_MENU', 'SEARCH_LEFT_CONTENT'])

		return template.apply_html_values(self.template_values.SearchLayoutHTML or u'', namespace)


@view_config(route_name='vol_basic_search')
class BasicSearch(VolViewBase):
	def __call__(self):
		request = self.request

		_ = lambda x: gettext(x, request)

		viewdata = request.viewdata
		vol_view = viewdata.vol

		request.vprofile_user = volprofileuser.VolProfileUser(request)

		layout_info = None
		search_info = None
		with request.connmgr.get_connection() as conn:
			preview_template_id = request.params.get('PreviewTemplateID')
			if preview_template_id:
				try:
					preview_template_id = int(preview_template_id)
				except ValueError:
					preview_template_id = None

			cursor = conn.execute('EXEC dbo.sp_VOL_View_s_BSrch_Template ?', vol_view.ViewType)

			layout_info = cursor.fetchone()

			cursor.nextset()

			menu_items_custom = cursor.fetchall()

			cursor.close()

			search_info = conn.execute('EXEC dbo.sp_VOL_View_s_BSrch ?', vol_view.ViewType).fetchone()

		if layout_info.SystemLayout and layout_info.LayoutHTMLURL:
			layout_info.SearchLayoutHTML = read_file(os.path.join(_system_layout_dir, layout_info.LayoutHTMLURL))

		viewslist = None
		if request.user:
			with request.connmgr.get_connection('admin') as conn:
				viewslist = conn.execute('EXEC dbo.sp_VOL_Views_l_Change ?,?,?', request.MemberID, request.user.User_ID, viewdata.ViewType).fetchall()

		focus = 'Search.STerms'
		if not search_info.BSrchKeywords:
			focus = ''

		return self._render_to_response(
			'cioc.web.vol:templates/bsearch.mak',
			request.pageinfo.PageTitle or _("Volunteer Opportunity Main Menu"),
			request.pageinfo.PageTitle or _("Volunteer Opportunity Main Menu"),
			dict(
				search_info=search_info,
				makeSearchForm=LayoutSearch(request, layout_info, search_info, viewslist, menu_items_custom)
			), True, False, True, focus=focus, show_message=True)
