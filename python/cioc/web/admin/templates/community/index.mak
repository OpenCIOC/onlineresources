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
import json
%>

<%inherit file="cioc.web:templates/master.mak" />

<p style="font-weight:bold">
	[
	<a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
	| <a href="${request.passvars.route_path('import_community')}">${_('Update Communities Version')}</a>
	| <a href="${request.passvars.route_path('import_community_map')}">${_('Update External Communities')}</a>
	| <a href="${request.passvars.route_path('admin_community', action='list')}">${_('Full List')}</a>
	]
</p>

<h2>${_('Edit Community')}</h2>

<div class="panel panel-default">
	<div class="panel-body">
		<!-- Nav tabs -->
		<ul class="nav nav-tabs" role="tablist">
			<li role="presentation" class="active"><a href="#commlist" aria-controls="commlist" role="tab" data-toggle="tab">${_('Communities')}</a></li>
			<li role="presentation"><a href="#altcommlist" aria-controls="altcommlist" role="tab" data-toggle="tab">${_('Alternative Search Areas')}</a></li>
		</ul>

		<!-- Tab panes -->
		<div class="tab-content">
			<div role="tabpanel" class="tab-pane active clear-line-above" id="commlist">
				<a class="btn btn-info" href="${request.passvars.route_path('admin_community', action='edit')}">${_('Add Community')}</a>
				<div class="clear-line-above">
					<table class="BasicBorder cell-padding-4 full-width" id="community_table">
						<thead>
							<tr>
								<th>${_('Community')}</th>
								<th>${_('Parent Community')}</th>
								<th>${_('Parent Community')} (2)</th>
								<th>${_('Type')}</th>
							</tr>
						</thead>
						<tbody>
							%for community in communities:
							<tr>
								<td><a href="${request.route_path('admin_community', action='edit', _query=[('CM_ID', community.CM_ID)])}">${community.Community}</a></td>
								<td>${community.ParentCommunity}</td>
								<td>${community.ParentCommunity2}</td>
								<td>${community.PrimaryAreaType}</td>
							</tr>
							%endfor
						</tbody>
					</table>
				</div>
			</div>
			<div role="tabpanel" class="tab-pane clear-line-above" id="altcommlist">
				<a class="btn btn-info" href="${request.passvars.route_path('admin_community', action='edit', _query=[('altarea', 'on')])}">${_('Add Alternative Search Area')}</a>
				<div class="clear-line-above">
					<table class="BasicBorder cell-padding-4 full-width" id="altcommunity_table">
						<thead>
							<tr>
								<th>${_('Community')}</th>
								<th>${_('Parent Community')}</th>
							</tr>
						</thead>
						<tbody>
							%for community in altcommunities:
							<tr>
								<td><a href="${request.route_path('admin_community', action='edit', _query=[('CM_ID', community.CM_ID)])}">${community.Community}</a></td>
								<td>${community.ParentCommunity}</td>
							</tr>
							%endfor
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<%def name="headerextra()">
<link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">
</%def>

<%def name="bottomjs()">
<script type="text/javascript" src="//cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
<script type="text/javascript">
	(function ($) {
		$('#community_table').DataTable({
			"autoWidth": false,
			"paging": false
		});
		$('#altcommunity_table').DataTable({
			"autoWidth": false,
			"paging": false
		});
	})(jQuery);
</script>
</%def>
