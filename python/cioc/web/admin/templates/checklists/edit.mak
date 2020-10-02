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
from markupsafe import Markup
import six
%>
<% 
makeLink = request.passvars.makeLink 
route_path = request.passvars.route_path
HeaderClass = Markup('class="RevTitleBox"')
MissingLangClass = 'AlertBorder' if chk_type.HighlightMissingLang else ''
user = request.user
SuperUserGlobal = (chk_type.Domain.id == const.DM_CIC and user.cic.SuperUserGlobal) or (chk_type.Domain.id == const.DM_VOL and user.vol.SuperUserGlobal) or (chk_type.Domain.id == const.DM_GLOBAL and user.SuperUserGlobal)

member_name_cic = request.dboptions.get_best_lang('MemberNameCIC')
member_name_vol = request.dboptions.get_best_lang('MemberNameVOL')

if member_name_cic == member_name_vol:
	member_name = member_name_cic
elif member_name_cic is None:
	member_name = member_name_vol
elif member_name_vol is None:
	member_name = member_name_cic
elif chk_type.Domain.id == const.DM_CIC:
	member_name = member_name_cic
elif chk_type.Domain.id == const.DM_VOL:
	member_name = member_name_vol
else:
	member_name = _('; ').join((member_name_cic, member_name_vol))
%>
<h2>${renderinfo.doc_title}</h2>


<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
%if _context.OtherMembersActive and chk_type.Shared == 'partial':
| <a href="${route_path('admin_checklists',_query=[('chk',chk_type.FieldCode)])}">${_('Back to Manage Values')}</a>
%else:
| <a href="${route_path('admin_checklists',_query=[('chk',chk_type.FieldCode), ('PrintMd', 'on')])}" target="_blank">${_('Print Version (New Window)')}</a>
%endif
]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
%if chk_type.ShowNotice1:
	${_(chk_type.ShowNotice1)|n}
%endif
%if chk_type.ShowNotice2:
<p class="Alert">${_('Note that changing an existing value will alter that value in every record in the database that uses it. In some cases this will cause a lag in database responsiveness while the records are updated and re-indexed.')}</p>
%endif

%if chk_type.Shared == 'partial' and request.dboptions.OtherMembersActive:
<h3>${_('Values for %s') % member_name}</h3>
%endif
<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="chk" value="${chk_type.FieldCode}">
</div>

${sc.shown_cultures_ui()}



<table class="BasicBorder cell-padding-3">
${make_table_header()}

<% index = -1 %>
%for index, chkitem in enumerate(chkitems):
<% 
	prefix = 'chkitem-' + str(index) + '.' 
	if isinstance(chkitem, dict):
		chkid = chkitem.get(chk_type.ID)
	else:
		chkid = getattr(chkitem, chk_type.ID)
%>

${make_row(prefix, chkitem, chkid)}
%endfor


<tr>
	<% colspan = (len(record_cultures) * (1 + len(chk_type.ExtraNameFields or []))) + bool(chk_type.CodeTitle) + (bool(chkusage and (chk_type.SearchLink or chk_type.SearchLink2)) * 2) + bool(chk_type.DisplayOrder) + len(chk_type.ExtraFields or []) + 1 + (SuperUserGlobal and chk_type.Shared == 'partial') + bool(chk_type.SearchParameter and request.params.get("SearchParameterKey")) %>
	<td colspan="${colspan}">
	%if chk_type.ShowAdd:
	<button class="add-row" data-count="${index+1}">${_('Add New Item')}</button>
	%endif
	<input type="submit" name="Submit" value="${_('Submit Changes')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>

</table>

</form>

</div>
%if chk_type.ShowAdd:
<script type="text/html" id="new-item-template">
${make_row('chkitem-[COUNT].', None, "NEW", True)}
</script>
%endif

<%def name="bottomjs()">
${sc.shown_cultures_js()}
%if chk_type.ShowAdd:
	%if chk_type.HasMunicipality:
	<% renderinfo.list_script_loaded = True %>
	${request.assetmgr.JSVerScriptTag('scripts/checklists.js')}
	%endif
