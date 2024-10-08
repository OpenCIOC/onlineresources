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
from cioc.core import googlemaps
from cioc.core.utils import grouper
%>

<%def name="community_form(communities, show_other_box=False, idsuffix='', type_override=None)">
<% is_dropdown = request.viewdata.cic.CommSrchDropDown %>
%if type_override is not None:
<% is_dropdown = type_override %>
%endif
%if is_dropdown:
	%if communities or show_other_box or located_near:
<div class="community-dropdown-search-parent">
	%if search_info.SrchCommunityDefaultOnly and len(located_near) < 1:
		%if search_info.SrchCommunityDefault:
	<input type="hidden" name="CMType" value="S" />
		%else:
	<input type="hidden" name="CMType" value="L" />
		%endif
	%else:
	<div class="community-dropdown-search community-dropdown-search-left community-search-type">
		<select name="CMType" id="CMType${idsuffix}" class="form-control cm-select cm-select${idsuffix}" data-suffix="${idsuffix}">
			%if not search_info.SrchCommunityDefaultOnly or not search_info.SrchCommunityDefault:
			<option value="L" ${'selected' if not search_info.SrchCommunityDefault else '' }>${_('Located in')}</option>
			%endif
			%if not search_info.SrchCommunityDefaultOnly or search_info.SrchCommunityDefault:
			<option value="S" ${'selected' if search_info.SrchCommunityDefault else '' }>${_("Serving")}</option>
			%endif
			%for distance, label in located_near:
			<option value="${distance}" style="display: none;" class="cmtype-located-near">${label}</option>
			%endfor
		</select>
	</div>
	<div class="community-dropdown-search community-dropdown-search-right">
	%endif
		<div id="located-serving-community-wrap${idsuffix}">
			%if communities:
			<div class="community-dropdown-expand" data-enable-comm-expand="${1 if request.viewdata.cic.CommSrchDropDownExpand else 0}" data-select-count="0">
			<select name="CMID" id="CMID${idsuffix}" class="form-control input-expand">
				<option value="">${_('Select a Community')}</option>
				%for community in communities:
				<option value="${community[0]}" data-child-community-type="${community[2]}">${community[1]}</option>
				%endfor
			</select>
			</div>
			%elif show_other_box:
			<input id="OComm${idsuffix}" name="OComm" type="text" placeholder="${_('Enter a community name')}" maxlength="200" class="form-control">
			<input type="hidden" name="OCommID" id="OCommID${idsuffix}">
			%endif
		</div>
		%if located_near:
		<div id="located-near-wrap${idsuffix}" style="display:none;">
			<input id="GeoLocatedNearAddress${idsuffix}" name="GeoLocatedNearAddress" type="text" placeholder="${_('Enter an address')}" maxlength="200" class="form-control">
			<div style="display:none;">
				<input type="hidden" name="GeoLocatedNearLatitude" id="LATITUDECommunity${idsuffix}" value="">
				<input type="hidden" name="GeoLocatedNearLongitude" id="LONGITUDECommunity${idsuffix}" value="">
			</div>
		</div>
		%endif
	%if not search_info.SrchCommunityDefaultOnly or len(located_near) >= 1:
	</div>
	%endif
</div>
%endif
%else:
	%if search_info.SrchCommunityDefaultOnly and len(located_near) < 1:
		%if search_info.SrchCommunityDefault:
	<input type="hidden" name="CMType" value="S" />
		%else:
	<input type="hidden" name="CMType" value="L" />
		%endif
	%else:
<div class="inline-radio-list community-search-type">
		%if not search_info.SrchCommunityDefaultOnly or not search_info.SrchCommunityDefault:
	<label for="CMType_L${idsuffix}" class="NoWrap radio-inline"><input type="radio" class="cm-select cm-select${idsuffix}" id="CMType_L${idsuffix}" name="CMType" value="L" ${'checked' if not search_info.SrchCommunityDefault else '' } data-suffix="${idsuffix}">${_("Located in Community")}</label>
		%endif
		%if not search_info.SrchCommunityDefaultOnly or search_info.SrchCommunityDefault:
	<label for="CMType_S${idsuffix}" class="NoWrap radio-inline"><input type="radio" class="cm-select cm-select${idsuffix}" id="CMType_S${idsuffix}" name="CMType" value="S" ${'checked' if search_info.SrchCommunityDefault else '' } data-suffix="${idsuffix}">${_("Serving Community")}</label>
		%endif
		%for distance, label in located_near:
	<label for="CMType_${distance}${idsuffix}" class="NoWrap radio-inline"><input type="radio" class="cm-select cm-select${idsuffix} cmtype-located-near" id="CMType_${distance}${idsuffix}" name="CMType" value="${distance}" data-suffix="${idsuffix}">${label}</label>
		%endfor
