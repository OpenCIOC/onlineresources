<%doc>
=========================================================================================
 Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
=========================================================================================
</%doc>

<%inherit file="cioc.web:templates/master.mak"/>
<%!
from datetime import datetime
from json import dumps as j
from cioc.core import constants as const, googlemaps, clienttracker, vacancyscript, detailsscript, gtranslate
from cioc.core.format import textToHTML
from cioc.core.modelstate import convert_options

from webhelpers2.html import tags
%>
<%
viewdata = request.viewdata
cicview = viewdata.cic
volview = viewdata.vol
makeLink = request.passvars.makeLink
makeDetailsLink = request.passvars.makeDetailsLink
%>

%if not viewdata.PrintMode:
${gtranslate.render_ui(request)}
%endif

%if not viewdata.PrintMode and (search_list_top or (request.user.cic and views)):

<div class="row clear-line-below">
	%if search_list_top:
	<!-- Other Search Results -->
	<div class="col-sm-12 ${' col-md-6 col-lg-8' if request.user.cic and views else ''}">
		<div id="search-list-top" class="content-bubble">
			<div class="row">${search_list_top}</div>
		</div>
	</div>
	%endif
	%if request.user.cic and views:
	<!-- Change Views -->
	<div class="col-sm-12 ${' col-md-6 col-lg-4' if search_list_top else ''}">
		<div class="content-bubble padding-xs">
			<form class="form" action="${request.url}" id="change_view_form" name="ChangeViewForm">
				<div class="text-right">
					<span style="display: none">
						%for key, value in request.params.items():
						%if key != 'UseCICVwTmp' and key != 'InlineResults':
						<input type="hidden" name="${key}" value="${value}">
						%endif
						%endfor
					</span>
					<div class="input-group">
						${tags.select('UseCICVwTmp', None, convert_options([('', '')] + list(map(tuple, views))), class_="form-control")}
						<div class="input-group-btn">
							<button class="btn" type="submit">${_('Preview in View')}</button>
						</div>
					</div>
				</div>
			</form>
		</div>
	</div>
	%endif
</div>
%endif

<%
now = datetime.now()
user = request.user
cicuser = user.cic
%>