<script type="text/javascript">
jQuery(function($) {
	var cm_link = '${request.passvars.makeLink("~/jsonfeeds/community_generator.asp")}',
		cm_error = '${_("An unknown community was entered")}';
	$('.add-row').click(function(evt) {
		var self = $(this), parent = self.parents('tr').first(), count = self.data('count'),
			row = $($('#new-item-template')[0].innerHTML.replace(/\[COUNT\]/g, count++));



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
		%if chk_type.HasMunicipality:
		init_municipality_autocomplete(row.find('.municipality'), cm_link, cm_error);
		%endif
		return false;
	});
	%if chk_type.HasMunicipality:
	init_municipality_autocomplete($('.municipality'), cm_link, cm_error);
	%endif
});
</script>
%endif
</%def>


<%def name="make_row(prefix, chkitem, itemid, ForceDeleteable=False)">
<tr>
## prefix fields
%for field in chk_type.PrefixFields or []:
	<td>${field['body'](itemid, chkusage, request)}</td>
%endfor
<% display_cultures = [model_state.value(prefix + 'Descriptions.' + culture_map[item].FormCulture + '.Name') for item in record_cultures if model_state.value(prefix + 'Descriptions.' + culture_map[item].FormCulture + '.Name') is not None] %>
<% title = model_state.value(prefix+chk_type.CodeField) or display_cultures[0] if display_cultures else model_state.value(prefix+chk_type.CodeField)%>
<% title = six.text_type(title or _('New')) %>
%if chk_type.CanDelete:
	<td class="text-center">
	%if ForceDeleteable or chk_type.can_delete_item(itemid, chkusage):
		${renderer.errorlist(prefix + 'delete')}
		
		${renderer.checkbox(prefix + 'delete', title=_('Delete Item: ') + title)}
	%endif
	</td>
%endif
	%if chk_type.CodeTitle:
		<td> 
		${renderer.errorlist(prefix + chk_type.CodeField)}
		<% kwargs = {'title': _('Item Code: ') + title} if not chk_type.CodeTip else {'title': _(chk_type.CodeTip)} %>
		${renderer.text(prefix+chk_type.CodeField, maxlength=chk_type.CodeMaxLength, size=chk_type.CodeSize, **kwargs)}
		</td>
	%endif

	%for i,culture in enumerate(record_cultures):
	<% 
		lang = culture_map[culture]
		field_name = prefix + 'Descriptions.' + lang.FormCulture + '.Name'
	%>
	<td ${sc.shown_cultures_attrs(culture)}>
		%if not i:
			${renderer.hidden(prefix + chk_type.ID, itemid)}
		%endif
	${renderer.errorlist(field_name)}${renderer.text(field_name, title=_('Display Text For ') + lang.LanguageName, maxlength=200, size=33, class_='' if model_state.value(field_name) else MissingLangClass)}
	</td>
	%for field in chk_type.ExtraNameFields or []:
		<% field_name = prefix + 'Descriptions.' + lang.FormCulture + '.' + field['field'] %>
		<td ${sc.shown_cultures_attrs(culture)}>
			${renderer.errorlist(field_name)}
			${getattr(renderer, field['type'])(field_name, **field['kwargs'])}
		</td>
	%endfor
	%endfor

## extra fields
%for field in chk_type.ExtraFields or []:
<% fn = getattr(renderer, field['type'], None) %>
		<td>
		${renderer.errorlist(prefix + field['field'])}
		%if field['type'] == 'municipality':
		${renderer.hidden(prefix + field['field'], id=(prefix + field['field']).replace('.','_'))}
		${renderer.text(prefix + field['field'] + 'Web', id=(prefix + field['field'] + 'Web').replace('.','_'), **field['kwargs'])}
		%else:
		${fn(prefix+field['field'], title=field['title'], **field['kwargs'])}
		%endif
		</td>
%endfor

