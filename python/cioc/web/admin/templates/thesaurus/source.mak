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
	<a href="${request.passvars.makeLink('~/admin/thesaurus.asp')}">${_('Return to Manage Thesaurus')}</a> ]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
<form method="post" action="${request.route_path('admin_thesaurus', action='source')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
</div>

<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${_('Delete')}</th>
	<th class="RevTitleBox">${_('Name')} <span class="Alert">*</span></th>
</tr>

<% 
	language_options = (culture_map[culture] for culture in active_cultures)
	language_options = [(x.LangID, x.LanguageName) for x in language_options]
%>
%for index, source in enumerate(sources):
<% 
	prefix = 'source-' + str(index) + '.' 
	if isinstance(source, dict):
		sourceid = source.get('SRC_ID')
	else:
		sourceid = source.SRC_ID
%>
	${make_row(prefix, sourceid)}
%endfor


<tr>
	<td colspan="3">
	<button id="add-row">${_('Add New Item')}</button>
	<input type="submit" name="Submit" value="${_('Submit Changes')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>

</form>
</div>


<script type="text/html" id="new-item-template">
${make_row('source-[COUNT].', "NEW")}
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
	<% args = [True] if itemid == 'NEW' else [] %>
	<td>
		${renderer.hidden(prefix + 'SRC_ID', itemid)}
	%if not usage.get(unicode(itemid)):
		${renderer.checkbox(prefix + 'delete')}
	%endif
	</td>

	<td><table class="NoBorder cell-padding-2">
	%for culture in active_cultures:
	<% lang = culture_map[culture] %>
	<tr>
		<td class="FieldLabelLeftClr">${renderer.label(prefix+'Descriptions.' + lang.FormCulture+ '.SourceName', lang.LanguageName)}</td>
		<td>
		${renderer.errorlist(prefix+'Descriptions.' + lang.FormCulture+ '.SourceName')}
		${renderer.text(prefix+'Descriptions.' + lang.FormCulture+ '.SourceName', maxlength=100)}
		</td>
	</tr>
	%endfor
	</table></td>
</tr>
</%def>

