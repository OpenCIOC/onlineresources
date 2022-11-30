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
from itertools import groupby
from operator import attrgetter
from cioc.core import constants as const
%>


<%inherit file="cioc.web:templates/master.mak" />
<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

<% culture_order = [x for x in active_cultures if x in descriptions] %>
<form method="post" action="${request.route_path('admin_view', action='topicsearch')}">
	<div class="NotVisible">
		${request.passvars.cached_form_vals|n}
		<input type="hidden" name="ViewType" value="${ViewType}">
		%if is_edit:
		<input type="hidden" name="TopicSearchID" value="${TopicSearchID}">
		%endif
	</div>
	<table class="BasicBorder cell-padding-4">
		<tr><th colspan="2" class="RevTitleBox">${_('Edit Topic Search') if is_edit else _('Add Topic Search')}</th></tr>
		<tr>
			<td class="FieldLabelLeft">${renderer.label('topicsearch.TopicSearchTag', _('Search Tag'))}</td>
			<td>
				${renderer.errorlist('topicsearch.TopicSearchTag')}
				${renderer.text('topic_search.TopicSearchTag', maxlength=20)}
			</td>
		</tr>
		%for culture in culture_order:
		<% lang = culture_map[culture] %>
		<tr>
			<td class="FieldLabelLeft">${renderer.label("descriptions." +lang.FormCulture + ".SearchTitle", _('Search Title') + " (" + lang.LanguageName + ")")}</td>
			<td>
				${renderer.errorlist("descriptions." + lang.FormCulture + ".SearchTitle")}
				${renderer.text("descriptions." + lang.FormCulture + ".SearchTitle", maxlength=50)}
			</td>
		</tr>
		%endfor
		%for culture in culture_order:
		<% lang = culture_map[culture] %>
		<tr>
			<td class="FieldLabelLeft">${renderer.label("descriptions." + lang.FormCulture + ".SearchDescription", _('Description') + " (" + lang.LanguageName + ")")}</td>
			<td>
				${renderer.errorlist("descriptions." + lang.FormCulture + ".SearchDescription")}
				${renderer.textarea("descriptions." + lang.FormCulture + ".SearchDescription", cols=const.TEXTAREA_COLS - 10)}
			</td>
		</tr>
		%endfor
		<tr>
			<td class="FieldLabelLeft">${renderer.label('topic_search.DisplayOrder', _('Display Order'))}</td>
			<td>
				${renderer.errorlist("topic_search.DisplayOrder")}
				${renderer.text('topic_search.DisplayOrder', maxlength=3)}
			</td>
		</tr>
		%for field_name, field_label in [('Heading1', _('Heading 1')), ('Heading2', _('Heading 2')), ('Community', _('Community')), ('AgeGroup', _('Age Group')), ('Language', _('Language'))]:
		<% prefix = 'topic_search.' + field_name %>
		<tr><th colspan="2" class="RevTitleBox">${field_label}</th></tr>
		<tr>
			<td class="FieldLabelLeft">${renderer.label(prefix + 'Step', _('Step'))}</td>
			<td>
				${renderer.errorlist(prefix + "Step")}
				${renderer.select(prefix + 'Step', [''] + list(map(str,range(1,6))))}
			</td>
		</tr>
		%if field_name != 'Heading1':
		<tr>
			<td class="FieldLabelLeft">${renderer.label(prefix + 'Required', _('Required'))}</td>
			<td>
				${renderer.errorlist(prefix + "Required")}
				${renderer.checkbox(prefix + 'Required')}
			</td>
		</tr>
		%endif

		%if field_name in ['Heading1', 'Heading2']:
		<% heading_no = field_name[-1] %>
		<tr>
			<td class="FieldLabelLeft">${renderer.label('topic_search.PB_ID' + heading_no,_('Publication'))}</th>
			<td>
				${renderer.errorlist("topic_search.PB_ID" + heading_no)}
				${renderer.select("topic_search.PB_ID" + heading_no, options=[('','')] + publications)}
			</td>
		</tr>
		<tr>
			<td class="FieldLabelLeft">${renderer.label(prefix + 'ListType', _('List Type'))}</td>
			<td>
				${renderer.errorlist(prefix + "ListType")}
				${renderer.select(prefix + "ListType", [('1', _('Drop-Down List')),('2',_('Drop-Down List Per Group (Limited View)')),('0',_('Checkboxes'))])}
			</td>
		</tr>
		%for culture in culture_order:
		<%
		lang = culture_map[culture]
		full_name = "descriptions." + lang.FormCulture + "." + field_name + "Title"
		%>
		<tr>
			<td class="FieldLabelLeft">${renderer.label(full_name, _('List Name (%s)') % lang.LanguageName)}</td>
			<td>
				${renderer.errorlist(full_name)}
				${renderer.text(full_name, maxlength=255, size=const.TEXT_SIZE-10)}
			</td>
		</tr>
		%endfor

		%endif
		%for culture in culture_order:
		<%
		lang = culture_map[culture]
		full_name = "descriptions." + lang.FormCulture + "." + field_name + "Help"
		%>
		<tr>
			<td class="FieldLabelLeft">${renderer.label(full_name, _('Help Text (%s)') % lang.LanguageName)}</td>
			<td>
				${renderer.errorlist(full_name)}
				${renderer.textarea(full_name, maxlength=4000)}
			</td>
		</tr>
		%endfor

		%if field_name == 'Community':
		<tr>
			<td class="FieldLabelLeft">${renderer.label(prefix + 'ListType', _('Community Search Type'))}</td>
			<td>
				${renderer.errorlist(prefix + "ListType")}
				${renderer.select(prefix + "ListType", [('True', _('Drop-Down List')),('False',_('Checkboxes'))])}
			</td>
		</tr>
		%endif

		%endfor
		<tr>
			<td colspan="2">
				<input type="submit" name="Submit" value="${_('Add') if not is_edit else _('Update')}">
				%if is_edit:
				<span class="HideNoJs">
					<input type="submit" name="Delete" value="${_('Delete')}" href="${request.passvars.route_path('admin_view', action='topicsearch_delete', _query=[('TopicSearchID', TopicSearchID)])}" class="nav-on-click">
				</span>
				<span class="HideJs">
					<input type="submit" name="Delete" value="${_('Delete')}" href="${request.passvars.route_path('admin_view', action='topicsearch_delete', _query=[('TopicSearchID', TopicSearchID)])}" disabled title="${_('JavaScript must be enabled to delete this item')}">
				</span>
				%endif
				<input type="reset" value="${_('Reset Form')}">
			</td>
		</tr>
	</table>
	</form>

	<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>
