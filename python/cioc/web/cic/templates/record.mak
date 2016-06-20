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

from webhelpers.html import tags
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
	<form action="${request.url}" id="change_view_form" name="ChangeViewForm">
		<div class="cioc-grid-row">
			%if search_list_top:
			<div class="cioc-col-sm-6"><div id="search-list-top"> ${search_list_top}</div></div>
			%endif
			%if request.user.cic and views:
				<div class="form-inline-always ${'cioc-col-sm-offset-6' if not search_list_top else ''} cioc-col-sm-6 change-view-box">
					<span style="display: none">
						%for key, value in request.params.items():
							%if key != 'UseCICVwTmp' and key != 'InlineResults':
								<input type="hidden" name="${key}" value="${value}">
							%endif
						%endfor
					</span>
					${tags.select('UseCICVwTmp', None, [('', '')] + map(tuple, views), class_="form-control")} <input type="submit" value="${_('Change View (Temp.)')}" class="btn btn-default">
				</div> <!-- .cioc-col-md-6 -->
			%endif
		</div> <!-- .cioc-grid-row -->
	</form> <!-- #change_view_form -->
%endif
<div class="cioc-grid-row">
	%if agency or org_locations or org_services or location_services or service_locations or similar_services:
	<div class="cioc-col-md-8">
	%else:
	<div class="cioc-col-md-12">
	%endif
		<div class="record-details">
			<div class="TitleBox RecordDetailsHeader ${'clearfix' if logo_link is not None else ''}">
			%if logo_link is not None:
				<div style="float:right;">${logo_link|n}</div>
			%endif
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
			</div> <!-- .TitleBox.RecordDetailsHeader -->
			<% now = datetime.now() %>


			<div class="record-details-action">
				<%
				user = request.user
				cicuser = user.cic
				%>
				%if not viewdata.PrintMode:
					<div class="record-details-action-header">
					<div class="record-details-action-bar HideListUI clear-line-below">

					${clienttracker.my_list_details_add_record(request, record.NUM)}

					<span class="NoWrap"><a class="NoLineLink" href="${feedback_link}"><img src="/images/edit.gif" aria-hidden="true" border="0"> ${_('Suggest Update')}</a></span>
					${other_langs_links}
					%if request.dboptions.UseVOL and cicview.VolunteerLink:
						%if record.HAS_VOL:
							| <span class="NoWrap"><a class="NoLineLink" href="${makeLink('~/volunteer/results.asp',num_link)}"><img src="/images/handshake.gif" aria-hidden="true" border="0"> ${_('Volunteer Opportunities')}</a></span>
						%endif
						% if volview.SuggestOpLink and not request.user.vol.CanAddRecord:
							| <span class="NoWrap"><a class="NoLineLink" href="${makeLink('~/volunteer/feedback.asp',num_link)}"><img src="/images/new.gif" aria-hidden="true" border="0"> ${_('Suggest New Volunteer Opportunity')}</a></span>
						%endif
					%endif
					%if (request.user or request.dboptions.PrintModePublic) and cicview.PrintTemplate:
						| <span class="NoWrap"><a class="NoLineLink" href="${makeDetailsLink(num, 'PrintMd=on&UseCICVwTmp=' + request.params.get("UseCICVwTmp", ''))}" target="_BLANK"><img src="/images/printer.gif" aria-hidden="true" border="0"> ${_('Print Version (New Window)')}</a></span>
					%endif
					%if cicview.AllowPDF:
						| <span class="NoWrap"><a class="NoLineLink" href="${makeDetailsLink(num + '/pdf', 'UseCICVwTmp=' + request.params.get('UseCICVwTmp', ''))}" target="_BLANK"><img src="/images/pdf.gif" aria-hidden="true" border="0"> ${_('PDF (New Window)')}</a></span>
					%endif

					%if record.NON_PUBLIC and request.user:
						| <span class="Alert NoWrap">${_('NON PUBLIC')}</span>
					%endif
					%if record.DELETION_DATE:
						%if record.DELETION_DATE <= now:
							| <span class="Alert">${_('DELETED')}</span>
						%elif request.user:
							| <span class="Alert NoWrap">${_('TO BE DELETED')}</span>
						%endif
					%endif
					%if request.user.cic.FeedbackAlert:
						%if record.HAS_FEEDBACK:
							| <a class="Alert NoLineLink NoWrap" href="${makeLink('~/revfeedback_view.asp',num_number_link)}">${_('CHECK FEEDBACK')}</a>
						%endif
						%if record.HAS_PUB_FEEDBACK:
							| <span class="Alert NoWrap">${_('CHECK PUB FEEDBACK')}</span>
						%endif
					%endif

					%if request.user:
					  ${reminder_notice}
					%endif


					</div> <!-- .HideListUI -->



				%if nav_dropdown:
				<span class="form-inline-always">
					<div class="form-group">
						<label for="ActionList">${_('Action:')}</label>
						<select name="ActionList" id="ActionList" onchange="do_drop_down_navigation()" class="form-control">
							<option selected></option>
							${nav_dropdown}
						</select>
					</div>
				</span>
				%endif

				%if cicview.SocialMediaShare and not inline_results:
				<div class="new-share-wrapper HideNoJs">
					<div class="new-share-label">${_('Share:')}</div>
					<div class="addthis_toolbox addthis_default_style addthis_20x20_style new-share-toolbox" addthis:url="${request.host_url}${request.passvars.makeDetailsLink(num)}">
						<a class="addthis_button_preferred_1"></a>
						<a class="addthis_button_preferred_2"></a>
						<a class="addthis_button_preferred_3"></a>
						<a class="addthis_button_preferred_4"></a>
						<a class="addthis_button_compact"></a>
					</div>
				</div> <!-- .new-share-wrapper -->
				%endif
				</div>
				%endif # not print mode

				<table class="NoBorder record-metadata cell-padding-4" style="padding: 0">
					<tr>
						<td><strong>${_('Record #:')}</strong> ${record.NUM}</td>
					%if cicview.LastModifiedDate:
						<td><strong>${_('Last Modified:')}</strong> <span class="NoWrap">${format_date(record.MODIFIED_DATE, if_none=_('Unknown'))}</span></td>
					%endif
						<td><strong>${_('Last Full Update:')}</strong> <span class="NoWrap">${format_date(record.UPDATE_DATE, if_none=_('Unknown'))}</span></td>
					%if cicview.DataMgmtFields:
						<td><strong>${_('Update Schedule:')}</strong> <span class="NoWrap ${'Alert' if record.UPDATE_SCHEDULE is None or now > record.UPDATE_SCHEDULE else ''}">${format_date(record.UPDATE_SCHEDULE, if_none=_('Unknown'))}</span></td>
						%if not cicview.LastModifiedDate and request.user.cic.CanRequestUpdate:
							<td>&nbsp;</td>
						%endif
					%endif
					</tr>
					%if request.viewdata.cic.DataMgmtFields:
						<tr>
							<td><strong>${_('Record Owner:')}</strong> ${record.RECORD_OWNER}</td>
							<td><strong>${_('Date Created:')}</strong> <span class="NoWrap">${format_date(record.CREATED_DATE, if_none=_('Unknown'))}</span></td>
							<td><strong>${_('Date Deleted:')}</strong> <span class="NoWrap">${format_date(record.DELETION_DATE, if_none=_('N/A'))}</span></td>

						%if request.user.cic.CanRequestUpdate:
							<td><strong>${_('Last Email:')}</strong> <span class="NoWrap">${format_date(record.EMAIL_UPDATE_DATE, if_none=_('N/A'))}</span></td>
						%elif request.viewdata.cic.LastModifiedDate:
							<td>&nbsp;</td>
						%endif
						</tr>
					%endif
				</table>

			</div> <!-- record-details-action -->
			

			<table class="BasicBorder cell-padding-3 record-data">
			%for group_name, fields in field_groups:
				<tr><th class="RevTitleBox field-group-header" colspan="2">${group_name|n}</th></tr>
					%for field, field_contents in fields:
						%if field_contents:
							%if field.CheckMultiline or field.CheckHTML:
								<% field_contents = textToHTML(field_contents) %>
							%elif field.FieldName.endswith('_DATE') and not isinstance(field_contents, basestring):
								<% field_contents = format_date(field_contents) %>
							%endif
							<% field_display = field.FieldDisplay %>
							%if field.FieldName in ['ORG_LEVEL_1', 'ORG_LEVEL_2', 'ORG_LEVEL_3']:
								<% field_display = getattr(viewdata.cic, "OrgLevel%sName" % field.FieldName[-1], None) or field_display %>
							%endif
							<tr>
								<td class="FieldLabelLeft">${field_display|n}</td>
								<td class="field-detail clearfix">${unicode(field_contents)|n}</td>
							</tr>
						%endif
					%endfor
			%endfor
			</table>

		</div> <!-- .record-details -->
	</div> <!-- .cioc-col-sm-8 -->

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
	<div class="cioc-col-md-4">
		%for j, (section, group) in enumerate(groups):
		%if any(x[0] for x in group):
		<div class="agency-overview">
			<div class="TitleBox RecordDetailsHeader">
				<h3>${section}</h3>
			</div>
			%for i, (records, title, force_open, search_url) in enumerate(group):
				%if records:
				<div class="related-records">
					<div class="RevTitleBox related-row">${len([x for x in records if not x.Deleted]) if j or i else ''} ${title}
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
					<div class="FieldLabelLeft related-row${' AlertStrike' if related_record.Deleted else ''}" ${'title="%s"' % related_record.NUM if not related_record.InView and related_record.NUM != record.NUM else ''|n}>
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
						${unicode(related_record.SUMMARY if not related_record.CheckHTML else textToHTML(related_record.SUMMARY))|n}
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
	</div> <!-- cioc-col-sm-4 -->
	%endif
