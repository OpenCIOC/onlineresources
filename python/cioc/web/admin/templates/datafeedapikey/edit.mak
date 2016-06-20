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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_datafeedapikey_index')}">${_('Return to Index')}</a> ]</p>
<form action=${request.current_route_path()} method="post">
<div class="hidden">
${request.passvars.cached_form_vals}
%if not is_add:
${renderer.hidden("FeedAPIKey")}
%endif
</div>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="2">${renderinfo.doc_title}</th>
</tr>
%if not is_add:
<tr>
<td class="FieldLabelLeft">${_('Feed API Key')}</td>
<td><code>${key.FeedAPIKey}</code></td>
</tr>
${self.makeMgmtInfo(key)}
<tr>
	<td>
</tr>
%endif
<tr>
<td class="FieldLabelLeft">${renderer.label('Owner', _('Owner'))}</td>
<td>${renderer.errorlist('Owner')}${renderer.text('Owner', maxlength=100, size=40)}</td>
</tr>
<tr>
<td class="FieldLabelLeft">${_('Applies To')}</td>
<td>
%if (request.dboptions.UseCIC and request.user.cic.SuperUser):
	${renderer.checkbox('CIC', label=_('Community Information'))}
%elif renderer.value('CIC'):
	${_('Community Information')}
%endif
<br>
%if (request.dboptions.UseVOL and request.user.vol.SuperUser):
	${renderer.checkbox('VOL', label=_('Volunteer'))}
%elif renderer.value('VOL'):
	${_('Volunteer')}
%endif
</td>
</tr>
<tr>
<td colspan="2"><input class="btn btn-primary" type="submit" value="${_('Submit Updates')}" name="Update">
%if not is_add:
<% activate_text = _('Activate') if key.Inactive else _('Inactivate') %>
<% btn_class = 'btn-default' if key.Inactive else 'btn-danger' %>
<a class="btn ${btn_class}" href="${request.passvars.route_path('admin_datafeedapikey', action='inactive', _query={'FeedAPIKey': key.FeedAPIKey})}">${activate_text}</a>
%endif
</td>
</tr>
</table>
</form>
