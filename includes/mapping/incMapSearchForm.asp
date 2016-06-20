<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<%
Sub printMapSearchForm(bInline)
	If hasGoogleMapsAPI() Then
%>
<tr id="SearchNear">
	<td class="field-label-cell"><%=TXT_LOCATED_NEAR%></td>
	<td class="field-data-cell">
		<div class="form-group row">
			<label for="located_near_address" class="control-label col-sm-4"><%=TXT_ADDRESS_POSTAL_CODE%></label>
			<div class="col-sm-8">
				<div class="input-group">
					<input name="GeoLocatedNearAddress" type="text" maxlength="250" id="located_near_address" class="form-control">
					<div class="input-group-addon"><span class="glyphicon glyphicon-search SimulateLink" title="<%=TXT_FIND_LOCATION%>" name="GeoLocatedNearCheck" id="located_near_check_button"></span></div>
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
					<div class="input-group-addon"><label for="WithinRange"><%=TXT_WITHIN%></label></div>
					<input type="text" id="WithinRange" name="GeoLocatedNearDistance" size="4" maxlength="4" class="form-control">
					<div class="input-group-addon">km</div>
				</div>
				<div class="checkbox">
					<label for="GeoLocatedNearUnmapped"><input type="checkbox" name="GeoLocatedNearUnmapped" id="GeoLocatedNearUnmapped" value="on"><%=TXT_INCLUDE_UNMAPPED_RECORDS%></label>
				</div>
				<hr>
				<div class="checkbox">
					<label for="GeoLocatedNearSort"><input type="checkbox" name="GeoLocatedNearSort" id="GeoLocatedNearSort" value="on" checked><%=TXT_SORT_BY_NEAREST%></label>
				</div>
			</div>
			<div class="col-sm-8">
				<div class="SearchNearMapCanvas" id="map_canvas"></div>
			</div>
		</div>
	</td>
</tr>
<%
	End If
End Sub
 %>