</div>
	%endif
<div class="inline-no-bold">
	<div id="located-serving-community-wrap${idsuffix}">
		%if communities:
<%
if request.viewdata.cic.CommSrchWrapAt < 3:
	colclass = "col-xs-12 col-sm-6"
elif request.viewdata.cic.CommSrchWrapAt == 3:
	colclass = "col-xs-12 col-sm-6 col-md-4"
elif request.viewdata.cic.CommSrchWrapAt > 3:
	colclass = "col-xs-12 col-sm-6 col-md-4 col-lg-3"
else:
	colclass = "col-xs-12"
%>
		<div class="row clear-line-below">
			%for community in communities:
			<div class="search-community ${colclass}"><label for="CM_${community[0]}${idsuffix}" class="checkbox-inline"><input type="checkbox" name="CMID" id="CM_${community[0]}${idsuffix}" value="${community[0]}"> ${community[1]}</label></div>
			%endfor
		</div>
		%endif
		%if show_other_box:
		%if communities:
		<strong><label for="OComm${idsuffix}">${_('Other Community')}</label></strong>${_(':')} [ <a href="javascript:openWin('${request.passvars.makeLink(request.pageinfo.PathToStart + 'comfind.asp')}','cfind')">${_('Find Community Name')}</a> ]
		<br>
		%endif
		<input id="OComm${idsuffix}" name="OComm" type="text" placeholder="${_('Enter a community name')}" maxlength="200" class="form-control">
		<input type="hidden" name="OCommID" id="OCommID${idsuffix}">
		%endif
	</div>
	%if located_near:
	<div id="located-near-wrap${idsuffix}" style="display:none;">
		<input id="GeoLocatedNearAddress${idsuffix}" name="GeoLocatedNearAddress" type="text" placeholder="${_('Enter an address')}" maxlength="200" class="form-control">
		<div style="display:none;">
			<input type="hidden" name="GeoLocatedNearLatitude" id="LATITUDECommunity${idsuffix}" value="">
			<input type="hidden" name="GeoLocatedNearLongitude" id="LONGITUDECommunity${idsuffix}" value="">
		</div>
	</div>
	%endif
</div>
%endif
</%def>

<%def name="map_search_form()">
%if googlemaps.hasGoogleMapsAPI(request):
<tr id="SearchNear">
	<td class="field-label-cell">${_('Located Near')}</td>
	<td class="field-data-cell">
		<div class="form-group row">
			<label for="located_near_address" class="control-label col-sm-4">${_('Address or Postal Code')}</label>
			<div class="col-sm-8">
				<div class="input-group">
					<input name="GeoLocatedNearAddress" type="text" maxlength="250" id="located_near_address" class="form-control">
					<div class="input-group-addon"><span class="glyphicon glyphicon-search SimulateLink" title="${_('Find Location')}" name="GeoLocatedNearCheck" id="located_near_check_button"></span></div>
				</div>
			</div>
		</div>

		<div class="NotVisible">
			<input type="hidden" name="GeoLocatedNearLatitude" id="LATITUDE" value="">
			<input type="hidden" name="GeoLocatedNearLongitude" id="LONGITUDE" value="">
		</div>
		
		<div class="row">
			<div class="col-sm-4">
				<div class="input-group">
					<div class="input-group-addon"><label for="WithinRange">${_('Within')}</label></div>
					<input type="text" id="WithinRange" name="GeoLocatedNearDistance" size="4" maxlength="4" class="form-control">
					<div class="input-group-addon">km</div>
				</div>
				<div class="checkbox">
					<label for="GeoLocatedNearUnmapped"><input type="checkbox" name="GeoLocatedNearUnmapped" id="GeoLocatedNearUnmapped" value="on">${_('Include unmapped records')}</label>
				</div>
				<hr>
				<div class="checkbox">
					<label for="GeoLocatedNearSort"><input type="checkbox" name="GeoLocatedNearSort" id="GeoLocatedNearSort" value="on" checked>${_('Sort by nearest')}</label>
				</div>
			</div>
			<div class="col-sm-8">
				<div class="SearchNearMapCanvas" id="map_canvas"></div>
			</div>
		</div>
	</td>
</tr>
%endif
</%def>
