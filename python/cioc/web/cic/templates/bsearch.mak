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

<%inherit file="cioc.web:templates/master.mak" />
<%namespace file="cioc.web.cic:templates/searchcommon.mak" import="community_form" />
<%!
import json
from functools import partial
from itertools import groupby
from operator import attrgetter

from markupsafe import Markup
from webhelpers.html import tags

from cioc.core import constants as const, googlemaps as maps, listformat, vacancyscript
from cioc.core.utils import grouper

subitem_prefix = Markup('&nbsp;&nbsp;&nbsp;&nbsp;')
%>

<%def name="bottomjs()">
	<form class="NotVisible" name="stateForm" id="stateForm">
	<textarea id="cache_form_values"></textarea>
	</form>

	<% renderinfo.list_script_loaded = True %>
	${request.assetmgr.JSVerScriptTag('scripts/bsearch.js')}
	%if maps.hasGoogleMapsAPI(request):
		${request.assetmgr.JSVerScriptTagSingleton("scripts/cultures/globalize.culture." + request.language.Culture + ".js")}
	%endif
	<script type="text/javascript">
	(function() {
	var defaultParams = ${json.dumps(request.passvars.httpvals) |n};
	jQuery(function($) {
		%if request.user.cic:
		initialize_vacancy_options(${vacancyscript.vacancy_parameters(request)|n});
		initialize_vacancy_events();
		%endif

		init_cached_state('#SearchForm');
		init_pre_fill_search_parameters(null, "#OComm", "#OCommID");
		init_bsearch_tabs(defaultParams, ${search_info.BSrchDefaultTab or '0'});

		init_community_autocomplete($, 'OComm', "${ request.passvars.makeLink(request.pageinfo.PathToStart + "jsonfeeds/community_generator.asp")}", 3, "#OCommID");
		init_community_autocomplete($, 'OComm_2', "${ request.passvars.makeLink(request.pageinfo.PathToStart + "jsonfeeds/community_generator.asp")}", 3, "#OCommID_2");

		%if maps.hasGoogleMapsAPI(request):
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
		%endif

		init_located_near_autocomplete($);

	%if search_info.BSrchKeywords and search_info.BSrchAutoComplete:
		<% makeLink = request.passvars.makeLink %>
		init_find_box({
				A: '${ makeLink("~/jsonfeeds/cic_keyword_generator.asp", "SearchType=A")|n}', 
				O: '${ makeLink("~/jsonfeeds/cic_keyword_generator.asp", "SearchType=O")|n}', 
				S: '${ makeLink("~/jsonfeeds/cic_keyword_generator.asp", "SearchType=S")|n}', 
				T: '${ makeLink("~/jsonfeeds/cic_keyword_generator.asp", "SearchType=T")|n}'
				});
	%endif

		init_grouped_quicklist('${_("(any value)")|n}');

		restore_cached_state();
		init_placeholder_select();
		});
	})();
	</script>
	${mapsbottomjs}

</%def>

<%def name="age_groups_form(ages)">
${tags.select("AgeGroup", None, [('', _('Select an age group'))] + [(x[0], x[1]) for x in ages], class_="form-control check-placeholder")}
</%def>

