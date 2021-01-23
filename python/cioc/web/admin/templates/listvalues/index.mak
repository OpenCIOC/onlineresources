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
import six
%>
<% 
makeLink = request.passvars.makeLink 
PrintMode = request.viewdata.PrintMode
HeaderClass = '' if PrintMode else Markup('class="RevTitleBox"')
SuperUserGlobal = _context.SuperUserGlobal
%>
<h2>${renderinfo.doc_title}</h2>


%if not PrintMode:
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
%if not SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', list_type.AdminAreaCode)])}">${_('Request Change')}</a>
%endif
| <a href="${request.passvars.route_path('admin_listvalues', _query=[('list',list_type.FieldCode), ('PrintMd', 'on')])}" target="_blank">${_('Print Version (New Window)')}</a>
]</p>

%endif



<table class="BasicBorder cell-padding-3">
${make_table_header()}

<% index = -1 %>
%for index, listitem in enumerate(listitems):
<% 
	prefix = 'listitem-' + str(index) + '.' 
	id_field = list_type.ID or list_type.NameField
	if isinstance(listitem, dict):
		list_id = listitem.get(id_field)
	else:
		list_id = getattr(listitem, id_field)
%>

${make_row(prefix, listitem, list_id)}
%endfor

</table>


<%def name="make_row(prefix, listitem, itemid)">
<tr>
	<td> 
	${getattr(listitem,list_type.NameField)}
	</td>

## extra fields
%for field in list_type.ExtraFields or []:
		<td ${'align="center"' if field['type']=='checkbox' else '' |n}>
		%if field['type'] == 'checkbox':
			${'*' if getattr(listitem, field['field']) else ''}
		%elif field['type'] == 'language':
			${culture_map[getattr(listitem, field['field'])].LanguageName}
		%else:
			${getattr(listitem, field['field'])}
		%endif
		</td>
%endfor

%if PrintMode and list_type.HasModified:
	<td>${format_date(listitem.MODIFIED_DATE) or _('Unknown')} (${listitem.MODIFIED_BY or _('Unknown')})</td>
%endif #Print Mode

%if list_type.Usage:
	<% 
		usage = list_type.Usage.get(six.text_type(getattr(listitem, list_type.ID or list_type.NameField)))
		usage1 = getattr(usage, 'Usage1', None)
		usage2 = getattr(usage, 'Usage2', None)
	%>
	<td>
	%if usage1:
	${'' if not list_type.SearchLinkTitle1 else _(list_type.SearchLinkTitle1)} 
		${usage1}
	
	%endif
	%if usage1 and usage2:
	<br>
	%endif
	%if usage2:
	${'' if not list_type.SearchLinkTitle2 else _(list_type.SearchLinkTitle2)} 
		${usage2}
	
	%endif
	</td>
%endif

</tr>
</%def>
<%def name="make_table_header()">
<tr>

	<th ${HeaderClass}>${_('Name')}</th>
	
## extra fields
%for field in list_type.ExtraFields or []:
		<th ${HeaderClass}>${_(field['title'])}</th>
%endfor



%if PrintMode and list_type.HasModified:
	<th>${_('Last Modified')}</th>
%endif
%if list_type.Usage:
	<th ${HeaderClass}>${_('Usage')}</th>
%endif

</tr>
</%def>
