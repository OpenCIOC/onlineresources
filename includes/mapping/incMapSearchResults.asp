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
<% If opt_bTableSortCIC Then %>
<script type="text/javascript" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
<% End If %>
<%= JSVerScriptTag("scripts/results.js") %>
<%= JSVerScriptTag("scripts/cultures/globalize.culture." & g_objCurrentLang.Culture & ".js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">

<% If opt_bTableSortCIC Then %>
(function($) {
	var cioc_facet_search = {};
	window.cioc_search_datatable = function() {
		window.cioc_data_table = $('#results_table').DataTable({
			"autoWidth": false,
			"paging": false,
		});
		//cioc_update_facet_search_criteria("359", [1292])
		$('#search-facet-selectors').on('change', '.facet-selector', function(e) {
			var self = $(this), facet=self.data('facet').toString(),
				criteria=$.map(this.value.split(','), function(val) {
					if (val) {
						return parseInt(val, 10);
					} else {
						return null;
					}
				});
			cioc_update_facet_search_criteria(facet, criteria);
		}).show();
	}
	window.cioc_update_facet_search_criteria = function(facet, criteria) {
		if (!Array.isArray(criteria) || !criteria.length) {
			delete cioc_facet_search[facet];
		} else {
			cioc_facet_search[facet] = criteria;
		}
		if (window.cioc_data_table) {
			window.cioc_data_table.search();
			window.cioc_data_table.draw();
		}
	};
	$.fn.dataTable.ext.search.push(
		function( settings, data, dataIndex ) {
			if (!cioc_facet_search || jQuery.isEmptyObject(cioc_facet_search)) {
				return true;
			}
			var tr = settings.aoData[dataIndex].nTr;
			if (!tr) {
				return false;
			}
			var facets = jQuery(tr).data("facets")
			if (!facets) {
				return false;
			}
			for(key in cioc_facet_search) {
				var facet_criteria = cioc_facet_search[key];
				var facet_data = facets[key];
				if (!Array.isArray(facet_data) || !facet_data.length) {
					return false;
				}
				if (!facet_criteria.some(r=> facet_data.indexOf(r) >= 0)){
					return false;
				}
			}
			return true;
		}
	);
})(jQuery);
<% End If %>
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
	if (window.cioc_search_datatable) {
		window.cioc_search_datatable();
	}
<%End If %>
});
</script>
<% End Sub %>
