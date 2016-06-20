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

<% If hasGoogleMapsAPI() Then %>

<%= JSVerScriptTag("scripts/cultures/globalize.culture." & g_objCurrentLang.Culture & ".js") %>
<script type="text/javascript">
jQuery(function() {
	pageconstants = {};
	pageconstants.culture= "<%=g_objCurrentLang.Culture%>";
	pageconstants.maps_key_arg = <%= JSONQs(getGoogleMapsKeyArg, True) %>;
	Globalize.culture(pageconstants.culture);

	pageconstants.txt_geocode_unknown_address= "<%=TXT_GEOCODE_UNKNOWN_ADDRESS%>";
	pageconstants.txt_geocode_map_key_fail= "<%=TXT_GEOCODE_MAP_KEY_FAIL%>";
	pageconstants.txt_geocode_too_many_queries= "<%=TXT_GEOCODE_TOO_MANY_QUERIES%>";
	pageconstants.txt_geocode_unknown_error= "<%= TXT_GEOCODE_UNKNOWN_ERROR & TXT_COLON%>";
	initialize_maps('<%= g_objCurrentLang.Culture %>', <%= JSONQs(getGoogleMapsKeyArg(), True)%>, searchform_map_loaded, true);
});
</script>
<% End If %>
