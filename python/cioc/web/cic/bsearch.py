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

import os
import logging
import itertools

from markupsafe import Markup
from webhelpers.html import tags

from cioc.core import template, viewbase, i18n, constants as const
from cioc.web.cic.viewbase import CicViewBase
from cioc.web.gbl.icons import make_icon_html
from cioc.core.browselist import makeAlphaList, makeAlphaListItems
from pyramid.view import view_config

from .csearch import ChildCareSearch

_system_layout_dir = template._system_layout_dir
encode_link_values = template.encode_link_values

gettext = i18n.gettext

log = logging.getLogger(__name__)


class LayoutSearch(object):
	def __init__(self, request, template_values, search_info, topic_searches, quick_searches, viewslist, menu_items_custom, quicklist, communities, languages, csearchform):
		self.request = request
		self.template_values = template_values
		self.search_info = search_info
		self.topic_searches = topic_searches
		self.quick_searches = quick_searches
		self.viewslist = viewslist
		self.menu_items_custom = menu_items_custom
		self.quicklist = quicklist
		self.communities = communities
		self.languages = languages
		self.csearchform = csearchform

	def __call__(self, search_form, **kwargs):
		if not self.template_values:
			return ''

		request = self.request

		_ = lambda x: gettext(x, request)

		passvars = request.passvars
		use_cic = request.dboptions.UseCIC
		search_info = self.search_info
		topic_searches = self.topic_searches
		quick_searches = self.quick_searches
		user = request.user
		cic_user = user and user.cic
		viewdata = request.viewdata.cic
		makeLink = passvars.makeLink

		browse_row_tmpl = u'''<tr><th class="RevTitleBox" colspan="2">%s</th></tr>
							<tr><td align="center" colspan="2">%s</td></tr>'''

		browse = []
		browse_org_items = []
		browse_subject_items = []
		browse_org_title = ''
		if search_info.BSrchBrowseByOrg:
			browse_org_title = viewdata.BrowseByOrg or _('Browse by Organization')
			browse.append(browse_row_tmpl % (browse_org_title,
						makeAlphaList(True, "browsebyorg.asp", "MenuText", request)))
			browse_org_items = makeAlphaListItems(True, "browsebyorg.asp", request)

		if use_cic and viewdata.UseThesaurusView:
			browse.append(browse_row_tmpl % (_('Browse by Subject'),
						makeAlphaList(False, "browsebysubj.asp", "MenuText", request)))
			browse_subject_items = makeAlphaListItems(False, "browsebysubj.asp", request)

		if browse:
			browse = ''.join(browse)
		else:
			browse = None

		service_category = None
		service_category_list = None
		if use_cic and viewdata.UseTaxonomyView:
			if cic_user:
				service_category = [
					(makeLink('servcat.asp'), '<span class="glyphicon glyphicon-th" aria-hidden="true"></span> ' + _('Browse by Service Category')),
					(makeLink('tax.asp'), '<span class="glyphicon glyphicon-sort-by-attributes" aria-hidden="true"></span> ' + _('Basic Taxonomy Search')),
					(makeLink('taxsrch.asp'), '<span class="glyphicon glyphicon-filter" aria-hidden="true"></span> ' + _('Advanced Taxonomy Search'))
				]

				serv_cat_item_tmpl = '<li><a href="%s">%s</a></li>'

				service_category = u'<ul id="service-category-staff" class="nav nav-pills nav-stacked">%s</ul>' % \
					''.join(serv_cat_item_tmpl % x for x in service_category)

				service_category_list = service_category
			else:
				service_category = (u'%s <a href="%s">%s</a>' %
						(viewdata.FindAnOrgBy or _(u'Find an Organization or Program by type of service:'),
						makeLink('servcat.asp'), _(u'Browse by Service Category')))

				serv_cat_link_tmpl = makeLink('servcat.asp', 'TC=TCTC').replace('TCTC', '{1}')
				serv_cat_icon_tmpl = u'<i class="fa fa-{}" aria-hidden="true"></i> '
				serv_cat_item_tmpl = u'<li><a href="%s">{0}{2}</a></li>' % serv_cat_link_tmpl

				with request.connmgr.get_connection() as conn:
					service_category_list = conn.execute('EXEC dbo.sp_TAX_Term_l_CdLvl1').fetchall()

				service_category_list = u'<ul id="service-category-list" class="nav nav-pills nav-stacked">%s</ul>' % \
					''.join(serv_cat_item_tmpl.format('' if not x.IconFA else serv_cat_icon_tmpl.format(x.IconFA), *x[:-1]) for x in service_category_list)

		menu_groups = {}
		for key, group in itertools.groupby(self.menu_items_custom, lambda x: x.MenuGroup):
			menu_groups[key] = list(group)

		menu_items_custom = [encode_link_values(x) for x in menu_groups.get(None, [])]

		Culture = request.language.Culture
		# main menu:
		other_langs = []
		if user or self.menu_items_custom:
			for key, val in viewdata.Cultures.iteritems():
				if key == Culture:
					continue
				httpvals = {}
				if key != passvars.DefaultCulture:
					httpvals['Ln'] = key
				other_langs.append(dict(Link=makeLink('~/', httpvals, ('Ln',)), Display=val))

		vol_link = None
		vol_link_text = None
		if user and request.dboptions.UseVOL and viewdata.VolunteerLink and Culture in request.viewdata.vol.Cultures:
			vol_link = makeLink('~/volunteer/')
			vol_link_text = _("Volunteer Menu")

		search_menu_items = []
		change_view = None
		dboptions = request.dboptions

		if user:
			if dboptions.UseCIC and cic_user and user.SavedSearchQuota:
				icon = u'<span class="glyphicon glyphicon-floppy-save" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('savedsearch.asp'), icon + _('Saved Search')))

			if cic_user and not cic_user.LimitedView and dboptions.UseCIC:
				icon = u'<span class="glyphicon glyphicon-print" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('printlist.asp'), icon + _('Print Records')))

			if dboptions.UseCIC and ((cic_user.ExportPermission and viewdata.HasExportProfile) or viewdata.HasExcelProfile):
				icon = u'<span class="glyphicon glyphicon-export" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('export.asp'), icon + _('Export')))

			if dboptions.UseCIC and cic_user.ImportPermission:
				icon = u'<span class="glyphicon glyphicon-import" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('import/import.asp', {'DM': const.DM_CIC}), icon + _('Import')))

			if cic_user.CanUpdatePubs == const.UPDATE_ALL and dboptions.UseCIC:
				icon = u'<span class="glyphicon glyphicon-book" aria-hidden="true"></span> '
				if cic_user.LimitedView:
					search_menu_items.append((makeLink('publication/edit', {'PB_ID': cic_user.PB_ID}), icon + _('Publications')))
				else:
					search_menu_items.append((makeLink('publication'), icon + _('Publications')))

			if cic_user.CanDeleteRecord:
				icon = u'<span class="glyphicon glyphicon-remove" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('delete_manage.asp'), icon + _('Deleted Records')))

			if cic_user.CanViewStats and dboptions.UseCIC:
				icon = u'<span class="glyphicon glyphicon-stats" aria-hidden="true"></span> '
				search_menu_items.append((makeLink('stats.asp'), icon + _('Statistics')))

			makeLinkAdmin = passvars.makeLinkAdmin

			if cic_user.CanManageUsers:
				icon = u'<span class="glyphicon glyphicon-lock" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('users.asp'), icon + _('Manage Users')))

			if cic_user.SuperUser:
				icon = u'<span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('download.asp', dict(DM=const.DM_CIC)), icon + _('Download')))
				icon = u'<span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('setup.asp'), icon + _('Setup')))

			if cic_user.WebDeveloper:
				icon = u'<span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> '
				search_menu_items.append((makeLinkAdmin('setup_webdev.asp'), icon + _('Setup')))

			icon = u'<span class="glyphicon glyphicon-user" aria-hidden="true"></span> '
			search_menu_items.append((makeLinkAdmin('account.asp'), icon + _('My Account')))

			icon = u'<span class="glyphicon glyphicon-log-out" aria-hidden="true"></span> '
			search_menu_items.append((makeLink('logout.asp'), icon + _('Logout')))

			search_menu_items = [dict(Link=l, Display=d) for l, d in search_menu_items]

			if self.viewslist:
				cv_select = tags.select('UseCICVw', None,
							[('', '')] + map(tuple, self.viewslist), class_="form-control")

				cv_params = ''.join(tags.hidden(n, value=v) for n, v in
						request.params.iteritems() if n != 'UseCICVw')

				cv_submit = tags.submit(None, value=_('Change View'))

				cv_namespace = dict(
					action=request.path, params=cv_params,
					title=_('Change View:'), select=cv_select,
					submit=cv_submit)
				change_view = u'''
				<form action="%(action)s">
				<div style="display:none;">
				%(params)s
				</div>
				%(select)s %(submit)s
				</form>''' % cv_namespace

		show_cic_search_form = any(getattr(search_info, x) for x in [
			'BSrchAges', 'BSrchLanguage', 'BSrchNUM', 'BSrchOCG', 'BSrchKeywords',
			'BSrchVacancy', 'BSrchVOL', 'BSrchWWW'])

		if not show_cic_search_form and request.dboptions.UseCIC:
			if self.quicklist:
				show_cic_search_form = True

		quick_searches = [{'URL': makeLink('~/' + qs.PageName, qs.QueryParameters), 'NAME': qs.Name, 'PROMOTE': qs.PromoteToTab} for qs in quick_searches]

		quick_searches_tab = [qs for qs in quick_searches if qs['PROMOTE']]
		quick_searches_notab = [qs for qs in quick_searches if not qs['PROMOTE']]
		log.debug('quick_searches: %s, %s, %s', quick_searches, quick_searches_tab, quick_searches_notab)

		has_centre_section = show_cic_search_form or bool(topic_searches) or bool(quick_searches) or service_category \
			or (use_cic and search_info.CSrch) or (use_cic and viewdata.UseNAICSView) or browse or search_info.SearchCentreMessage

		if viewdata.QuickListWrapAt < 2:
			quicklist_col_class = 'col-sm-12'
			quicklist_clear_at = []
		elif viewdata.QuickListWrapAt == 2:
			quicklist_col_class = 'col-sm-6'
			quicklist_clear_at = [(2, ['sm', 'md', 'lg'])]
		elif viewdata.QuickListWrapAt == 3:
			quicklist_col_class = 'col-md-6 col-lg-4'
			quicklist_clear_at = [(2, ['sm', 'md']), (3, ['lg'])]
		else:
			quicklist_col_class = 'col-sm-6 col-md-4 col-lg-3'
			quicklist_clear_at = [(2, ['sm']), (3, ['md']), (4, ['lg'])]

		quick_list_clear_visible = lambda index: ' '.join('visible-' + y + '-block' for condition, sizes in quicklist_clear_at for y in sizes if (index + 1) % condition == 0)
		if viewdata.LimitedView or viewdata.QuickListPubHeadings:
			quicklist_split = []
			for key, group in itertools.groupby(self.quicklist, lambda x: x.Group):
				group_row = len(quicklist_split)
				if key is None:
					quicklist_split.extend([{'IDTYPE': 'GHID', 'ID': row.GH_ID, 'NAME': row.GeneralHeading, 'ICON': make_icon_html(None, row.IconNameFull, False, 'heading-icon'), 'HEADINGS': None, 'CLEAR_CLASS': quick_list_clear_visible(i)} for i, row in enumerate(group, group_row)])
				else:
					group = list(group)
					sub_heading = [{'IDTYPE': 'GHID', 'ID': row.GH_ID, 'NAME': row.GeneralHeading, 'ICON': make_icon_html(None, row.IconNameFull, False, 'sub-heading-icon')} for row in group]
					row = group[0]
					quicklist_split.append({'IDTYPE': 'GHID', 'ID': row.GroupID, 'IDLIST': ','.join(str(row.GH_ID) for row in group), 'NAME': row.Group, 'ICON': make_icon_html(None, row.IconNameFullGroup, False, 'heading-icon'), 'HEADINGS': sub_heading, 'CLEAR_CLASS': quick_list_clear_visible(group_row)})
		else:
			quicklist_split = [{'IDTYPE': 'PBID', 'ID': row.PB_ID, 'NAME': row.PubName or row.PubCode, 'ICON': None, 'HEADINGS': None,  'CLEAR_CLASS': quick_list_clear_visible(i)} for i, row in enumerate(self.quicklist)]

		namespace = {
			'TOGGLE_NAV_TITLE': gettext('Toggle navigation', request),

			'MENU_TITLE': search_info.MenuTitle or (_('Main Menu') if not not user else None),
			'MENU_MESSAGE': search_info.MenuMessage,
			'MENU_GLYPH': search_info.MenuGlyph,

			'BASIC_SEARCH': search_form() if show_cic_search_form else None,
			'BASIC_SEARCH_SECTION': show_cic_search_form,
			'BROWSE': browse,

			'BROWSE_BY_INDUSTRY_URL': makeLink('browsebyindustry.asp') if use_cic and viewdata.UseNAICSView else None,
			'NAICS_INTRO': gettext('Browse for a Business / Organization using the ', request),
			'NAICS_LINK_TEXT': gettext('North American Industry Classification System (NAICS)', request),
			'NAICS_TITLE': gettext('Industry Search', request),

			'BROWSE_TITLE': gettext('Browse', request),
			'BROWSE_ORG_ITEMS': browse_org_items,
			'BROWSE_ORG_TITLE': browse_org_title,
			'BROWSE_SUBJ_ITEMS': browse_subject_items,
			'BROWSE_SUBJ_TITLE': (_('Browse by Subject')),
			'CHANGE_VIEW': change_view,

			'CHILDCARE_SEARCH_TITLE': gettext('Child Care Search', request),
			'CHILDCARE_SEARCH_TEXT': search_info.CSrchText,
			'CHILDCARE_LINK_TEXT': gettext('Search for Child Care Resources', request),
			'CHILDCARE_SEARCH_URL': makeLink('csrch') if use_cic and search_info.CSrch else None,
			'CHILDCARE_SEARCH_FORM': self.csearchform,

			'CUSTOM_MENU_ITEMS': menu_items_custom,
			'CUSTOM_MENU_ITEMS_GROUP_1': [encode_link_values(x) for x in menu_groups.get(1, [])],
			'CUSTOM_MENU_ITEMS_GROUP_2': [encode_link_values(x) for x in menu_groups.get(2, [])],
			'CUSTOM_MENU_ITEMS_GROUP_3': [encode_link_values(x) for x in menu_groups.get(3, [])],

			'TOPIC_SEARCHES': [{'TAG': g, 'TITLE': t, 'DESC': d, 'LINK': request.passvars.route_path('cic_topicsearch', tag=g)} for g, t, d in topic_searches],
			'SEARCH_LEAD': gettext('Search ', request),

			'QUICK_SEARCHES': quick_searches,
			'QUICK_SEARCHES_TAB': quick_searches_tab,
			'QUICK_SEARCHES_NOTAB': quick_searches_notab,

			'LOGGED_IN': not not user,

			'NOT_LOGGED_IN': not user,
			'OTHER_LANGS': other_langs,

			'QUICK_SEARCH_TITLE': search_info.QuickSearchTitle or gettext('Quick Search', request),
			'QUICK_SEARCH_GLYPH': search_info.QuickSearchGlyph,

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

			'SEARCH_KEYWORD_TITLE': search_info.KeywordSearchTitle or gettext('New Search', request),
			'SEARCH_KEYWORD_GLYPH': search_info.KeywordSearchGlyph or 'search',
			'SEARCH_OTHER_TITLE': search_info.OtherSearchTitle or gettext('Explore', request),
			'SEARCH_OTHER_GLYPH': search_info.OtherSearchGlyph or 'hand-right',

			'SEARCH_MENU': not not (search_info.MenuMessage or user or self.menu_items_custom),
			'SEARCH_MENU_ITEMS': search_menu_items,

			'SERVICE_CATEGORY_TITLE': gettext('Service Categories', request),
			'SERVICE_CATEGORY': service_category,
			'SERVICE_CATEGORY_LIST': service_category_list,
			'SERVICE_CATEGORY_URL': makeLink('servcat.asp') if use_cic and viewdata.UseTaxonomyView and not cic_user else None,

			'VOL_LINK': vol_link,
			'VOL_LINK_TEXT': vol_link_text,

			'SEARCH_FORM_START': kwargs['searchform_start'],
			'HAS_KEYWORD_SEARCH': not not search_info.BSrchKeywords,
			'KEYWORD_SEARCH_BOX': kwargs['searchform_keyword'],
			'KEYWORD_SEARCH_IN': kwargs['searchform_in_values'],
			'COMMUNITY_SEARCH': kwargs['searchform_community'],
			'LANGUAGES_SEARCH': kwargs['searchform_languages'],
			'HAS_LANGUAGES_SEARCH': self.languages,
			'HAS_COMMUNITY_SEARCH': self.communities or (request.viewdata.cic.QuickListDropDown and request.viewdata.cic.OtherCommunity),

			'QUICKLIST': quicklist_split,
			'QUICKLIST_COL_CLASS': quicklist_col_class,
			'QUICKLIST_SEARCH': kwargs['searchform_quicklist'] if self.quicklist else None,
			'QUICKLIST_SEARCH_GROUPS': request.viewdata.cic.QuickListSearchGroups,
			'SEARCH_ALL_TITLE': gettext('Search all in this Category', request),

			'NUM_SEARCH': kwargs['searchform_num'] if search_info.BSrchNUM else None,
			'RECORD_NUMBER': gettext('Record #', request),

			'VOLUNTEER_ORG_URL': makeLink('results.asp', 'HasVol=on') if search_info.BSrchVOL else None,
			'VOLUNTEER_OPPORTUNITIES': gettext('Volunteer Opportunities', request),
			'ORGS_WITH_OPS': request.viewdata.cic.OrganizationsWithVolOps or _("Organizations with Volunteer Opportunities"),

			'MAKE_LINK': template.make_linkify_fn(request),
			'VIEWS_LIST': [{'VIEWTYPE': unicode(x.ViewType), 'VIEWNAME': x.ViewName} for x in self.viewslist] if self.viewslist else [],
			'CHANGE_VIEW_TITLE': _('Change View'),

			'HAS_CENTRE_SECTION': has_centre_section
		}

		namespace['HAS_LEFT_CONTENT'] = any(namespace[x] for x in ['SEARCH_ALERT', 'SEARCH_MENU', 'SEARCH_LEFT_CONTENT'])
		namespace['HAS_RIGHT_OR_SERVCAT'] = any(namespace[x] for x in ['SEARCH_RIGHT_CONTENT', 'SERVICE_CATEGORY'])

		return template.apply_html_values(self.template_values.SearchLayoutHTML or u'', namespace)


