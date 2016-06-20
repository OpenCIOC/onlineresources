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

<h1>${_('Browse Available Icons')}</h1>
<div class="row" style="font-size:x-large">
%for icon in icons:
	<% icon_full = icon.Type + '-' + icon.IconName %>
	<div class="col-sm-6 col-lg-4">
		<div class="icon-listing-group">
			<div class="icon-listing">
			${make_icon_html(icon.Type, icon.IconName, True)}
			</div>
			${icon_full}
		</div>
	</div>
%endfor
</div>