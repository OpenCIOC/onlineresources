
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
<%!
from datetime import date
import json
import six

from markupsafe import Markup

from cioc.core import googlemaps as maps
from cioc.core.datesearch import add_months, add_years
%>

<%namespace file="cioc.web.cic:templates/searchcommon.mak" import="community_form,map_search_form" />

<%def name="childsearchform()">
<div id="csrch_top">
<form action="cresults.asp" method="get" id="EntryForm" name="EntryForm" ${' onSubmit="formNewWindow(this);"' if request.user else ''|n} class="form-horizontal">
<div style="display:none">
${request.passvars.cached_form_vals}
</div>
<div class="search-buttons">
	<input type="submit" value="${_('Search')}" class="btn btn-default">
	<input type="reset" value="${_('Clear Form')}" class="btn btn-default">
</div>

<div class="max-width-lg">
<table class="BasicBorder cell-padding-3 responsive-table form-table auto-fill-table">
%if communities:
<tr>
	<td class="field-label-cell">${_('Communities')}</td>
	<td class="field-data-cell"><span class="SmallNote">${_('If you do not select any values, all values will be searched.')}</span>
	<hr style="border: 1px dashed #999999">
	<div class="clear-line-below">
	${community_form(communities, request.viewdata.cic.OtherCommunity)}
	</div>
	</td>
</tr>
%endif
%if search_info.CSrchNear:
${map_search_form()}
%endif
<tr>
	<td class="field-label-cell">${_('Ages')}</td>
	<td class="field-data-cell"><span class="SmallNote">${_('If you do not select any values, all values will be searched.')}</span>
	<hr style="border: 1px dashed #999999">
	<p>${_('For the most accurate search, enter the date(s) of birth of the child(ren) requiring care:')}</p>
	%for i in range(4):
	<div class="row form-group">
		<label for="DOB${i}" class="control-label col-sm-4">${_('Date of Birth #%d') % (i + 1)}</label>
		<div class="col-sm-8 form-inline">
			<input type="text" name="DOB${i}" class="DatePicker form-control" id="DOB${i}"> (${_('e.g.')} ${format_date(date.today())})
		</div>
	</div>
	%endfor
	<hr style="border: 1px dashed #999999">
	<h4>${_('Are you searching for care for more than one child?')}</h4>
	<p class="clear-line-below">${renderer.radio("AgeType", id="AgeTypeOne", value='', label=Markup(_("Match programs that serve <strong>any one</strong> child's age")))}
	<br>${renderer.radio("AgeType", id="AgeTypeAll", value="A", label=Markup(_("Match only programs that can serve <strong>all</strong> the children")))}
	%if request.user:
	<br>${renderer.radio("AgeType", id="AgeTypeS", value="S", label=Markup(_("Match programs that serve <strong>child #</strong>")))}
		%for i in range(4):
		${renderer.radio("AgeTypeSpecific", value=six.text_type(i), checked=not i, id="AgeTypeSpecific%d" % i, label=six.text_type(i+1))}
		%endfor
	%endif
	</p>
	<hr style="border: 1px dashed #999999">
	<h4>${_('Is the care required on a future date?')}</h4>
	<div class="form-group row">
		${renderer.label('CareDate', _('Care Required on'),class_='control-label col-sm-4')}
		<div class="col-sm-8 form-inline">
			${renderer.text("CareDate", size=None, class_='DatePicker form-control')}
			<div>
				<input type="button" value="${_('1 Month')}" onClick="document.EntryForm.CareDate.value='${format_date(add_months(date.today(), 1))}';" class="btn btn-default">
				<input type="button" value="${_('3 Months')}" onClick="document.EntryForm.CareDate.value='${format_date(add_months(date.today(), 3))}';" class="btn btn-default">
				<input type="button" value="${_('6 Months')}" onClick="document.EntryForm.CareDate.value='${format_date(add_months(date.today(), 6))}';" class="btn btn-default">
				<input type="button" value="${_('1 Year')}" onClick="document.EntryForm.CareDate.value='${format_date(add_years(date.today(), 1))}';" class="btn btn-default">
			</div>
		</div>
	</div>
	%if age_groups:
	<hr style="border: 1px dashed #999999">
	<p>${_('<em><strong>Or</strong></em>, you can select the age group of the child at the time they require care')|n}</p>
	<p>${renderer.select('AgeGroup', options=[('', '')] + list(map(tuple, age_groups)), class_='form-control')}</p>
	%endif
	</td>
</tr>
%if types_of_care:
<tr>
	<td class="field-label-cell">${_('Type of Care Needed')}</td>
	<td class="field-data-cell"><span class="SmallNote">${_('If you do not select any values, all values will be searched.')}</span>
	<hr style="border: 1px dashed #999999">
	<table class="NoBorder cell-padding-2">
	%for toc in types_of_care:
		<tr>
			<td style="padding-left:8px;">${renderer.ms_checkbox('TOCID', value=toc.TOC_ID, label=toc.TypeOfCare)}</td>
		</tr>
	%endfor
	</table>
	<hr style="border: 1px dashed #999999">
	${renderer.radio('TOCType', value='F', label=Markup(_('Match <strong>any</strong> selected types of care')))}
	<br>${renderer.radio('TOCType', value='AF', label=Markup(_('Match <strong>all</strong> selected types of care')))}
	</td>
