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
PrintMode = request.viewdata.PrintMode
HeaderClass = '' if PrintMode else Markup('class="RevTitleBox"')
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
	member_name = _('; ').join([member_name_cic, member_name_vol])
%>
<h2>${chk_type.CheckListName if PrintMode else _(chk_type.ManagePageTitleTemplate).format(chk_type.CheckListName)}</h2>


%if not PrintMode:
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
%if not SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', chk_type.AdminAreaCode)])}">${_('Request Change')}</a>
%endif
| <a href="${request.passvars.route_path('admin_checklists', _query=[('chk',chk_type.FieldCode), ('PrintMd', 'on')])}" target="_blank">${_('Print Version (New Window)')}</a>
]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
%if chk_type.ShowNotice1:
	${_(chk_type.ShowNotice1)|n}
%endif

%if chk_type.Shared != 'full':
<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="chk" value="${chk_type.FieldCode}">
<input type="hidden" name="which" value="local">
</div>
%endif

${sc.shown_cultures_ui(False)}
%endif



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

%if not PrintMode and chk_type.Shared != 'full':

<tr>
	<% colspan = (len(record_cultures) * (1+ len(chk_type.ExtraNameFields or []))) + bool(chk_type.CodeTitle) + (bool(chkusage and (chk_type.SearchLink or chk_type.SearchLink2)) * 2) + bool(chk_type.DisplayOrder) + len(chk_type.ExtraFields or []) + 1 + (2 * int(chk_type.Shared != 'full')) + (3 * int(chk_type.Shared != 'full' and SuperUserGlobal)) + bool(chk_type.SearchParameter and request.params.get('SearchPareterKey')) %>
	<td colspan="${colspan}">
	<input type="submit" name="Submit" value="${_('Update "Hide" State')}"> 
	<input type="reset" value="${_('Reset Form')}">

%if SuperUserGlobal:
<button onclick="window.location.href='${request.passvars.route_path('admin_checklists_shared', _query=[('chk', chk_type.FieldCode)])}'; return false;">${_('Add / Edit All Shared Values')}</button> 
%endif
<button onclick="window.location.href='${request.passvars.route_path('admin_checklists_local', _query=[('chk', chk_type.FieldCode)])}'; return false;">${_('Add / Edit All Local Values')}</button>
	</td>
</tr>
%endif

</table>

%if not PrintMode and chk_type.Shared != 'full':
</form>
%endif


%if not PrintMode:
</div>
%endif

<%def name="bottomjs()">
%if not request.viewdata.PrintMode:
${sc.shown_cultures_js()}
%endif
</%def>


<%def name="make_row(prefix, chkitem, itemid)">
<% row_title = [] %>
<% PrintMode = request.viewdata.PrintMode %>
<tr>
## prefix fields
%for field in chk_type.PrefixFields or []:
	<td>${field['body'](itemid, chkusage, request)}</td>
%endfor

	%if chk_type.CodeTitle:
		<td> 
		${row_title.append(getattr(chkitem,chk_type.CodeField))}
		${getattr(chkitem,chk_type.CodeField)}
		</td>
	%endif

	%for i,culture in enumerate(record_cultures):
	<% 
		lang = culture_map[culture]
		name = chkitem.Descriptions.get(lang.FormCulture, {}).get('Name')
		row_title.append(name)
	%>
	<td ${'' if PrintMode else sc.shown_cultures_attrs(culture)}>
	${name}
	</td>
	%for field in chk_type.ExtraNameFields or []:
		<% field_name = prefix + 'Descriptions.' + lang.FormCulture + '.' + field['field'] %>
		<td ${sc.shown_cultures_attrs(culture)}>
			${chkitem.Descriptions.get(lang.FormCulture, {}).get(field['field'])}
		</td>
	%endfor

	%endfor

## extra fields
%for field in chk_type.ExtraFields or []:
		<td>
		%if field['type'] == 'checkbox':
			${'*' if getattr(chkitem, field['field']) else ''}
		%elif field['type'] == 'municipality':
			${getattr(chkitem, field['field'] + 'Web')}
		%else:
			${getattr(chkitem, field['field'])}
		%endif
		</td>
%endfor

%if chk_type.ShowOnForm:
	<td align="center">
	${'*' if chkitem.ShowOnForm else ''}
	</td>
%endif

	%if chk_type.DisplayOrder and not PrintMode:
	<td>
	${chkitem.DisplayOrder}
	</td>
	%endif

	%if chk_type.Shared != 'full' and _context.OtherMembersActive:
	<td align="center">
	${'*' if chkitem.MemberID is None else ''}
	</td>
	<td align="center">
	${'*' if chkitem.MemberID == request.dboptions.MemberID else ''}
	</td>
	%if SuperUserGlobal:
	<td align="center">
	${'*' if chkitem.MemberID is not None and chkitem.MemberID != request.dboptions.MemberID else ''}
	</td>
	<td>${chkitem.MemberName}</td>
	%endif
	%endif