<%def name="quicklist_form(quicklist, quicklist_type, field_suffix='', expand_class='', force_heading=False)">
	<%
	limited_view = request.viewdata.cic.LimitedView or force_heading
	if limited_view:
		quicklist = [(key, list(grp)) for key, grp in groupby(quicklist, attrgetter('GroupID', 'Group'))]
		field_name = "GHID" + field_suffix
		can_see_non_pub = False
	else:
		field_name = "PBID"
		can_see_non_pub = request.user and request.user.cic and request.viewdata.cic.CanSeeNonPublicPub
		if quicklist:
			quicklist = [((None,None), listformat.format_pub_list(quicklist, can_see_non_pub, request.viewdata.cic.UsePubNamesOnly ))]

	search_groups = request.viewdata.cic.QuickListSearchGroups
	%>
	%if quicklist_type == 1:
		<select name="${field_name}" id="QuickList" class="form-control check-placeholder ${expand_class}${'' if not search_groups else ' fix-group-single'|n}">
			<option value="">${_('Select a category')}</option>
		<% prefix = '' %>
		%for ((grpid, grpname), items) in quicklist:
			%if grpid:
			%if search_groups:
				<option data-group="${grpid}" value="${','.join(str(x[0]) for x in items)}">${grpname}</option>
				<% prefix = subitem_prefix %>
			%else:
				<optgroup label="${grpname}">
			%endif
			%endif
			%for item in items:
				<option value="${item[0]}">${prefix}${item[1]}</option>
			%endfor
			%if grpid and not search_groups:
				</optgroup>
			%endif
		%endfor
		</select>
	%elif quicklist_type == 2:
		%if request.viewdata.cic.QuickListMatchAll:
		<input type="hidden" name="${field_name[:2]}Type${field_suffix}" value="AF">
		%else:
		## force a Type value. In AG for Any Group
		<input type="hidden" name="${field_name[:2]}Type${field_suffix}" value="AG">
		%endif
		%for i,((grpid, grpname), items) in enumerate(quicklist):
			%if i:
				<br>
			%endif
			<div class="search-group">
			%if grpid is not None:
			<% kwargs = {} if not search_groups else {'class_': 'fix-group-multi', 'data-group': grpid} %>
			<label class="search-group-header checkbox-inline" for="QuickList_${grpid}">${grpname}</label><br>
			%else:
			<% kwargs = {} %>
			%endif
			${tags.select(field_name,None,[('',_('Select a category'))] + map(tuple, items), id="QuickList_" + str(grpid), class_="form-control checkbox-inline check-placeholder", **kwargs)}
			</div>
		%endfor
	%else:
		%if request.viewdata.cic.QuickListMatchAll:
		<input type="hidden" name="${field_name[:2]}Type${field_suffix}" value="AF">
		%else:
		## force a Type value. In AG for Any Group
		<input type="hidden" name="${field_name[:2]}Type${field_suffix}" value="AG">
		%endif
		<div class="inline-checkbox-list">
		<table class="NoBorder checkbox-list-table">
		<% 
			wrap_at = request.viewdata.cic.QuickListWrapAt
		%>
		%for i, ((grpid, grpname), items) in enumerate(quicklist):
			%if grpid is not None:
			<tr><td colspan="${wrap_at}" class="search-group-header">
			%if search_groups:
				${tags.checkbox(field_name + "_GRP" + unicode(field_suffix), value=grpid, label=grpname)} 
			%else:
				${grpname}
			%endif
			</td></tr>
			%endif
			%for row in grouper(wrap_at, items):
				<tr class="search-heading-row">
					%for col in row:
						%if col:
							<td class="search-heading checkbox-list-item"><label for="${field_name+str(col[0])}" class="checkbox-inline">${tags.checkbox(field_name, value=col[0], id=field_name+str(col[0]))} ${col[1]}</label></td>
						%endif
					%endfor
				</tr>
			%endfor
		%endfor
		</table>
		</div>
	%endif
	%if can_see_non_pub:
	<span class="SmallNote">${_("* indicates non-public")}</span>
	%endif
</%def>

<%def name="searchform_start()">
<form id='SearchForm' action="results.asp" method="get" name="Search" role="form">
<div style="display:none">
${request.passvars.cached_form_vals}
</div>
</%def>

<%def name="searchform_buttons()">
	<span class="search-buttons">
	<input type="submit" value="${_('Search')}" class="btn btn-default">
	<input type="reset" value="${_('Clear Form')}" class="btn btn-default">
	%if search_info.HasSearchTips:
	<a href="${request.passvars.makeLink('search_help.asp')}" role="button" class="btn btn-default">${_('Search Tips')}</a>
	%endif
	</span>
</%def>

<%def name="searchform_languages(idsuffix='')">
	${renderer.select('LNID', options=[('', _('Select a language of service'))] + map(tuple, languages), class_='form-control check-placeholder')}
</%def>

<%def name="searchform_keyword()">
	%if search_info.BSrchKeywords:
	<input type="text" maxlength="250" id="STerms" name="STerms" class="form-control ui-autocomplete-input" placeholder="${_('Enter one or more search terms')}">
	%endif
</%def>

<%def name="searchform_in_values()">
<div class="inline-radio-list keyword-search-in">
	<label for="SType_A" class="radio-inline"><input type="radio" name="SType" id="SType_A" value="A" checked>${_('Keywords')}</label>
	<label for="SType_O" class="radio-inline"><input type="radio" name="SType" id="SType_O" value="O">${request.viewdata.cic.OrganizationNames or _('Organization Name(s)')}</label>
%if request.dboptions.UseCIC:
	%if request.viewdata.cic.UseThesaurusView:
	<label for="SType_S" class="radio-inline"><input type="radio" name="SType" id="SType_S" value="S">${_('Subjects')}</label>
	%endif
	%if request.viewdata.cic.UseTaxonomyView:
	<label for="SType_T" class="radio-inline"><input type="radio" name="SType" id="SType_T" value="T">${_('Service Categories')}</label>
	%endif
%endif
</div>
</%def>

<%def name="searchform_num()">
%if search_info.BSrchNUM:
	<input type="text" size="15" maxlength="8" name="NUM" id="NUM" class="form-control" placeholder="${_('e.g.')} ACT0001">
%endif
</%def>

<%def name="searchform()" buffered="True">
<form id="SearchForm" action="bresults.asp" method="get" name="Search" class="form-horizontal" role="form">
${request.passvars.cached_form_vals}
<div class="form-group">
	<div class="col-sm-offset-3 col-sm-9">
		${searchform_buttons()}
	</div>
