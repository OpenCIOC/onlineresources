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
<%! 
from cioc.core import constants as const
%>
<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

<h2>${renderinfo.doc_title}</h2>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
<input type="hidden" name="ViewType" value="${ViewType}">
</div>

<table class="BasicBorder cell-padding-3">
<tr><th>${_('Delete')}</th><th>${_('Quick Search Settings')}</th><th>${_('Order')}</th></tr>

%for index, quicksearch in enumerate(renderer.value('quicksearch') or []):
<% 
	prefix = 'quicksearch-' + str(index) + '.' 
	if isinstance(quicksearch, dict):
		quicksearchid = quicksearch.get('QuickSearchID')
	else:
		quicksearchid = quicksearch.QuickSearchID
%>
	${make_row(prefix, quicksearchid)}
%endfor


<tr>
	<td colspan="3">
	<button id="add-row">${_('Add New Item')}</button>
	<input type="submit" name="Submit" value="${_('Update')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>

</form>


<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>
</div>

<script type="text/html" id="new-item-template">
${make_row('quicksearch-[COUNT].', "NEW")}
</script>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	var count = 999999;
	$('#add-row').click(function(evt) {
		var self = $(this), parent = self.parents('tr').first(),
			row = $($('#new-item-template')[0].innerHTML.replace(/\[COUNT\]/g, count++));

		evt.preventDefault()
		parent.before(row);
		return false;
	});
});
</script>
</%def>

<%def name="make_row(prefix, itemid)">
<tr>
	<td>
	${renderer.hidden(prefix + 'QuickSearchID', itemid)}
	${renderer.checkbox(prefix + 'delete')}
	</td>

	<td>
	<table class="NoBorder cell-padding-2">
	%for culture in active_cultures:
	<% 
		lang = culture_map[culture]
		field_name = prefix + 'Descriptions.' + lang.FormCulture + '.Name'
	%>
	<tr><td class="FieldLabelLeftClr">${renderer.label(field_name, _('Name (%s)') % lang.LanguageName)}</td>
	<td>${renderer.errorlist(field_name)}${renderer.text(field_name, maxlength=100, size=50, class_=('' if model_state.value(field_name) or itemid == 'NEW' else 'AlertBorder'))}</td>
	</tr>
	%endfor
	<tr>
		<% field_name = prefix + 'PageName' %>
		<td class="FieldLabelLeftClr">${renderer.label(field_name, _('Search Page'))}</td>
		<td>${renderer.errorlist(field_name)}${renderer.select(field_name, options=pages)}</td>
	</tr>
	<tr>
		<% field_name = prefix + 'QueryParameters' %>
		<td class="FieldLabelLeftClr">${renderer.label(field_name, _('Query Parameters'))}</td>
		<td>${renderer.errorlist(field_name)}${renderer.text(field_name, maxlength=1000, size=50)}</td>
	</tr>
	<tr>
		<% field_name = prefix + 'PromoteToTab' %>
		<td class="FieldLabelLeftClr">${_('Show in Tab')}</td>
		<td>${renderer.errorlist(field_name)}${renderer.checkbox(field_name, label=_('Promote to Tab (tabbed search form only)'))}</td>
	</tr>
	</table>
	</td>

	<td>${renderer.errorlist(prefix + 'DisplayOrder')}${renderer.text(prefix + 'DisplayOrder', "0", size=3, maxlength=3)}</td>
</tr>
</%def>