%if PrintMode:
	<td>${format_date(chkitem.MODIFIED_DATE) or _('Unknown')} (${chkitem.MODIFIED_BY or _('Unknown')})</td>
%endif #Print Mode

%if chkusage and (chk_type.SearchLink or chk_type.SearchLink2):
<%
types = ['Local']
if _context.OtherMembersActive:
	types.append('Other')
%>
%for which in types:
	<% 
		usage = chkusage.get(six.text_type(getattr(chkitem, chk_type.ID)))
		usage1 = getattr(usage, 'Usage1' + which, None)
		usage2 = getattr(usage, 'Usage2' + which, None)
	%>
	<td>
	%if usage1:
	${'' if not chk_type.SearchLinkTitle else _(chk_type.SearchLinkTitle)} 
		%if which == 'Local' and not PrintMode:
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
		%if which == 'Local' and not PrintMode:
		<a href="${makeLink(*chk_type.SearchLink2).replace('IDIDID', str(itemid))}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17" height="14" border="0" title="${_('Usage: %d') % usage2}"></a>
		%else:
		${usage2}
		%endif
	
	%endif
	</td>
%endfor
%endif

%if not PrintMode and chk_type.Shared != 'full':
	<td style="text-align:center">
	<% row_title = [item for item in row_title if item is not None] %>
	<% row_title = row_title[0] if len(row_title) else _('New') %>
	%if not isinstance(row_title, str):
	<% row_title = str(row_title) %>
	%endif
	%if not getattr(chkitem, 'MemberID', None):
	${renderer.ms_checkbox('ChkHide', getattr(chkitem, chk_type.ID), title=_('Hide Item: ') + row_title)}
	%endif
	</td>
		<td>
			<% chk_member_id = getattr(chkitem, 'MemberID', None) %>
			%if chk_member_id == request.dboptions.MemberID:
				<a href="${request.passvars.route_path('admin_checklists_local', _query=[('chk',chk_type.FieldCode)])}">${_('Edit')}</a>
			%elif chk_member_id is None:
				%if SuperUserGlobal:
					<a href="${request.passvars.route_path('admin_checklists_shared', _query=[('chk',chk_type.FieldCode)])}">${_('Edit')}</a>
				%else:
					<a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', chk_type.AdminAreaCode)])}">${_('Request Change')}</a>
				%endif
			%endif
			%if SuperUserGlobal:
				%if chk_member_id:
					%if chk_member_id == request.dboptions.MemberID:
						|
					%endif
					<a href="${request.passvars.route_path('admin_checklists_sharedstate', _query=[('chk', chk_type.FieldCode),('state','shared'), ('ID',str(itemid))])}">${_('Make Shared')}</a>
				%endif
			%endif
		</td>
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

## prefix fields
%for field in chk_type.PrefixFields or []:
	<th ${HeaderClass}>${_(field['header'])}</th>
%endfor

	%if chk_type.CodeTitle:
		<th ${HeaderClass}>${_(chk_type.CodeTitle)}</th>
	%endif
	
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<th ${'' if PrintMode else sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_('Display')} (${lang.LanguageName})</th>
	%for field in chk_type.ExtraNameFields or []:
		<th ${sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_(field['title']) % lang.LanguageName}</th>
	%endfor
%endfor

## extra fields
%for field in chk_type.ExtraFields or []:
		<th ${HeaderClass}>${_(field['title'])}</th>
%endfor


	%if chk_type.ShowOnForm:
	<th ${HeaderClass}>${_('Show On Form')}</th>
	%endif
	%if chk_type.DisplayOrder and not PrintMode:
	<th ${HeaderClass}>${_('Order')}</th>
	%endif

	%if chk_type.Shared != 'full' and _context.OtherMembersActive:
	<th ${HeaderClass}>${_('Shared')}</th>
	<th ${HeaderClass}>${_('Local')}</th>
	%if SuperUserGlobal:
	<th ${HeaderClass}>${_('Other')}</th>
	<th ${HeaderClass}>${_('Member')}</th>
	%endif
	%endif

%if not PrintMode:
	%if chkusage and (chk_type.SearchLink or chk_type.SearchLink2):
	<th ${HeaderClass}>${_('Local Records')}</th>
	<th ${HeaderClass}>${_('Other Records')}</th>
	%endif
	%if chk_type.Shared != 'full':
	<th ${HeaderClass}>${_('Hide')}</th>
	<th ${HeaderClass}>${_('Action')}</th>
	%endif

%else:
	<th>${_('Last Modified')}</th>
	%if chkusage and (chk_type.SearchLink or chk_type.SearchLink2):
	<th>${_('Local Records') if _context.OtherMembersActive else _('Usage')}</th>
	%if _context.OtherMembersActive:
	<th>${_('Other Records')}</th>
	%endif
	%endif
%endif
%if chk_type.SearchParameter and request.params.get("SearchParameterKey"):
	<th ${HeaderClass}>${_('Search Parameter')}</th>
%endif

</tr>
</%def>