<!-- Record Admin Header -->
<div class="record-details">
	<div class="RecordDetailsHeader TitleBox">
		<div class="row">
			<div class="col-sm-${'8' if logo_link is not None else '12'}" ">
				<h2>${org_level_1_linked}</h2>
				%if org_level_2to5_linked:
				<h3>${org_level_2to5_linked}</h3>
				%endif
				%if location_name_linked:
				<h3>${_('Site:')} ${location_name_linked}</h3>
				%endif
				%if service_levels_linked:
				<h3>${_('Service:')} ${service_levels_linked}</h3>
				%endif
			</div>
			%if logo_link is not None:
			<div class="hidden-xs col-sm-4 text-right">${logo_link|n}</div>
			%endif
		</div>
	</div>

	<div class="record-details-action">
		%if not viewdata.PrintMode:
		<!-- Quick Access Record Menu -->
		<div class="HideListUI clear-line-below text-center">
			${clienttracker.my_list_details_add_record(request, record.NUM)}
			<a role="button" class="btn btn-info" href="${feedback_link}">
				<span class="fa fa-edit" aria-hidden="true"></span> ${_('Suggest Update')}
			</a>
			${other_langs_links}

			%if request.dboptions.UseVOL and cicview.VolunteerLink:
			%if record.HAS_VOL:
			<a role="button" class="btn btn-info" href="${makeLink('~/volunteer/results.asp',num_link)}">
				<span class="fa fa-users" aria-hidden="true"></span> ${_('Volunteer Opportunities')}
			</a>
			%endif
			% if volview.SuggestOpLink:
			<a role="button" class="btn btn-info hidden-xs hidden-sm" href="${makeLink('~/volunteer/entryform.asp' if request.user.vol.CanAddRecord else '~/volunteer/feedback.asp',num_link)}">
				<span class="fa fa-plus" aria-hidden="true"></span><span class="fa fa-user" aria-hidden="true"></span> ${_('New Volunteer Opportunity') if request.user.vol.CanAddRecord else _('Suggest a Volunteer Opportunity')}
			</a>
			%endif
			%endif

			%if (request.user or request.dboptions.PrintModePublic) and cicview.PrintTemplate:
			<a role="button" class="btn btn-info hidden-xs" href="${makeDetailsLink(num, 'PrintMd=on&UseCICVwTmp=' + request.params.get(" UseCICVwTmp", '' ))}" target="_BLANK">
				<span class="fa fa-print" aria-hidden="true"></span>
				${_('Print Version')}${'' if request.user else ' (' + _('New Window') + ')'}
			</a>
			%endif

			%if cicview.AllowPDF:
			<a role="button" class="btn btn-info hidden-xs hidden-sm" href="${makeDetailsLink(num + '/pdf', 'UseCICVwTmp=' + request.params.get('UseCICVwTmp', ''))}" target="_BLANK">
				<span class="fa fa-file-pdf-o" aria-hidden="true"></span>
				${_('PDF Version')}${'' if request.user else ' (' + _('New Window') + ')'}
			</a>
			%endif

			%if request.user.cic.FeedbackAlert:
			%if record.HAS_FEEDBACK:
			<a role="button" class="btn btn-info btn-alert-border-thick" href="${makeLink('~/revfeedback_view.asp',num_number_link)}">${_('CHECK FEEDBACK')}</a>
			%endif
			%if record.HAS_PUB_FEEDBACK:
			<span class="AlertBubble">${_('CHECK PUB FEEDBACK')}</span>
			%endif
			%endif

			%if request.user:
			${reminder_notice}
			%endif

			%if record.NON_PUBLIC and request.user:
			<span class="AlertBubble">${_('NON PUBLIC')}</span>
			%endif

			%if record.DELETION_DATE:
			%if record.DELETION_DATE <= now:
			<span class="AlertBubble">${_('DELETED')}</span>
			%elif request.user:
			<span class="AlertBubble">${_('TO BE DELETED')}</span>
			%endif
			%endif

		</div>

		%if nav_dropdown:
		<!-- Action Menu -->
		<div class="form form-group">
			<div class="input-group">
				<div class="input-group-addon">
					<label for="ActionList">${_('Action:')}</label>
				</div>
				<select name="ActionList" id="ActionList" onchange="do_drop_down_navigation()" class="form-control">
					<option selected></option>
					${nav_dropdown}
				</select>
			</div>
		</div>
		%endif
		%endif

		<div class="${'record-details-top-border' if (request.user.cic and not viewdata.PrintMode) else ''}">
			<div class="row">
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Record #:')}</strong>
					${record.NUM}
				</div>
				%if cicview.LastModifiedDate:
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Last Modified:')}</strong>
					<span class="NoWrap">${format_date(record.MODIFIED_DATE, if_none=_('Unknown'))}</span>
				</div>
				%endif
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Last Full Update:')}</strong>
					<span class="NoWrap">${format_date(record.UPDATE_DATE, if_none=_('Unknown'))}</span>
				</div>
				%if cicview.DataMgmtFields:
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Update Schedule:')}</strong>
					<span class="NoWrap ${'Alert' if record.UPDATE_SCHEDULE is None or now > record.UPDATE_SCHEDULE else ''}">${format_date(record.UPDATE_SCHEDULE, if_none=_('Unknown'))}</span>
				</div>
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Record Owner:')}</strong>
					${record.RECORD_OWNER}
				</div>
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Date Created:')}</strong>
					<span class="NoWrap">${format_date(record.CREATED_DATE, if_none=_('Unknown'))}</span>
				</div>
				%if record.DELETION_DATE:
				<div class="col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Date Deleted:')}</strong>
					<span class="NoWrap">${format_date(record.DELETION_DATE, if_none=_('N/A'))}</span>
				</div>
				%endif
				%if request.user.cic.CanRequestUpdate:
				<div class="${'' if record.EMAIL_UPDATE_DATE else 'hidden-xs '}col-sm-4 col-md-3 record-details-admin-fields">
					<strong>${_('Last Email:')}</strong>
					<span class="NoWrap">${format_date(record.EMAIL_UPDATE_DATE, if_none=_('N/A'))}</span>
				</div>
				%endif
				%endif
				%if cicview.SocialMediaShare and not inline_results and not viewdata.PrintMode:
				<div class="col-sm-4 col-md-3 hidden-xs record-details-admin-fields HideNoJs">
					<table border="0" class="NoBorder">
						<tr>
							<td><span style="padding-right:0.5em; font-weight: bold;">${_('Share:')}</span></td>
							<td><div class="addthis_inline_share_toolbox"></div></td>
						</tr>
					</table>
				</div>
				%endif
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-${'8' if agency or org_locations or org_services or location_services or service_locations or similar_services else '12'}">
		%for group_name, fields in field_groups:
		<div class="panel panel-default">
			<div class="panel-heading">
				<h4>${group_name|n}</h4>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width inset-table responsive-table">
					%for field, field_contents in fields:
					%if field_contents:
					%if field.CheckMultiline or field.CheckHTML:
					<% field_contents = textToHTML(field_contents) %>
					%elif field.FieldName.endswith('_DATE') and not isinstance(field_contents, str):
					<% field_contents = format_date(field_contents) %>
					%endif
					<% field_display = field.FieldDisplay %>
					%if field.FieldName in ['ORG_LEVEL_1', 'ORG_LEVEL_2', 'ORG_LEVEL_3']:
					<% field_display = getattr(viewdata.cic, "OrgLevel%sName" % field.FieldName[-1], None) or field_display %>
					%endif
					<tr>
						<td class="field-label-cell">${field_display|n}</td>
						<td class="field-data-cell">${str(field_contents)|n}</td>
					</tr>
					%endif
					%endfor
				</table>
			</div>
		</div>
		%endfor
	</div>

	%if agency or org_locations or org_services or location_services or service_locations or similar_services:
	<%
	groups = [
	(_('Agency Overview'), [
	(agency, _('About This Agency'), True, None),
	(org_locations, _('Agency Locations'), False, {'OLSCode': 'SITE', 'ORGNUM': record.ORG_NUM or record.NUM}),
	(org_services, _('Agency Services'), False, {'OLSCode': 'SERVICE', 'ORGNUM': record.ORG_NUM or record.NUM})
	]), (_('Services at this Location'), [
	(location_services, _(' other Service(s) at this Location') if record.IS_SERVICE else _(' Service(s) at this Location'), True, {'ORGNUM': record.ORG_NUM or record.NUM, 'LL1': (record.LOCATION_NAME or u'').strip()})
	]), (_('Locations for this Service'), [
	(service_locations, _(' other Location(s) for this Service') if record.IS_SITE else _(' Location(s) for this Service'), not record.IS_SITE, {'SERVICENUM': record.NUM})
	]), (_('Similar Service(s)'), [
	(similar_services, _(' Similar Service(s) from this Agency'), False, {'ORGNUM': record.ORG_NUM or record.NUM, 'SL1': record.SERVICE_NAME_LEVEL_1})
	])
	]

	makeLink = request.passvars.makeLink
	%>
	<div class="col-md-4">
		%for j, (section, group) in enumerate(groups):
		%if any(x[0] for x in group):
		<div class="agency-overview">
			<div class="TitleBox RecordDetailsHeader">
				<h3>${section}</h3>
			</div>
			%for i, (records, title, force_open, search_url) in enumerate(group):
			%if records:
			<div class="related-records">
				<div class="RevTitleBox related-row">
					${len([x for x in records if not x.Deleted]) if j or i else ''} ${title}
					%if (j or i):
					%if not force_open:
					<a href="${makeLink('~/results.asp', search_url)}" class="show-toggle RevTitleText">[${_('Show Listings')}]</a>
					%endif
					%if request.user and not viewdata.PrintMode:
					<a href="${makeLink('~/results.asp', search_url)}" target="_blank" class="RevTitleText"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17" height="14" border="0" title="${_('Search in New Window')}"></a>
					%endif
					%endif
				</div>
				<div class="details"
						%if (j or i) and not force_open:
						style="display: none;"
						%endif
					 >
					<% deleted_seen = False %>
					%for related_record in records:
					%if related_record.Deleted and not deleted_seen:
					<% deleted_seen = True %>
					<div class="FieldLabelLeft related-row hidden-print"><a href="#" class="deleted-toggle Alert">[${_('Show Deleted')}]</a></div>
					<div class="deleted-records" style="display: none">
						%endif
						<div class="FieldLabelLeft related-row${' AlertStrike' if related_record.Deleted else ''}" ${'title="%s" ' % related_record.NUM if not related_record.InView and related_record.NUM != record.NUM else ' '|n}>
							%if related_record.NUM == record.NUM:
							&#x2794;
							%endif
							%if related_record.InView and related_record.NUM != record.NUM:
							<a href="${makeDetailsLink(related_record.NUM)}">${related_record.ORG_NAME|n}</a>
							%else:
							${related_record.ORG_NAME|n}
							%endif
						</div>
						%if related_record.SUMMARY and related_record.InView:
						<div class="record-summary related-row">
							%if related_record.NON_PUBLIC and request.user:
							<div class="Alert NoWrap SmallNote">${_('NON PUBLIC')}</div>
							%endif
							${str(related_record.SUMMARY if not related_record.CheckHTML else textToHTML(related_record.SUMMARY))|n}
						</div>
						%endif
						%endfor
						%if deleted_seen:
					</div>
					%endif
				</div>
			</div>
			%endif
			%endfor
		</div>
		%endif
		%endfor
	</div>
	%endif