%if chk_type.ShowOnForm:
	<td align="center">
	${renderer.errorlist(prefix + 'ShowOnForm')}
	${renderer.checkbox(prefix + 'ShowOnForm')}
	</td>
%endif

	%if chk_type.DisplayOrder:
	<td>
	${renderer.errorlist(prefix + 'DisplayOrder')}
	${renderer.text(prefix + 'DisplayOrder', title=_('Display Order: ') + title, maxlength=3)}
	</td>
	%endif

%if chkusage and (chk_type.SearchLink or chk_type.SearchLink2):
<% 
types = ['Local']
if _context.OtherMembersActive:
	types.append('Other')
%>
%for which in  types:
	<% 
		usage = chkusage.get(six.text_type(renderer.value(prefix + chk_type.ID)))
		usage1 = getattr(usage, 'Usage1' + which, None)
		usage2 = getattr(usage, 'Usage2' + which, None)
	%>
	<td>
%if usage1:
	${'' if not chk_type.SearchLinkTitle else _(chk_type.SearchLinkTitle)} 
		%if which == 'Local':
		<a href="${makeLink(*chk_type.SearchLink).replace('IDIDID', str(itemid))}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17" height="14" border="0" title="${_('Usage: %d') % usage1}"></a>
		%else:
		${usage1}
		%endif
	
	%endif
	%if usage1 and usage2:
	<br>
	%endif
	%if usage2:
	${'' if not chk_type.SearchLinkTitle2 else _(chk_type.SearchLinkTitle2)} 
		%if which == 'Local':
		<a href="${makeLink(*chk_type.SearchLink2).replace('IDIDID', str(itemid))}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17", height="14", border="0", title="${_('Usage: %d') % usage2}"></a>
		%else:
		${usage2}
		%endif
	
	%endif
	</td>
%endfor
%endif

%if SuperUserGlobal and chk_type.Shared=='partial':
	%if ForceDeleteable:
		[ACTION_COL]
	%endif
%endif

%if chk_type.SearchParameter and request.params.get("SearchParameterKey"):
	<td><div class="HighLight">${chk_type.SearchParameter}=${itemid}</div>
	%if chk_type.SearchParameter2:
	<div class="HighLight">${chk_type.SearchParameter2}=${itemid}</div>
	%endif
	</td>
%endif

</tr>
</%def>
<%def name="make_table_header()">
<tr>

%if chk_type.CanDelete:
	<th ${HeaderClass}>${_('Delete')}</th>
%endif

## prefix fields
%for field in chk_type.PrefixFields or []:
	<th ${HeaderClass}>${_(field['header'])}</th>
%endfor

	%if chk_type.CodeTitle :
		<th ${HeaderClass}>${_(chk_type.CodeTitle)}
		%if chk_type.CodeValidator and chk_type.CodeValidator.not_empty:
			<span class="Alert">*</span>
		%endif
		</th>
	%endif
	
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<th ${sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_('Display')} (${lang.LanguageName})</th>
	%for field in chk_type.ExtraNameFields or []:
		<th ${sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_(field['title']) % lang.LanguageName}</th>
	%endfor
%endfor

## extra fields
%for field in chk_type.ExtraFields or []:
		<th ${HeaderClass}>${_(field['title'])}
		%if field['validator'].not_empty:
			<span class="Alert">*</span>
		%endif
		</th>
%endfor


	%if chk_type.ShowOnForm:
	<th ${HeaderClass}>${_('Show On Form')}</th>
	%endif
	%if chk_type.DisplayOrder:
	<th ${HeaderClass}>${_('Order')}</th>
	%endif

	%if chkusage and (chk_type.SearchLink or chk_type.SearchLink2):
	<th ${HeaderClass}>${_('Local Records') if _context.OtherMembersActive else _('Usage')}</th>
	%if _context.OtherMembersActive:
	<th ${HeaderClass}>${_('Other Records')}</th>
	%endif
	%endif

	%if chk_type.SearchParameter and request.params.get("SearchParameterKey"):
		<th ${HeaderClass}>${_('Search Parameter')}</th>
	%endif

</tr>
</%def>
