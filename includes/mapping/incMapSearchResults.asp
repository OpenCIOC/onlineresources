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

<script language="python" runat="server">
from cioc.core import vacancyscript, detailsscript
def vacancy_script():
	return vacancyscript.vacancy_script(pyrequest)

def details_script():
	return detailsscript.details_sidebar_script(pyrequest)

</script>
<%
Sub makeMappingSearchFooter()
	If g_bPrintMode Then
		Exit Sub
	End If
%>
<script type="text/javascript">var is_ie7 = false;</script>
<!--[if lte IE 7]>
<script type="text/javascript">var is_ie7 = true;</script>
<![endif]-->
<script type="text/javascript">var skip_mapping = false;</script>
<!--[if lte IE 6]>
<script type="text/javascript">var skip_mapping = true;</script>
<![endif]-->
<%
%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/results.js") %>
<%= JSVerScriptTag("scripts/cultures/globalize.culture." & g_objCurrentLang.Culture & ".js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">
jQuery(function() {
	<%= vacancy_script() %>;
	<%= details_script() %>
	<% If g_bMapSearchResults Then %>
	var map_pins = {
		0: {
				category: '<%= Nz(get_view_data_cic("MultipleOrgWithSimilarMap"), TXT_MULTIPLE_ORGANIZATIONS) %>',
				image_small_circle: 'images/mapping/mm_0_white_20_circle.png'

	<%
			Call openMappingCategoryListRst()
			With rsListMappingCategory		
				While Not .EOF
	%>
			}, <%=.Fields("MapCatID")%>: {
				category: <%=JsQs(.Fields("CategoryName"))%>, 
				image: <%=JsQs("images/mapping/" & .Fields("MapImage"))%>,
				image_small: <%=JsQs("images/mapping/" & .Fields("MapImageSm"))%>,
				image_small_dot: <%=JsQs("images/mapping/" & .Fields("MapImageSmDot"))%>,
				image_small_circle: <%=JsQs("images/mapping/" & .Fields("MapImageSmCircle"))%>,
				colour: <%=JsQs(.Fields("PinColour"))%>
	<%
					.MoveNext
				Wend
			End With
			Call closeMappingCategoryListRst()
	%>
		}
	};
	var translations = {
		txt_more_info: <%= JsQs(TXT_MORE_INFO) %>,
		txt_legend: <%= JsQs(TXT_LEGEND) %>,
		txt_to_bottom: <%= JsQs(TXT_TO_BOTTOM) %>,
		txt_to_side: <%= JsQs(TXT_TO_SIDE) %>,
		txt_close: <%= JsQs(TXT_CLOSE) %>
	};
	<% If hasGoogleMapsAPI() Then %>
	initialize_mapping({map_pins: map_pins, translations: translations,
			culture: "<%= g_objCurrentLang.Culture %>",
			key_arg: <%= JSONQs(getGoogleMapsKeyArg(), True)%>,
			auto_start: <%= IIf(g_bAutoMapSearchResults, "true", "false") %>
	});
	<% End If %>
<%End If %>
});
</script>
<% End Sub %>