</div> <!-- .cioc-grid-row -->

%if request.user and not viewdata.PrintMode and search_list_bottom:
<p>
	<span id="search-list-bottom">${search_list_bottom}</span>
</p>
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
%if not inline_results:
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
%endif
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/details.js')}


<script type="text/javascript">
(function() {
window['initialize'] = function() {
	var $ = jQuery
	${vacancyscript.vacancy_script(request)|n}
	init_cached_state();
	%if request.user:
	$('#ActionList option').prop('selected', false);
	initialize_reminders(${_("Reminders")|j}, ${makeLink("~/jsonfeeds/users")|j},
			${makeLink("~/reminders", "NUM=" + num)|j},
			${makeLink("~/reminders/dismiss/IDIDID")|j},
			${_(': ')|j},
			${_('[read more]')|j}, ${_('[less]')|j},
			${_('Loading...')|j},
			${makeLink("~/reminders/IDIDID/delete")|j},
			${_('Not Found')|j});
	%endif
%if not inline_results and googlemaps.hasGoogleMapsAPI(request):
	initialize_record_maps(${googlemaps.getGoogleMapsKeyArg(request)|j}, ${cur_culture|j})
%endif
	restore_cached_state();

	${detailsscript.details_sidebar_script(request)|n}
};
$(initialize);
})();
%if cicview.SocialMediaShare and not inline_results:
var addthis_exclude = 'print';
var addthis_config = {
	ui_language: ${cur_culture|j}
}
%endif
</script>
%if cicview.SocialMediaShare and not inline_results and not viewdata.PrintMode:
<script type="text/javascript" src="https://s7.addthis.com/js/250/addthis_widget.js#pubid=ra-4f7b02c913a929bb"></script>
%endif
<% request.language.setSystemLanguage(restore_culture) %>
</%def>


