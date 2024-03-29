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

from markupsafe import Markup

from cioc.core import googlemaps as maps
from cioc.core.datesearch import add_months, add_years
%>

<%namespace file="cioc.web.cic:templates/searchcommon.mak" import="community_form,map_search_form" />

<%def name="no_values_search_all_text(add_hr)">
<div class="no-values-search-all-text">
	<span class="SmallNote">${_('If you do not select any values, all values will be searched.')}</span>
	%if add_hr:
	<hr />
	%endif
</div>
</%def>

<%def name="childsearchform()">
<div id="csrch_top">
	<form action="cresults.asp" method="get" id="EntryForm" name="EntryForm" ${' onSubmit="formNewWindow(this);" ' if request.user else ' '|n} class="form-horizontal">
		<div style="display:none">
			${request.passvars.cached_form_vals}
		</div>
		<div class="search-buttons">
			<input type="submit" value="${_('Search')}" class="btn btn-default">
			<input type="reset" value="${_('Clear Form')}" class="btn btn-default">
		</div>

		<div class="max-width-lg">
			<table class="BasicBorder cell-padding-4 responsive-table form-table auto-fill-table">
				%if communities:
				<tr>
					<td class="field-label-cell">${_('Communities')}</td>
					<td class="field-data-cell">
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
					<td class="field-data-cell">
						<div class="row form-group">
							<label for="DOB0" class="control-label col-sm-5 col-md-4 col-lg-3">${_('Date of Birth')}</label>
							<div class="col-sm-7 col-md-8 col-lg-9 form-inline">
								<input type="text" name="DOB0" class="DatePicker form-control" id="DOB0" autocomplete="off" data-lpignore="true">
								<br class="visible-sm" />(${_('e.g.')} ${format_date(date.today())})
							</div>
						</div>
						<div class="form-group row">
							${renderer.label('CareDate', _('Care Required on'),class_='control-label col-sm-5 col-md-4 col-lg-3')}
							<div class="col-sm-7 col-md-8 col-lg-9 form-inline">
								${renderer.text("CareDate", size=None, class_='DatePicker form-control')}
								<br class="visible-sm" />(${_('optional future date')})
								<div>
									<input type="button" value="${_('1 Month')}" onClick="document.EntryForm.CareDate.value='${format_date(add_months(date.today(), 1))}';" class="btn btn-default">
									<input type="button" value="${_('3 Months')}" onClick="document.EntryForm.CareDate.value='${format_date(add_months(date.today(), 3))}';" class="btn btn-default">
									<input type="button" value="${_('6 Months')}" onClick="document.EntryForm.CareDate.value='${format_date(add_months(date.today(), 6))}';" class="btn btn-default">
									<input type="button" value="${_('1 Year')}" onClick="document.EntryForm.CareDate.value='${format_date(add_years(date.today(), 1))}';" class="btn btn-default">
								</div>
							</div>
						</div>
						<div id="multiple-children-search">
							<div class="panel panel-info">
								<div class="panel-heading">
									<a href="#multiple-children" data-toggle="collapse">${_('Are you searching for care for more than one child?')} <span class="caret"></span></a>
								</div>
								<div id="multiple-children" class="panel-body panel-collapse collapse ${'in' if request.user else ''}">
									%for i in range(1,4):
									<div class="row form-group">
										<label for="DOB${i}" class="control-label col-sm-5 col-md-4 col-lg-3">${_('Date of Birth #%d') % (i + 1)}</label>
										<div class="col-sm-7 col-md-8 col-lg-9 form-inline">
											<input type="text" name="DOB${i}" class="DatePicker form-control" id="DOB${i}" autocomplete="off" data-lpignore="true">
											<br class="visible-sm" />(${_('e.g.')} ${format_date(date.today())})
										</div>
									</div>
									%endfor
									<p class="clear-line-below">
										${renderer.radio("AgeType", id="AgeTypeOne", value='', label=Markup(_("Match programs that serve <strong>any one</strong> child's age")), checked=True)}
										<br>${renderer.radio("AgeType", id="AgeTypeAll", value="A", label=Markup(_("Match only programs that can serve <strong>all</strong> the children")))}
										%if request.user:
										<br>${renderer.radio("AgeType", id="AgeTypeS", value="S", label=Markup(_("Match programs that serve <strong>child #</strong>")))}
										%for i in range(4):
										${renderer.radio("AgeTypeSpecific", value=str(i), checked=not i, id="AgeTypeSpecific%d" % i, label=str(i+1)+' ')}
										%endfor
										%endif
									</p>
								</div>
							</div>
						</div>
						%if age_groups:
						<p>${_('<em><strong>Or</strong></em>, you can select the age group of the child at the time they require care')|n}</p>
						<p>${renderer.select('AgeGroup', options=[('', '')] + list(map(tuple, age_groups)), class_='form-control')}</p>
						%endif
					</td>
				</tr>
				%if types_of_care:
				<tr>
					<td class="field-label-cell">${_('Type of Care Needed')}</td>
					<td class="field-data-cell">
						%if request.user:
						<p>
							${renderer.radio('TOCType', value='F', label=Markup(_('Match <strong>any</strong> selected types of care')), checked=True)}
							<br>${renderer.radio('TOCType', value='AF', label=Markup(_('Match <strong>all</strong> selected types of care')))}
						</p>
						<hr>
						%else:
						<input type="hidden" name="TOCType" value="F">
						%endif
						<div class="row">
							%for toc in types_of_care:
							<div class="col-sm-6 ${'col-lg-4' if (request.pageinfo.ThisPage == 'csrch') else ''}">
								${renderer.ms_checkbox('TOCID', value=toc.TOC_ID, label=toc.TypeOfCare)}
							</div>
							%endfor
						</div>
					</td>
				</tr>
				%endif
				%if types_of_program:
				<tr>
					<td class="field-label-cell">${_('Type of Program')}</td>
					<td class="field-data-cell">
						<div class="row">
							%for top in types_of_program:
							<div class="col-sm-6 ${'col-lg-4' if (request.pageinfo.ThisPage == 'csrch') else ''}">
								${renderer.ms_checkbox('TOPID', value=top.TOP_ID, label=top.TypeOfProgram)}
							</div>
							%endfor
						</div>
					</td>
				</tr>
				%endif

				%if search_info.CSrchSubsidy or search_info.CSrchSubsidyNamedProgram:
				<tr>
					<td class="field-label-cell">${_('Subsidy')}</td>
					<td class="field-data-cell">
						%if search_info.CSrchSubsidy:
						<p>${renderer.checkbox("CCSubsidy", value='on', label=_('Only show programs offering subsidized spaces'))}</p>
						%endif
						%if search_info.CSrchSubsidyNamedProgram:
						%if request.user:
						<p>
							<strong>${search_info.SubsidyNamedProgramSearchLabel + _(':')}</strong>
							<br>${renderer.radio("CCSubsidyNP", value='', checked=True, label=_('Any'))}
							<br>${renderer.radio("CCSubsidyNP", value='Y', label=_('Yes'))}
							<br>${renderer.radio("CCSubsidyNP", value='N', label=_('No'))}
							<br>${renderer.radio("CCSubsidyNP", value='U', label=_('Unknown'))}
						</p>
						%else:
						<p>${renderer.checkbox("CCSubsidyNP", value='on', label=search_info.SubsidyNamedProgramSearchLabel)}</p>
						%endif
						%endif
					</td>
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
					</td>
				</tr>
				%endif
			</table>
		</div>
		<div style="display:none"><input type="hidden" name="CCRStat" value="R"></div>
		%if request.user:
		<p>
			<label><input type="checkbox" id="NewWindow" name="NewWindow"> ${_('Open search results in a new window')}</label>
		</p>
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
	jQuery(function () {
		if (!window.pageconstants) {
			pageconstants = {};
			pageconstants.culture = "${request.language.Culture}";
			pageconstants.maps_key_arg = ${ json.dumps(maps.getGoogleMapsKeyArg(request)) | n };
			Globalize.culture(pageconstants.culture);

			pageconstants.txt_geocode_unknown_address = "${'No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect.'}";
			pageconstants.txt_geocode_map_key_fail = "${_('Google Map Key Error. Contact your system administrator.')}";
			pageconstants.txt_geocode_too_many_queries = "${_('Too many Google requests. Try again later.')}";
			pageconstants.txt_geocode_unknown_error = "${_('Google geocoding request error. Contact your system administrator.')}";
		}
		initialize_maps(pageconstants.culture, pageconstants.maps_key_arg, searchform_map_loaded, true);
	});
</script>
%endif
</%def>
