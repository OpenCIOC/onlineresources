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
<form method="post" action="${request.route_path('admin_naics', action='exclusion')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="Code" value="${Code}">
</div>

<p class="Info">${_('To find a NAICS Code, use the')} <a href="${request.passvars.makeLink('~/naicsfind.asp')}" class="poplink" target="_BLANK" data-popargs="{size:'sm',name:'sFind'}">${_('NAICS Code Finder')}</a></p>

<table class="BasicBorder cell-padding-3">
<tr><th colspan="2">${renderinfo.doc_title}</th></tr>
<tr><th>${_('Delete')}</th><th>${_('Exclusion')}</th></tr>

<% 
language_options = (culture_map[culture] for culture in active_cultures)
self.language_options = [(x.LangID, x.LanguageName) for x in language_options]
%>
%for index, exclusion in enumerate(exclusions):
<% 
	prefix = 'exclusion-' + str(index) + '.' 
	if isinstance(exclusion, dict):
		exclusionid = exclusion.get('Exclusion_ID')
		use_codes = exclusion.get('UseCodes')
	else:
		exclusionid = exclusion.Exclusion_ID
		use_codes = exclusion.UseCodes
%>
	${make_row(prefix, exclusionid, use_codes)}
%endfor


<tr>
	<td colspan="2">
	<button id="add-row">${_('Add New Item')}</button>
	<input type="submit" name="Submit" value="${_('Update')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>

</form>
</div>


<script type="text/html" id="new-item-template">
${make_row('exclusion-[COUNT].', "NEW")}
</script>

<%def name="bottomjs()">
<script type="text/javascript">
(function() {
var $ = jQuery,
naics_re = /^\d{2,63}$/,
add_code = function(evt) {
	var chkitem = null, self = $(this), parent = self.parent(), input = parent.find('.ADD_Code_Source'),
		target = parent.find('.ADD_Code_Target'), val = $.trim(input[0].value), intval = parseInt(val, 10),
		existing_error = parent.find('.ADD_Error'), chkname=input.data('fieldname');

	evt.preventDefault()

	if (!val) {
		return false;
	}
	if ( !naics_re.test(val) || intval < 11 || intval > 999999) {
		// XXX invalid naics code
		$('<p class="Alert ADD_Error">').hide().text("${_('Invalid NAICS Code')|n}").insertBefore(input).show('fast');
	} else {
		//valid naics code
		chkitem = target.find('input[value="' + val + '"]');
		if (chkitem.length > 0) {
			// already there
			chkitem.attr('checked', true);
		} else {
			target.append($('<label><input type="checkbox" value="' + val + '" name="' + chkname + '" checked> ' + val + '</label>'))
		}

		input[0].value = '';
	}
	existing_error.hide('fast');

	return false;

};
jQuery(function($) {
	var count = 999999;
	$('#add-row').click(function(evt) {
		var self = $(this), parent = self.parents('tr').first(),
			row = $($('#new-item-template')[0].innerHTML.replace(/\[COUNT\]/g, count++));

		evt.preventDefault()
		parent.before(row);

		return false;
	});

	$('.ADD_Code').live('click', add_code);
});
})();
</script>
</%def>

<%def name="make_row(prefix, itemid, use_codes=[])">
<tr>
	<td>
		${renderer.hidden(prefix + 'Exclusion_ID', itemid)}
		${renderer.checkbox(prefix + 'delete')}
	</td>

	<td>
	<table class="NoBorder cell-padding-2">
	<tr><td colspan="2">${renderer.errorlist(prefix + 'Establishment')}
	${renderer.checkbox(prefix + 'Establishment', label=_('Establishments primarily engaged in'))}
	</td></tr>
	<tr>
		<td class="FieldLabelLeftClr">${renderer.label(prefix + 'Description', _('Description'))}</td>
		<td>${renderer.errorlist(prefix + 'Description')}
			${renderer.text(prefix + 'Description', maxlength=255)}
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeftClr">${renderer.label(prefix + 'LangID', _('Language'))}</td>
		<td>${renderer.errorlist(prefix + 'LangID')}
			${renderer.select(prefix + 'LangID', options=self.language_options)}
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeftClr">${_('Use Code(s)')}</td>
		<td><div class="ADD_Code_Target">
			%for code in use_codes:
			${renderer.ms_checkbox(prefix + 'UseCodes', code, label=code)}
			%endfor
		</div>
		<input type="text" class="ADD_Code_Source" data-fieldname="${prefix}UseCodes"> <button class="ADD_Code">${_('Add Code')}</button>
		</td>
	</tr>
	</table>
	</td>

</tr>
</%def>

