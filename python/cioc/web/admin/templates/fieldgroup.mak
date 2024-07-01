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
<%namespace file="cioc.web.admin:templates/shown_cultures.mak" name="sc" />
<%!
from cioc.core import constants as const
%>
<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

<h2>${renderinfo.doc_title}</h2>

<p><span class="AlertBubble">${_('Note that deleting a field group will remove all the fields in that group!')}</span></p>
<p class="HideJs Alert">
	${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
	<form method="post" action="${request.current_route_path()}" class="form-horizontal">
		<div class="NotVisible">
			${request.passvars.cached_form_vals|n}
			<input type="hidden" name="DM" value="${domain.id}">
			<input type="hidden" name="ViewType" value="${ViewType}">
		</div>

		${sc.shown_cultures_ui()}

		<table class="BasicBorder cell-padding-3 form-table">
			<tr>
				<th>${_('Delete')}</th>
				<th>${_('Field Group')}</th>
				<th>${_('Order')}</th>
			</tr>
			%for index, group in enumerate(groups):
			<%
				prefix = 'group-' + str(index) + '.'
				if isinstance(group, dict):
					groupid = group.get('DisplayFieldGroupID')
				else:
					groupid = group.DisplayFieldGroupID
			%>
			${make_row(prefix, groupid)}
			%endfor
		<tr>
			<td colspan="3">
				<button id="add-row" class="btn btn-default">${_('Add New Item')}</button>
				<input type="submit" name="Submit" value="${_('Update')}" class="btn btn-default">
				<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
			</td>
		</tr>
		</table>

	</form>
</div>

<p align="center" class="clear-line-above">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

<script type="text/html" id="new-item-template">
	${make_row('group-[COUNT].', "NEW")}
</script>

<%def name="bottomjs()">
${sc.shown_cultures_js()}
<script type="text/javascript">
	jQuery(function($) {
		var count = 999999;
		$('#add-row').click(function(evt) {
			var self = $(this), parent = self.parents('tr').first(),
				row = $($('#new-item-template')[0].innerHTML.replace(/\[COUNT\]/g, count++));

			evt.preventDefault()
			$('.ShowCultures').each(function() {
				if (this.checked) {
					row.find('.culture-' + this.value).show();
				} else {
					row.find('.culture-' + this.value).hide();
				}
			});
			parent.before(row);
			return false;
		});
	});
</script>
</%def>

<%def name="make_row(prefix, itemid)">
<tr>
	<td>
		${renderer.hidden(prefix + 'DisplayFieldGroupID', itemid)}
		<% row_title = [model_state.value(prefix + 'Descriptions.' + culture_map[culture].FormCulture + '.Name') for culture in record_cultures if model_state.value(prefix + 'Descriptions.' + culture_map[culture].FormCulture + '.Name') is not None] %>
		<% row_title = row_title[0] if row_title else _('New') %>
		${renderer.checkbox(prefix + 'delete', title=row_title + _(': Delete'))}
	</td>

	<td>
		%for culture in record_cultures:
		<%
			lang = culture_map[culture]
			field_name = prefix + 'Descriptions.' + lang.FormCulture + '.Name'
		%>
		<div ${sc.shown_cultures_attrs(culture)}>
			<div class="form-group row">
				${renderer.label(field_name, lang.LanguageName, class_='control-label col-xs-3')}
				<div class="col-xs-9">
					${renderer.errorlist(field_name)}
					${renderer.text(field_name, maxlength=100, class_=('form-control ' + '' if model_state.value(field_name) or itemid == 'NEW' else 'AlertBorder'))}
				</div>
			</div>
		</div>
		%endfor
	</td>

	<td>
		${renderer.errorlist(prefix + 'DisplayOrder')}${renderer.text(prefix + 'DisplayOrder', "0", title=row_title + _(': Order'), size=3, maxlength=3, class_='form-control')}
	</td>
</tr>
</%def>

