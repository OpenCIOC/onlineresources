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

<%!
from cioc.core import constants as const
%>
<%def name="display_options(for_view=False, prefix='dopts.')">
<%
viewdata = request.viewdata
%>
%if not for_view:
<form method="post" action="display_options2.asp" name="EntryForm">
<div style="display:none;">
${request.passvars.cached_form_vals |n}
</div>
%endif

<table class="BasicBorder cell-padding-3" ${'' if for_view else 'align="center"' |n}>
<tr>
	<th class="RevTitleBox">${_('Change Results Display')}</th>
</tr>
%if domain.id == const.DM_CIC:
<tr>
	<th>${_('Show Fields')}</th>
</tr>
<tr>
<td>
	<table class="NoBorder cell-padding-2" width="100%">
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowID', label=_('Record #'))}</td>
		<td>${renderer.checkbox(prefix + 'ShowOwner', label=_('Record Owner'))}</td>
		<td>${renderer.checkbox(prefix + 'ShowOrg', label=_('Org. Name(s)'))}</td>
	</tr>
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowCommunity', label=_('Located In'))}</td>
		<td>${renderer.checkbox(prefix + 'ShowUpdateSchedule', label=_('Update Schedule'))}</td>
		%if not for_view and viewdata.cic.AlertColumn:
		<td>${renderer.checkbox(prefix + 'ShowAlert', label=_('Alert Box'))}</td>
		%else:
		<td></td>
		%endif
	</tr>
	</table>	
</td>
</tr>
%else: #VOL
<tr>
	<th>${_('Show Options')}</th>
</tr>
<td>
	## My List?
	<table class="NoBorder cell-padding-2" width="100%">
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowTable', label=_('Use Table Format'))}</td>
		<td>${renderer.checkbox(prefix + 'LinkWeb', label=_('Web-enable Custom Fields'))}</td>
	</tr>
	%if not for_view:
	<tr>
		<td>${renderer.checkbox(prefix + 'LinkUpdate', label=_('Update Record'))}</td>
		<td>${renderer.checkbox(prefix + 'LinkSelect', label=_('Select Checkbox'))}</td>
	</tr>
		%if request.user.vol.CanRequestUpdate:
	<tr>
		<td colspan="2">${renderer.checkbox(prefix + 'LinkEmail', label=_('Email Update Request'))}</td>
	</tr>
		%endif
	%endif
	</table>
</td>
</tr>
<tr>
	<th>${_('Show Fields (Table Format Only)')}</th>
</tr>
<tr>
<td>
	<table class="NoBorder cell-padding-2" width="100%">
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowID', label=_('Op. ID'))}</td>
		<td>${renderer.checkbox(prefix + 'VShowPosition', label=_('Position Title'))}</td>
		<td>${renderer.checkbox(prefix + 'ShowOrg', label=_('Org. Name(s)'))}</td>
	</tr>
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowOwner', label=_('Record Owner'))}</td>
		<td>${renderer.checkbox(prefix + 'ShowCommunity', label=_('Communities'))}</td>
		<td>${renderer.checkbox(prefix + 'VShowDuties', label=_('Duties'))}</td>
	</tr>
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowUpdateSchedule', label=_('Update Schedule'))}</td>
		<% need_extra_td = True %>

		%if not for_view and viewdata.vol.AlertColumn:
		<% need_extra_td = False %>
		<td>${renderer.checkbox(prefix + 'ShowAlert', label=_('Alert Box'))}</td>
		%endif

		<td>${renderer.checkbox(prefix + 'LinkListAdd', label=_('List/Client Tracker'))}</td>

		%if need_extra_td:
		<td></td>
		%endif
	</tr>
	</table>	
</td>
</tr>
%endif
<tr>
	<td>
	<table class="NoBorder cell-padding-2" width="100%">
	<tr valign="top">
		<td>
			${_('Custom Fields:')}
			<br><span class="SmallNote">(${_('Hold CTRL to select/deselect multiple items')})</span>
			<br><input type="button" value="${_('Clear Selections')}" onClick="$('#DisplayOptions_FieldIDs option').attr('selected', false); return false;">
		</td>
		<td>
			${renderer.errorlist(prefix + 'FieldIDs')}
			${renderer.select(prefix + 'FieldIDs', multiple=True, id='DisplayOptions_FieldIDs', options=disp_opt_field_descs, size=5)}
		</td>
	</tr>
	</table>
	</td>
</tr>
%if domain.id == const.DM_CIC:
<tr>
	<th>${_('Show Options')}</th>
</tr>
<tr>
	<td><table border="0" width="100%">
	<% user_cic = request.user.cic %>
	%if not for_view:
	<tr>
		<td>${renderer.checkbox(prefix + 'LinkUpdate', label=_('Update Record'))}</td>
		<td>${renderer.checkbox(prefix + 'LinkSelect', label=_('Select Checkbox'))}</td>
	</tr>
	%if user_cic.CanRequestUpdate:
	<tr>
		<td>${renderer.checkbox(prefix + 'GLinkMail', label=_('Mail Form'))}</td>
		<td>${renderer.checkbox(prefix + 'LinkEmail', label=_('Email Update Request'))}</td>
	</tr>
	%endif
	%endif
	<% has_pub = False %>
	<tr>
		<td>${renderer.checkbox(prefix + 'ShowTable', label=_('Use Table Format'))}</td>
	%if not for_view and user_cic.CanUpdatePubs != const.UPDATE_NONE and not user_cic.LimitedView:
	<% has_pub = True %>
		<td>${renderer.checkbox(prefix + 'GLinkPub', label=_('Update Publications'))}</td>
	</tr>
	<tr>
	%endif
		<td>${renderer.checkbox(prefix + 'LinkWeb', label=_('Web-enable Custom Fields'))}</td>
	%if not has_pub:
	</tr>
	<tr>
	%endif
		<td ${'colspan="2"' if not has_pub else '' |n}>${renderer.checkbox(prefix + 'LinkListAdd', label=_('List/Client Tracker'))}</td>
	</tr>
	</table></td>
</tr>
%endif
<tr>
	<th>${_('Order Results By')}</th>
</tr>
<tr>
	<td align="center">
	${renderer.errorlist(prefix + 'OrderBy')}
	%if domain.id == const.DM_VOL:

	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_REQUEST, label=_('Request Date'))}</span>
	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_POS, label=_('Position Title'))}</span>

	%endif

	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_NAME, True, label=_('Org. Name(s)'))}</span>

	%if domain.id == const.DM_CIC:
	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_NUM, label=_('Record #'))}</span>
	%endif

	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_UPDATE, label=_('Update Schedule'))}</span>

	%if domain.id == const.DM_CIC:
	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_LOCATION, label=_('Located In'))}</span>
	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_RELEVANCY, label=_('Relevancy'))}</span>
	%endif

	<span style="white-space:nowrap">${renderer.radio(prefix + 'OrderBy', const.OB_CUSTOM, label=_('Custom (Specify)'))} ${renderer.select(prefix + 'OrderByCustom', [('','')] + disp_opt_field_descs)}</span>

	<br>${_('Sort:')}
	${renderer.radio(prefix + 'OrderByDesc', 'False', True, label=_('Ascending'))}
	${renderer.radio(prefix + 'OrderByDesc', 'True', label=_('Descending'))}

	</td>
</tr>

%if not for_view:
<tr>
	<td align="center" class="RevTitleBox"><input type="submit" value="${_('Update Display')}"></td>
</tr>
%endif

</table>
%if not for_view:
</form>
%endif
</%def>
