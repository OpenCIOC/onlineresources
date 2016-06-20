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
%>

<% 
makeLink = request.passvars.makeLink 
PrintMode = request.viewdata.PrintMode
HeaderClass = '' if PrintMode else Markup('class="RevTitleBox"')
SuperUserGlobal = request.user.vol.SuperUserGlobal
%>

<h1>${_('Specific Areas of Interest') if PrintMode else _('Edit Values for checklist: Specific Areas of Interest')}</h1>
%if not PrintMode:
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
%if not SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', 'INTEREST')])}">${_('Request Change')}</a>
%endif
| <a href="${request.passvars.route_path('admin_interests_index', _query=[('PrintMd', 'on')])}" target="_blank">${_('Print Version (New Window)')}</a> ]</p>

${sc.shown_cultures_ui()}
%endif

%if not PrintMode and request.dboptions.OtherMembersActive:
<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
</div>
%endif
<table class="BasicBorder cell-padding-3">
<tr>
<th ${HeaderClass}>${_('Code')}</th>
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<th ${'' if PrintMode else sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_('Display')} (${lang.LanguageName})</th>
%endfor

	<th ${HeaderClass}>${_('Belongs to General Areas')}</th>
	%if PrintMode:
		<th>${_('Last Modified')}</th>
	%endif
	%if not PrintMode and request.dboptions.OtherMembersActive:
		<th ${HeaderClass}>${_('Hide')}</th>
	%endif
	%if request.dboptions.OtherMembersActive:
	<th ${HeaderClass}>${_('Usage Local')}</th>
	<th ${HeaderClass}>${_('Usage Other')}</th>
	%else:
	<th ${HeaderClass}>${_('Usage')}</th>
	%endif
	%if not PrintMode and SuperUserGlobal:
		<th ${HeaderClass}>${_('Action')}</th>
	%endif
<tr>

%for interest in interests:
<%
current_culture = request.language.Culture
display_cultures = sorted(filter(lambda x: not not x[1], ((culture != current_culture,interest.Descriptions.get(culture_map[culture].FormCulture, dict()).get('Name', '')) for culture in record_cultures)))
%>
%if display_cultures:
	<% row_title = display_cultures[0][1] %>
%elif interest.Code:
	<% row_title = interest.Code %>
%else:
	<% row_title = _('Unknown') %>
%endif
<tr>
	<td>${interest.Code}</td>
	%for culture in record_cultures:
	<% 
		lang = culture_map[culture]
	%>
	<td ${'' if PrintMode else sc.shown_cultures_attrs(culture)}>
	${interest.Descriptions.get(lang.FormCulture, dict()).get('Name', '')}
	</td>
	%endfor
	<td>${interest.Groups or ''}</td>
	%if PrintMode:
	<td>${format_date(interest.MODIFIED_DATE) or _('Unknown')} (${interest.MODIFIED_BY or _('Unknown')})</td>
	%endif
	%if not PrintMode and request.dboptions.OtherMembersActive:
	<td style="text-align:center">
		%if not interest.UsageLocal:
			${renderer.ms_checkbox('ChkHide', interest.AI_ID, title=row_title + _(': Hide'))}
		%endif
	</td>
	%endif
	<td align="center">
	%if PrintMode:
		${interest.UsageLocal}
	%elif interest.UsageLocal:
		<% url = makeLink('~/volunteer/results.asp', dict(incDel="on", DisplayStatus="A", AIID=interest.AI_ID)) %>
		<a href="${url}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17" height="14" border="0" title="${_('Usage: %d') % interest.UsageLocal}"></a>
	%endif
	
	</td>
	%if request.dboptions.OtherMembersActive:
	<td align="center">
	%if PrintMode:
		${interest.Usage}
	%elif interest.Usage:
		<% url = makeLink('~/volunteer/results.asp', dict(incDel="on", DisplayStatus="A", AIID=interest.AI_ID)) %>
		<a href="${url}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17", height="14", border="0", title="${_('Usage: %d') % interest.Usage}"></a>
	%endif
	
	</td>
	%endif
	%if not PrintMode and SuperUserGlobal:
	<td>
		[ <a href="${request.passvars.route_path('admin_interests', action='edit', _query=[('AI_ID', str(interest.AI_ID))])}">${_('Update')}</a>
		%if not interest.Usage:
		| <a href="${request.passvars.route_path('admin_interests', action='delete', _query=[('AI_ID', str(interest.AI_ID))])}">${_('Delete')}</a> 
		%endif
		]
	</td>
	%endif
</tr>
%endfor

<% colspan = len(record_cultures) + 4 + bool(request.dboptions.OtherMembersActive) %>
%if not PrintMode and request.dboptions.OtherMembersActive:
	<td colspan="${colspan}">
	<input type="submit" name="Submit" value="${_('Update "Hide" State')}"> 
	<input type="reset" value="${_('Reset Form')}">
	</td>
%endif
</table>
%if not PrintMode and request.dboptions.OtherMembersActive:
</form>
%endif
%if not PrintMode and SuperUserGlobal:
	<td colspan="${colspan}">
<form action="${request.route_path('admin_interests', action='edit')}" method="get">
<div style="display:none;">
${request.passvars.cached_form_vals|n}
</div>
<p>
<input type="submit" value="${_('Add')}">
</p>
</form>
%endif

<%def name="bottomjs()">
%if not request.viewdata.PrintMode:
${sc.shown_cultures_js()}
%endif
</script>
</%def>
