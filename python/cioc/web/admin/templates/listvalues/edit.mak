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
from markupsafe import Markup
%>
<%
makeLink = request.passvars.makeLink
route_path = request.passvars.route_path
HeaderClass = Markup('class="RevTitleBox"')

if list_type.ExtraFields and any(x['type'] == 'language' for x in list_type.ExtraFields):
	_context.langauges = [(x, culture_map[x].LanguageName) for x in record_cultures]
%>
<h2>${renderinfo.doc_title}</h2>


<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
| <a href="${route_path('admin_listvalues',_query=[('list',list_type.FieldCode), ('PrintMd', 'on')])}" target="_blank">${_('Print Version (New Window)')}</a>
]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
%if list_type.ShowNotice1:
	${_(list_type.ShowNotice1)|n}
%endif
<p class="Alert">${_('Note that %s in records are not confined to these values, and changes to these values will not alter existing records. This list only limits what is displayed as an option on update and feedback forms.') % _(list_type.ListNamePlural)}</p>

<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="list" value="${list_type.FieldCode}">
</div>

<table class="BasicBorder cell-padding-3">
${make_table_header()}

<% index = -1 %>
%for index, listitem in enumerate(listitems):
<%
	prefix = 'listitem-' + str(index) + '.'
	id_field = list_type.ID or list_type.NameField
	if isinstance(listitem, dict):
		listid = listitem.get(id_field)
	else:
		listid = getattr(listitem, id_field)

%>

${make_row(prefix, listitem, listid)}
%endfor


<tr>
	<% colspan = 2 + bool(list_type.Usage) + len(list_type.ExtraFields or []) %>
	<td colspan="${colspan}">
	<button class="add-row" data-count="${index+1}" data-action-col="true">${_('Add New Item')}</button>
	<input type="submit" name="Submit" value="${_('Update')}">
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>

</table>

</form>

</div>
<script type="text/html" id="new-item-template">
${make_row('listitem-[COUNT].', None, "NEW", True)}
</script>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	$('.add-row').click(function(evt) {
		var self = $(this), parent = self.parents('tr').first(), count = self.data('count'),
			row = $($('#new-item-template')[0].innerHTML.replace(/\[COUNT\]/g, count++).
				replace(/\[ACTION_COL\]/g, self.data('actionCol') ? '<td></td>' : ''));



		self.data('count', count);

		evt.preventDefault()
		self.parents('form').first().find('.ShowCultures').each(function() {
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


<%def name="make_row(prefix, listitem, itemid, ForceDeleteable=False)">
<% title_suffix = model_state.value(prefix+list_type.NameField) or _('New') %>
<tr>
	<td align="center">
	%if ForceDeleteable or list_type.can_delete_item(itemid):
		${renderer.errorlist(prefix + 'delete')}

		${renderer.checkbox(prefix + 'delete', title=_('Delete Item: ') + title_suffix)}
	%endif
	${renderer.hidden(prefix + (list_type.ID or 'OldValue'), itemid)}
	</td>
	<td>
	${renderer.errorlist(prefix + list_type.NameField)}
	${renderer.text(prefix+list_type.NameField, title=_('Item Name: ') + title_suffix, maxlength=list_type.NameFieldMaxLength, size=list_type.NameFieldSize)}
	</td>

## extra fields
%for field in list_type.ExtraFields or []:
<% fn = getattr(renderer, field['type'], None) %>
		<td align="center">
		${renderer.errorlist(prefix + field['field'])}
		%if field['type'] == 'language':
		${renderer.select(prefix + field['field'], _context.langauges, title=_('Language: ') + title_suffix, **field['kwargs'])}
		%else:
		<% element_title = field.get('element_title') %>
		%if element_title is not None:
			<% element_title += title_suffix %>
		%endif
		${fn(prefix+field['field'], title=element_title, **field['kwargs'])}
		%endif
		</td>
%endfor


%if list_type.Usage:
	<%
		usage = list_type.Usage.get(str(renderer.value(prefix + (list_type.ID or list_type.NameField))))
		usage1 = getattr(usage, 'Usage1', None)
		usage2 = getattr(usage, 'Usage2', None)
	%>
	<td>
%if usage1:
	${'' if not list_type.SearchLinkTitle1 else _(list_type.SearchLinkTitle1)}
		<a href="${makeLink(*list_type.SearchLink1).replace('IDIDID', str(itemid).replace("'", "''"))}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17", height="14", border="0", title="${_('Usage: %d') % usage1}"></a>

	%endif
	%if usage1 and usage2:
	<br>
	%endif
	%if usage2:
	${'' if not list_type.SearchLinkTitle2 else _(list_type.SearchLinkTitle2)}
		<a href="${makeLink(*list_type.SearchLink2).replace('IDIDID', str(itemid).replace("'", "''"))}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17", height="14", border="0", title="${_('Usage: %d') % usage2}"></a>

	%endif
	</td>
%endif


</tr>
</%def>
<%def name="make_table_header()">
<tr>

	<th ${HeaderClass}>${_('Delete')}</th>

	<th ${HeaderClass}>${_('Name')}</th>

## extra fields
%for field in list_type.ExtraFields or []:
		<th ${HeaderClass}>${_(field['title'])}</th>
%endfor



%if list_type.Usage:
	<th ${HeaderClass}>${_('Usage')}</th>
%endif

</tr>
</%def>
