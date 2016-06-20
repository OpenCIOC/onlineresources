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
	from datetime import datetime
	from markupsafe import Markup
%>


<%inherit file="cioc.web:templates/master.mak" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a> ]</p>

<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
<input type="hidden" name="ProfileID" value="${ProfileID}">
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Review Sharing Profile')}</th></tr>
${self.makeMgmtInfo(profile)}
<tr>
	<td class="FieldLabelLeft">${_('Status')}</td>
	<td>
	%if not profile.AcceptedDate:
		${_('The partner member has <strong>not</strong> accepted the sharing agreement')|n}
	%else:
		${_('The partner member accepted the sharing agreement on %s.') % format_date(profile.AcceptedDate)}
	%endif
	%if profile.RevokedDate:
	<br>
		%if profile.RevokedDate > datetime.now():
			${_('The sharing agreement will end on %s.') % format_date(profile.RevokedDate) |n}
		%else:
			${_('The sharing agreement ended on %s.') % format_date(profile.RevokedDate) |n}
		%endif
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Records')}</td>
	<td><a href="${request.passvars.route_path('admin_sharingprofile', action='records', _query=[('DM', domain.id), ('ProfileID', _context.ProfileID)])}">${_('View records associated with this profile (%d)') % profile.RecordCount}</a></td>
</tr>
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="FieldLabelLeft">${renderer.label("descriptions." +lang.FormCulture + ".Name", _('Name') + " (" + lang.LanguageName + ")")}</td>
	<td>${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=50)}</td>
</tr>
%endfor
<tr>
	<td class="FieldLabelLeft">${_('Partner Member')}</td>
	<td>${profile.ReceivingMemberName}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Update Records')}</td>
	<td>
	%if profile.CanUpdateRecords:
		%if not edit_languages:
			${_('The partner member <strong>may</strong> update records.')|n}
		%else:
			${Markup(_('The partner member <strong>may</strong> update records in %s.')) % ' or '.join(culture_map[c[0]].LanguageName for c in edit_languages)}
		%endif
	%else:
		${_('The partner member <strong>may not</strong> update records.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Use Print Tools')}</td>
	<td>
	%if profile.CanUsePrint:
		${_('The partner member <strong>may</strong> use records in print tools.')|n}
	%else:
		${_('The partner member <strong>may not</strong> use records in print tools.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Export Records')}</td>
	<td>
	%if profile.CanUseExport:
    ${_('The partner member <strong>may</strong> export records.')|n}
	%else:
    ${_('The partner member <strong>may not</strong> export records.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Update Publications')}</td>
	<td>
	%if profile.CanUpdatePubs:
    ${_('The partner member <strong>may</strong> add/remove/update publication data.')|n}
	%else:
    ${_('The partner member <strong>may not</strong> add/remove/update publication data.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can View Feedback')}</td>
	<td>
	%if profile.CanViewFeedback:
    ${_('The partner member <strong>may</strong> view feedback for the record.')|n}
	%else:
    ${_('The partner member <strong>may not</strong> view feedback for the record.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can View Private Records')}</td>
	<td>
	%if profile.CanViewPrivate:
    ${_('Private data <strong>is</strong> accessible, if a privacy profile is assigned to the record.')|n}
	%else:
    ${_('Private data <strong>is not</strong> accessible, if a privacy profile is assigned to the record.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Revocation Period')}</td>
	<td>
    ${_('The revocation period is %d day(s).') % profile.RevocationPeriod}
	<div class="hidden">
	<input type="hidden" name="profile.RevocationPeriod" value="0">
	</div>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Views')}</td>
	<td>
	%if profile.CanUseAnyView:
	${_("The partner member can use records in <strong>any</strong> of their views.")|n}
	%else:
	${renderer.radio('profile.CanUseAnyView', 'Y', True, label=_("Records can be used in any of the partner member's views."), id='profile_CanUseAnyView_Y')}
	<br>${renderer.radio('profile.CanUseAnyView', 'N', False, label=_("Records can be used in the following partner member's views:"), id='profile_CanUseAnyView_N')}

	<br>

	<% 
		my_view_descs = [v for v in view_descs if v.MemberID==profile.ShareMemberID] 
		locked_views = [v for v in my_view_descs if str(v.ViewType) in views]
		unused_views = [v for v in my_view_descs if str(v.ViewType) not in views]
	%>

	%if locked_views:
	<ul>
	%for view in locked_views:
	<li>${_('%d - %s') % (view.ViewType, view.ViewName)}</li>
	%endfor
	</ul>
	%endif

	%for view in unused_views:
	<br>${renderer.ms_checkbox('profile.Views', str(view.ViewType), label=_('%d - %s') % (view.ViewType, view.ViewName), id='view_' + str(view.ViewType))}
	%endfor

	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Fields')}</td>
	<td>
	%if always_shared_fields:
	<h4>${_('The Following Fields are shared automatically, or are Member-specific:')}</h4>
	<ul>
	%for field in always_shared_fields:
		<li${' style=font-style:italic' if field.Generated else ''}>${field.FieldDisplay}</li>
	%endfor
	</ul>
	%endif
	<h4>${_('Available for the following fields:')}</h4>
	<% 
		locked_fields = [f for f in field_descs if str(f.FieldID) in fields]
		unused_fields = [f for f in field_descs if str(f.FieldID) not in fields]
	%>
		%if locked_fields:
		<ul>
		%for field in locked_fields:
		<li>${field.FieldDisplay}</li>
		%endfor
		</ul>
		%endif

		%if unused_fields:
		<br>

		<input type="button" value="${_('Check All')}" id="field-check-all"> <input type="button" value="${_('UnCheck All')}" id="field-uncheck-all"> <br>
		%for field in unused_fields:
		<br>${renderer.ms_checkbox('profile.Fields', str(field.FieldID), label=field.FieldDisplay, id='field_' + str(field.FieldID))}
		%endfor
		%endif
		
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Email Notifications')}</td>
	<td>${renderer.errorlist("profile.NotifyEmailAddresses")}
	${renderer.text("profile.NotifyEmailAddresses", maxlength=1000)}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Update')}"> 
	%if not profile.AcceptedDate:
	<input type="submit" name="Delete" value="${_('Delete')}" href="${request.passvars.route_path('admin_sharingprofile', action='delete', _query=[('DM', domain.id), ('ProfileID', ProfileID)])}" class="nav-on-click"> 
	%endif
	%if profile.Active and not profile.RevokedDate:
	<input type="submit" name="Revoke" value="${_('Revoke Sharing Profile')}" class="nav-on-click" href="${request.passvars.route_path('admin_sharingprofile', action='revoke', _query=[('ProfileID', ProfileID),('DM', domain.id)])}">
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
	</td>
</tr>
</table>
</form>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	var initialized = false;
	$('.nav-on-click').click(function() {
		window.location.href = $(this).attr('href');
		return false;
	});
	$('#field-check-all').click(function() {
		$(this).parents('td').first().find('input[type=checkbox]').prop('checked', true);
		return false;
	})
	$('#field-uncheck-all').click(function() {
		$(this).parent('td').first().find('input[type=checkbox]').prop('checked', false);
		return false;
	})
})
</script>
</%def>
