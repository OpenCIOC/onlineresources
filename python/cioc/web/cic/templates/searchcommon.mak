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
	%if communities or show_other_box:
<div class="community-dropdown-search-parent">
	<div class="community-dropdown-search community-dropdown-search-left community-search-type">
		<select name="CMType" id="CMType${idsuffix}" class="form-control cm-select cm-select${idsuffix}" data-suffix="${idsuffix}">
			<option value="L" ${'selected' if not search_info.SrchCommunityDefault else ''} >${_('Located in')}</option>
			<option value="S" ${'selected' if search_info.SrchCommunityDefault else ''}>${_("Serving")}</option>
			%for distance, label in located_near:
				<option value="${distance}" style="display: none;" class="cmtype-located-near">${label}</option>
			%endfor
		</select>
	</div>
	<div class="community-dropdown-search community-dropdown-search-right">
		<div id="located-serving-community-wrap${idsuffix}">
		%if communities:
		<select name="CMID" id="CMID${idsuffix}" class="form-control input-expand">
			<option>${_('Select a Community')}</option>
		%for community in communities:
			<option value="${community[0]}">${community[1]}</option>
		%endfor
		</select>
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
	</div>
</div>
	%endif
%else:
<div class="inline-radio-list community-search-type">
	<label for="CMType_L${idsuffix}" class="NoWrap radio-inline"><input type="radio" class="cm-select cm-select${idsuffix}" id="CMType_L${idsuffix}" name="CMType" value="L" ${ 'checked' if not search_info.SrchCommunityDefault else ''} data-suffix="${idsuffix}">${_("Located in Community")}</label>
	<label for="CMType_S${idsuffix}" class="NoWrap radio-inline"><input type="radio" class="cm-select cm-select${idsuffix}" id="CMType_S${idsuffix}" name="CMType" value="S" ${'checked' if search_info.SrchCommunityDefault else ''} data-suffix="${idsuffix}">${_("Serving Community")}</label>
	%for distance, label in located_near:
		<label for="CMType_${distance}${idsuffix}" class="NoWrap radio-inline"><input type="radio" class="cm-select cm-select${idsuffix} cmtype-located-near" id="CMType_${distance}${idsuffix}" name="CMType" value="${distance}" data-suffix="${idsuffix}">${label}</label>
	%endfor
</div>
<div class="inline-no-bold">
	<div id="located-serving-community-wrap${idsuffix}">
	%if communities:
	<table class="NoBorder clear-line-below checkbox-list-table">
	%for row in grouper(request.viewdata.cic.CommSrchWrapAt, communities):
		<tr class="search-community-row">
		%for col in row:
			%if col:
			<td class="search-community checkbox-list-item"><label for="CM_${col[0]}${idsuffix}" class="checkbox-inline"><input type="checkbox" name="CMID" id="CM_${col[0]}${idsuffix}" value="${col[0]}"> ${col[1]}</label></td>
			%endif
		%endfor
		</tr>
	%endfor
	</table>
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
