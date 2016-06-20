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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | 
	<a href="${request.passvars.route_path('admin_naics_index')}">${_('Return to NAICS Management')}</a> |
	<a href="${request.passvars.route_path('admin_naics', action='edit', _query=[('Code', Code)])}">${_('Return to NAICS Code: %s') % Code}</a> ]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
<form method="post" action="${request.route_path('admin_naics', action='example')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="Code" value="${Code}">
</div>

<table class="BasicBorder cell-padding-3">
<tr><th colspan="3">${renderinfo.doc_title}</th></tr>
<tr><th>${_('Delete')}</th><th>${_('Language')}</th><th>${_('Example')}</th></tr>

<% 
language_options = (culture_map[culture] for culture in active_cultures)
self.language_options = [(x.LangID, x.LanguageName) for x in language_options]
%>
%for index, example in enumerate(examples):
<% 
	prefix = 'example-' + str(index) + '.' 
	if isinstance(example, dict):
		exampleid = example.get('Example_ID')
	else:
		exampleid = example.Example_ID
%>
	${make_row(prefix, exampleid)}
%endfor


<tr>
	<td colspan="3">
	<button id="add-row">${_('Add New Item')}</button>
	<input type="submit" name="Submit" value="${_('Update')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>

</form>
</div>


<%def name="bottomjs()">
<script type="text/html" id="new-item-template">
${make_row('example-[COUNT].', "NEW")}
</script>

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
		${renderer.hidden(prefix + 'Example_ID', itemid)}
		${renderer.checkbox(prefix + 'delete')}
	</td>

	<td>${renderer.errorlist(prefix + 'LangID')}
		${renderer.select(prefix + 'LangID', options=self.language_options)}
	</td>
	<td>${renderer.errorlist(prefix + 'Description')}
		${renderer.text(prefix + 'Description', maxlength=255)}
	</td>
</tr>
</%def>