</div>

%if search_info.BSrchKeywords:
<div class="form-group">
	<label for="STerms" class="control-label col-sm-3">${_('Find')}</label>
	<div class="col-sm-9">
		${searchform_keyword()}
		${searchform_in_values()}
	</div>
</div>
%endif

%if communities:
<div class="form-group">
	<label class="control-label col-sm-3">${_('Community')}</label>
	<div class="col-sm-9">
		${community_form(communities, request.viewdata.cic.OtherCommunity)}
	</div>
</div>
%endif

%if search_info.BSrchWWW or search_info.BSrchVOL:
<div class="form-group">
	<label for="STerms" class="control-label col-sm-3">${_('Limit To')}</label>
	<div class="col-sm-9 inline-checkbox-list">
		%if search_info.BSrchWWW:
		<label for="HasURL"><input type="checkbox" name="HasURL" id="HasURL" class="checkbox-inline">${request.viewdata.cic.OrganizationsWithWWW or _("Organizations with Website")}</label>
		%endif
		%if search_info.BSrchVOL and request.dboptions.UseVOL:
			%if search_info.BSrchWWW:
			<br>
			%endif
			<label for="HasVol"><input type="checkbox" name="HasVol" id="HasVol" class="checkbox-inline">${request.viewdata.cic.OrganizationsWithVolOps or _("Organizations with Volunteer Opportunities")}</label>
		%endif
	</div>
</div>
%endif

%if search_info.BSrchAges and ages:
<div class="form-group">
	<label for="agegroup" class="control-label col-sm-3">${_('Ages')}</label>
	<div class="col-sm-9">
		${age_groups_form(ages)}
	</div>
</div>
%endif

%if search_info.BSrchLanguage and languages:
<div class="form-group">
	<label for="agegroup" class="control-label col-sm-3">${_('Languages')}</label>
	<div class="col-sm-9">
		${searchform_languages()}
	</div>
</div>
%endif

%if search_info.BSrchVacancy and vacancy_targets:
<div class="form-group">
	<label class="control-label col-sm-3">${_("Vacancy")}</label>
	<div class="col-sm-9">
		<div class="inline-radio-list form-inline-always">
		<label for="vacancytp">${_("Has capacity / availability for")}</label>
		${tags.select("VacancyTP", None, [('','')] + [(x.VTP_ID, x.TargetPopulation) for x in vacancy_targets], class_="form-control")}
		</div>
		<span class="inline-no-bold">
		<label for="Vacancy_NONE"><input type="radio" name="Vacancy" value="" checked id="Vacancy_NONE">${_("Do not search availability information")}</label>
		<br><label for="Vacancy_Y"><input type="radio" name="Vacancy" value="Y" id="VACANCY_Y">${_("Has availability")}</label>
		<br><label for="Vacancy_W"><input type="radio" name="Vacancy" value="W" id="VACANCY_W">${_("Has availability or a wait list")}</label>
		</span>
	</div>
</div>
%endif

%if request.dboptions.UseCIC:
	%if quicklist:
	<div class="form-group">
		<label class="control-label col-sm-3" for="QuickList">${request.viewdata.cic.QuickListName or ''}</label>
		<div class="col-sm-9">
			${quicklist_form(quicklist, request.viewdata.cic.QuickListDropDown, expand_class='input-expand', force_heading=request.viewdata.cic.QuickListPubHeadings)}
		</div>
	</div>
	%endif
%endif

%if search_info.BSrchOCG:
<div class="form-group">
	<label class="control-label col-sm-3" for="OCG">${_('OCG #')}</label>
	<div class="col-sm-9">
		<input type="Text" maxlength="100" name="OCG" id="OCG" class="form-control">
	</div>
</div>
%endif

%if search_info.BSrchNUM:
<div class="form-group">
	<label class="control-label col-sm-3" for="NUM">${_('Record #')}</label>
	<div class="col-sm-9 form-inline-always">
		${searchform_num()}
	</div>
</div>
%endif

<div class="form-group">
	<div class="col-sm-offset-3 col-sm-9">
		${searchform_buttons()}
	</div>
</div>

</form>

</%def>

<div id="cic-search">
${makeSearchForm(
		searchform,
		searchform_start=partial(capture, searchform_start),
		searchform_keyword=partial(capture, searchform_keyword),
		searchform_in_values=partial(capture, searchform_in_values),
		searchform_community=partial(capture, partial(community_form, communities, request.viewdata.cic.OtherCommunity)),
		searchform_quicklist=partial(capture, partial(quicklist_form, quicklist, request.viewdata.cic.QuickListDropDown, expand_class='input-expand', force_heading=request.viewdata.cic.QuickListPubHeadings)),
		searchform_num=partial(capture, searchform_num),
		searchform_languages=partial(capture, searchform_languages),
	)|n}
</div>