</tr>
%endif
%if types_of_program:
<tr>
	<td class="field-label-cell">${_('Type of Program')}</td>
	<td class="field-data-cell"><span class="SmallNote">${_('If you do not select any values, all values will be searched.')}</span>
	<hr style="border: 1px dashed #999999">
	<table class="NoBorder cell-padding-2">
	%for top in types_of_program:
		<tr>
			<td style="padding-left:8px;">${renderer.ms_checkbox('TOPID', value=top.TOP_ID, label=top.TypeOfProgram)}</td>
		</tr>
	%endfor
	</table>
	</td>
</tr>
%endif

%if search_info.CSrchSubsidy:
<tr>
	<td class="field-label-cell">${_('Subsidy')}</td>
	<td class="field-data-cell">${renderer.checkbox("CCSubsidy", value='on', label=_('Only show programs offering subsidized spaces'))}</td>
</tr>
%endif

%if search_info.CSrchSpaceAvailable:
<tr>
	<td class="field-label-cell">${_('Space Available?')}</td>
	<td class="field-data-cell">${renderer.checkbox("CCSpace", value='on', label=_('Only show programs reporting space available'))}</td>
</tr>
%endif

%if bus_routes:
<tr>
	<td class="field-label-cell">${renderer.label('BRID', _('On / Near Bus Route'))}</td>
	<td class="field-data-cell">${renderer.select('BRID', options=[('', '')] + list(map(tuple, bus_routes)), class_='form-control')}</td>
</tr>
%endif

%if search_info.CSrchSchoolsInArea and schools:
<tr>
	<td class="field-label-cell">${renderer.label("SCHAID", _('Local schools'))}</td>
	<td class="field-data-cell">${renderer.select('SCHAID', options=[('', '')] + list(map(tuple, schools)), class_='form-control')}</td>
</tr>
%endif

%if search_info.CSrchSchoolEscort and schools:
<tr>
	<td class="field-label-cell">${renderer.label("SCHEID", _('Escorts to / from School'))}</td>
	<td class="field-data-cell">${renderer.select('SCHEID', options=[('', '')] + list(map(tuple, schools)), class_='form-control')}</td>
</tr>
%endif

%if languages:
<tr>
	<td class="field-label-cell">${renderer.label("LNID", _('Languages'))}</td>
	<td class="field-data-cell">${renderer.select('LNID', options=[('', '')] + list(map(tuple, languages)), class_='form-control')}</td>
</tr>
%endif

%if search_info.CSrchKeywords:
<tr>
	<td class="field-label-cell">${renderer.label("STerms", _('Search Terms'))}</td>
	<td class="field-data-cell">
	<div class="inline-radio-list">
		${renderer.radio('SCon', id='SCon_A', value='A', checked=True, label=_('All the Terms'))}
		${renderer.radio('SCon', id='SCon_O', value='O', label=_('Any of the Terms'))}
	</div>

	${renderer.text('STerms', placeholder=_('Enter one or more search terms'), maxlength=255, size=None, class_='form-control')}

	<div class="inline-radio-list">
		${renderer.radio('SType', id='SType_A', value='A', checked=True, label=_('Keywords'))}
		${renderer.radio('SType', id='SType_O', value='O', label=request.viewdata.cic.OrganizationNames or _('Organization Name(s)'))}
	</div>
</tr>
%endif
</table>
</div>

<div style="display:none"><input type="hidden" name="CCRStat" value="R"></div>
%if request.user:
<p><label><input type="checkbox" id="NewWindow" name="NewWindow"> ${_('Open search results in a new window')}</p>
%endif
<p>
	<span class="search-buttons">
	<input type="submit" value="${_('Search')}" class="btn btn-default">
	<input type="reset" value="${_('Clear Form')}" class="btn btn-default">
	</span>
</p>

</form>
</div>
</%def>

<%def name="mapsbottomjs()">
%if search_info.CSrchNear and maps.hasGoogleMapsAPI(request):
${request.assetmgr.JSVerScriptTagSingleton("scripts/cultures/globalize.culture." + request.language.Culture + ".js")}
<script type="text/javascript">
jQuery(function() {
	if (!window.pageconstants) {
	pageconstants = {};
	pageconstants.culture="${request.language.Culture}";
	pageconstants.maps_key_arg = ${json.dumps(maps.getGoogleMapsKeyArg(request))|n};
	Globalize.culture(pageconstants.culture);

	pageconstants.txt_geocode_unknown_address= "${'No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect.'}";
	pageconstants.txt_geocode_map_key_fail= "${_('Google Map Key Error. Contact your system administrator.')}";
	pageconstants.txt_geocode_too_many_queries= "${_('Too many Google requests. Try again later.')}";
	pageconstants.txt_geocode_unknown_error= "${_('Google geocoding request error. Contact your system administrator.')}";
	}
	initialize_maps(pageconstants.culture, pageconstants.maps_key_arg, searchform_map_loaded, true);
});
</script>
%endif
</%def>