@view_config(route_name='cic_basic_search', renderer='cioc.web.cic:templates/bsearch.mak')
class BasicSearch(CicViewBase):
	def __init__(self, request, require_login=False):
		CicViewBase.__init__(self, request, require_login)

	def __call__(self):
		request = self.request
		dboptions = request.dboptions

		_ = lambda x: gettext(x, request)

		# To use this page, the software must be set up to use the CIC module
		# or the user must be logged in and the Volunteer module must be in use
		if not dboptions.UseCIC and not (dboptions.UseVOL and request.user):
			if dboptions.UseVOL:
				raise self._go_to_page('~/volunteer/')
			else:
				# We aren't using *any* module of the software - that's a problem!
				raise viewbase._security_failure()

		viewdata = request.viewdata
		cic_view = viewdata.cic

		layout_info = None
		menu_items_custom = None
		search_info = None
		topic_searches = None
		quick_searches = None
		communities = None
		ages = None
		vacancy_targets = None
		quicklist = None
		viewslist = None
		languages = None
		with request.connmgr.get_connection('admin' if request.user else None) as conn:
			preview_template_id = request.params.get('PreviewTemplateID')
			if preview_template_id:
				try:
					preview_template_id = int(preview_template_id)
				except ValueError:
					preview_template_id = None

			cursor = conn.execute('EXEC dbo.sp_CIC_View_s_BSrch ?', cic_view.ViewType)
			search_info = cursor.fetchone()

			cursor.nextset()

			topic_searches = cursor.fetchall()

			cursor.nextset()

			quick_searches = cursor.fetchall()

			cursor.close()

			sql = '''
				DECLARE @ViewType int = ?, @PreviewTemplateID int = ?, @MemberID int = ?
				EXEC dbo.sp_CIC_View_s_BSrch_Template @ViewType, @PreviewTemplateID
				EXEC dbo.sp_CIC_View_Community_l @ViewType
			'''
			args = [cic_view.ViewType, preview_template_id, request.dboptions.MemberID]
			if search_info.BSrchAges:
				sql += '\nEXEC dbo.sp_GBL_AgeGroup_l @MemberID, 0'

			if search_info.BSrchVacancy:
				sql += '\nEXEC dbo.sp_CIC_Vacancy_TargetPop_l @MemberID, 0, NULL'

			if search_info.BSrchLanguage:
				sql += '\nEXEC dbo.sp_GBL_Language_l @MemberID, 0, 1'

			if request.dboptions.UseCIC:
				if not (cic_view.LimitedView or cic_view.QuickListPubHeadings):
					sql += '\nEXEC dbo.sp_CIC_Publication_l @ViewType, 0, NULL'
				else:
					sql += '\nEXEC dbo.sp_CIC_GeneralHeading_l @MemberID,?,NULL,?,0,1'
					args.extend([cic_view.QuickListPubHeadings or cic_view.PB_ID, True if cic_view.CanSeeNonPublicPub is None else cic_view.CanSeeNonPublicPub])
			if request.user:
				sql += '\nEXEC dbo.sp_CIC_Views_l_Change @MemberID, ?, @ViewType'
				args.append(request.user.User_ID)

			cursor = conn.execute(sql, args)

			layout_info = cursor.fetchone()

			cursor.nextset()

			menu_items_custom = cursor.fetchall()

			cursor.nextset()

			communities = cursor.fetchall()

			if search_info.BSrchAges:
				cursor.nextset()
				ages = cursor.fetchall()

			if search_info.BSrchVacancy:
				cursor.nextset()
				vacancy_targets = cursor.fetchall()

			if search_info.BSrchLanguage:
				cursor.nextset()
				languages = cursor.fetchall()

			if request.dboptions.UseCIC:
				cursor.nextset()
				quicklist = cursor.fetchall()

			if request.user:
				cursor.nextset()
				viewslist = cursor.fetchall()

		if layout_info.SystemLayout and layout_info.LayoutHTMLURL:
			f = open(os.path.join(_system_layout_dir, layout_info.LayoutHTMLURL), 'rU')
			layout_info.SearchLayoutHTML = f.read().decode('utf8')
			f.close()

		focus = 'Search.STerms'
		if not search_info.BSrchKeywords:
			focus = ''

		title = cic_view.SearchTitleOverride or request.pageinfo.PageTitle or _("Organization / Program Search")
		distances = [2, 5, 10, 15, 25, 50, 100]
		located_near = [
			(x, _('Within %skm') % x)
			for x in distances
			if getattr(search_info, 'BSrchNear%s' % x)]

		namespace = self._create_response_namespace(
			title, title,
			dict(
				search_info=search_info, communities=communities, ages=ages, viewslist=viewslist,
				vacancy_targets=vacancy_targets, quicklist=quicklist, languages=languages, located_near=located_near
			), True, False, True, focus=focus, show_message=True)

		if search_info.CSrch and request.dboptions.UseCIC:
			csearch = ChildCareSearch(request)
			csearchform, mapsbottomjs, _ = csearch.childcare_form(dict(namespace), communities)
		else:
			csearchform = mapsbottomjs = ''

		namespace['makeSearchForm'] = LayoutSearch(request, layout_info, search_info, topic_searches, quick_searches, viewslist, menu_items_custom, quicklist, communities, languages, csearchform)
		if mapsbottomjs and '[CHILDCARE_SEARCH_FORM]' in layout_info.SearchLayoutHTML:
			namespace['mapsbottomjs'] = Markup(mapsbottomjs())
		else:
			namespace['mapsbottomjs'] = ''

		return namespace