</div>

%if request.user and not viewdata.PrintMode and search_list_bottom:
<div id="search-list-bottom" class="content-bubble">
	<div class="row">
		${search_list_bottom}
	</div>
</div>
%endif

%if request.user and not viewdata.PrintMode:
<div id="reminder-dialog" style="display: none;">
	<div id="existing-reminders-page">
	</div>
</div>
<div id="reminder-edit-dialog" style="display: none;">
</div>
%endif

<% request.language.setSystemLanguage(restore_culture) %>

<%def name="bottomjs()">
<%
request.language.setSystemLanguage(cur_culture)
makeLink = request.passvars.makeLink
viewdata = request.viewdata
cicview = request.viewdata.cic
%>
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/details.js')}

<script type="text/javascript">
	(function () {
		window['initialize'] = function () {
			var $ = jQuery
			${ vacancyscript.vacancy_script(request) | n }
			init_cached_state();
			%if request.user:
				$('#ActionList option').prop('selected', false);
			initialize_reminders(${ _("Reminders")| j}, ${ makeLink("~/jsonfeeds/users") | j },
					${ makeLink("~/reminders", "NUM=" + num) | j },
					${ makeLink("~/reminders/dismiss/IDIDID") | j },
					${ _(': ') | j },
					${ _('[read more]') | j }, ${ _('[less]') | j },
					${ _('Loading...') | j },
					${ makeLink("~/reminders/IDIDID/delete") | j },
					${ _('Not Found') | j });
			% endif
			%if not inline_results and googlemaps.hasGoogleMapsAPI(request):
		initialize_record_maps(${ googlemaps.getGoogleMapsKeyArg(request) | j }, ${ cur_culture| j})
		% endif
	restore_cached_state();

			${ detailsscript.details_sidebar_script(request) | n }
};
	$(initialize);
}) ();
%if cicview.SocialMediaShare and not inline_results:
	var addthis_exclude = 'print';
	var addthis_config = {
		ui_language: ${ cur_culture| j}
}
% endif
</script>
%if cicview.SocialMediaShare and not inline_results and not viewdata.PrintMode:
<script type="text/javascript" src="https://s7.addthis.com/js/250/addthis_widget.js#pubid=ra-4f7b02c913a929bb"></script>
%endif
<% request.language.setSystemLanguage(restore_culture) %>
</%def>
