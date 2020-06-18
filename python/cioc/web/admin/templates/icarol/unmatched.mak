<%doc>
=========================================================================================
 Copyright 2020 KCL Software Solutions Inc.

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
import json
%>

<%inherit file="cioc.web:templates/master.mak" />

%if not unmatched:
<p class="InfoMsg">${_('No unmatched records from iCarol')}
%else:
<p class="InfoMsg">${_('Found %d unmatched records from iCarol') % (len(unmatched),)}

<table class="display" width="100%" id="results_table"></table>

<%doc>
<table class="BasicBorder cell-padding-3" id="results_table">
	<thead>
		<tr>
			<th>${_('Record ID')}</th><th>${_('Taxonomy Level')}</th><th>${_('Org Name')}</th><th>${_('Community')}</th>
		</tr>
	</thead>
	<tbody>
	%for unmatched_record in unmatched:
		<tr>
			<td>${unmatched_record.ResourceAgencyNum}</td>
			<td>${unmatched_record.TaxonomyLevelName}</td>
			<td>${unmatched_record.PublicName}</td>
			<td>${unmatched_record.PhysicalCity}</td>
		</tr>
	%endfor
	</tbody>
</table>
</%doc>
%endif

<%def name="headerextra()">
<link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">
</%def>

<%def name="bottomjs()">
<script type="text/javascript" src="//cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
<script type="text/javascript">
var dataSet=${json.dumps(list(map(tuple, unmatched)))|n};
(function($) {
		window.cioc_data_table = $('#results_table').DataTable({
			data: dataSet,
			columns: [
				{ title: "${_('Record ID')}"},
				{ title: "${_('Org Name')}"},
				{ title: "${_('Taxonomy Level')}"},
				{ title: "${_('Community')}"},
			]
		});
})(jQuery);
</script>
</%def>
