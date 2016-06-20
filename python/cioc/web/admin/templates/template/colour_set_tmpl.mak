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

<%def name="colour_set(fieldname, fieldlabel)">
<%
set_items = [('fc',_('Text Colour')),('bgColor',_('Background Colour')),('borderColor',_('Border Colour')),('iconColor',_('Icon Colour'))]
%>
	<tr>
		<td class="field-label-cell">${fieldlabel}</td>
		<td class="field-data-cell">
		%for set_item, set_title in set_items:
			${renderer.errorlist("template." + set_item + fieldname)}
			<div class="form-group row form-inline form-inline-always">
				${renderer.label("template." + set_item + fieldname, set_title, class_='col-xs-4 col-md-3 control-label')}
				<div class="col-xs-8 col-md-9">
					${renderer.colour("template." + set_item + fieldname, class_="form-control")}
				</div>
			</div>
		%endfor
		</td>
	</tr>
</%def>
