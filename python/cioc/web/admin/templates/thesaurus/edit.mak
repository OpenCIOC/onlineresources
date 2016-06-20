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
from markupsafe import Markup, escape
from cioc.core import constants as const
%>

<%def name="makeSubjLink(subj, show_with=False)" filter="Markup" buffered="True"><a href="${request.passvars.route_path('admin_thesaurus', action='edit', _query=[('SubjID',subj.Subj_ID)])}" ${'class="Alert"' if subj.Inactive else '' |n}>${subj.SubjectTerm}</a>${'' if not (show_with and subj.UsedWith) else ' ' + Markup(_('(with <em>%s</em>)')) % subj.UsedWith}</%def>
<%
SuperUserGlobal = request.user.cic.SuperUserGlobal
%>
<p style="font-weight:bold">[
	<a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
	| <a href="${request.passvars.makeLink('~/admin/thesaurus.asp')}">${_('Return to Manage Thesaurus')}</a>
	%if not SuperUserGlobal:
	| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', 'THESAURUS'), ('DM', const.DM_CIC)])}">${_('Request Change')}</a>
	%endif
	| <a href="${request.passvars.makeLink('~/admin/thesaurus_results.asp', dict(PrevResults='True'))}">${_('Return to Previous Search Results')}</a>
]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

<form method="post" action="${request.route_path('admin_thesaurus', action='edit')}" id="EntryForm">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="SubjID" value="${SubjID}">
<input type="hidden" name="MemberID" value="${subject.MemberID}">
%endif
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Edit Subject Term') if not is_add else _('Add Subject Term')}</th></tr>
<%
can_update = is_add or usage.MemberID==request.dboptions.MemberID or (SuperUserGlobal and usage.MemberID is None)
can_inactivate = is_add or (usage.UsageCountLocal==0 and (usage.MemberID is None or usage.MemberID==request.dboptions.MemberID))
can_delete = not is_add and can_update
%>
%if not is_add and context.get('usage') is not None:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Status')}</td>
	<td>
	%if usage.UsageCountLocal or usage.UsageCountShared or usage.UsageCountOther:
		<% can_delete = False %>
		${_('This Subject Term is being used by <strong>%d</strong> local record(s) and <strong>%d</strong> record(s) shared with you by other members.') % (usage.UsageCountLocal, usage.UsageCountShared) |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(incDel='on', SubjID=SubjID))}">${_('Search')}</a> ]
		%if SuperUserGlobal:
		<br>${_('This Subject Term is being used by <strong>%d</strong> record(s) in total in this database.') % (usage.UsageCountLocal + usage.UsageCountOther) |n}		
		%endif
	%else:
		${_('This Subject Term <strong>is not</strong> being used by any records.')|n}
	%endif
	%if used_for:
		<% can_delete = False %>
		<br>${_('This Subject Term <stong>is being used for</strong> other Subjects (see below).')|n}
	%else:
		<br>${_('This Subject Term <strong>is not</strong> being <strong>used for</strong> any other Subjects.')|n}
	%endif
	%if usage.MemberID is not None and usage.MemberID<>request.dboptions.MemberID:
		<br>${_('This Subject Term is <strong>controlled exclusively</strong> by another CIOC Member in your database.')|n}
	%elif can_delete:
		<br>${_('Because this Subject is not being used, you can make it inactive, or delete it using the button at the bottom of the form.')}
	%elif can_inactivate:
		<br>${_('Because this Subject is being used, you cannot currently delete it.')}
	%else:
		<br>${_('Because this Subject is being used by local records, you cannot currently inactivate or delete it.')}
	%endif
	</td>
</tr>
%if not is_add and usage.ManagedBy:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Owned/Managed by')}</td>
	<td>
	<span class="${'Info' if usage.MemberID==request.dboptions.MemberID else 'Alert'}">${usage.ManagedBy}</span>
	%if SuperUserGlobal:
	<br><label><input type="checkbox" id="MakeShared" name="MakeShared" value="on"> ${_('Make this Subject Term shared (available to all CIOC Members in this database)')}</label>
	%endif
	</td>
</tr>
%endif
${self.makeMgmtInfo(usage)}
%endif

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="FieldLabelLeft">${renderer.label("descriptions." +lang.FormCulture + ".Name", _('Subject Term') + " (" + lang.LanguageName + ")")}</td>
	<td>
	%if can_update:
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=200)}
	%else:
	${renderer.value("descriptions." +lang.FormCulture + ".Name")}
	%endif
	</td>
</tr>
%endfor
%if not (is_add and not SuperUserGlobal):
<tr>
	<td class="FieldLabelLeft">${_('Authorized')}</td>
	<td>
	%if can_update and SuperUserGlobal and (is_add or subject.MemberID is None):
	${renderer.errorlist("subject.Authorized")}
	${renderer.radio("subject.Authorized", 'T', False, _('Yes'), id = "Authorized_Yes")}
	${renderer.radio("subject.Authorized", 'F', True, _('No'), id = "Authorized_No")}
	%else:
	${_('Yes') if subject.Authorized else _('No')}
	%endif
	</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft">${_('Usage')}</td>
	<td>
	%if can_update:
	${renderer.errorlist("subject.Used")}
	${renderer.radio("subject.Used", 'U', True, _('Used Term'), id = "Used_Used")}
	<br>${renderer.radio("subject.Used", 'N', False, _('Use'), id = "Used_Instead")} ${renderer.select("subject.UseAll", [('ALL', _('all')), ('ANY', _('any'))])} ${_('of the following term(s) instead:')}
	${subject_selector('UseSubj', usesubjects)}
	%else:
	${_('Used Term') if subject.Used else _('Use ') + (_('all') if subject.UseAll else _('any')) + _(' of the following term(s) instead:')}
	${subject_list(usesubjects)}
	%endif
	</td>
</tr>
%if used_for:
<tr>
	<td class="FieldLabelLeft">${_('Used For')}</td>
	<td>${Markup(', '.join(makeSubjLink(x, True) for x in used_for))}</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft">${_('Broader Term(s)')}</td>
	<td>
	%if can_update:
	${subject_selector('BroaderSubj', broadersubjects)}
	%else:
	${subject_list(broadersubjects)}
	%endif
	</td>
</tr>
%if narrower:
<tr>
	<td class="FieldLabelLeft">${_('Narrower Terms')}</td>
	<td>${Markup(', '.join(makeSubjLink(x) for x in narrower))}</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft">${_('Related Term(s)')}</td>
	<td> 
	%if can_update:
	${subject_selector('RelatedSubj', relatedsubjects)}
	%else:
	${subject_list(relatedsubjects)}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('subject.SubjCat_ID', _('Category'))}</td>
	<td>
	%if can_update:
	${renderer.errorlist('subject.SubjCat_ID')}
	${renderer.select('subject.SubjCat_ID', categories)}
	%else:
	${'' if not subject.SubjCat_ID else [x[1] for x in categories if x[0]==subject.SubjCat_ID][0]}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('subject.SRC_ID', _('Source'))}</td>
	<td>
	%if can_update:
	${renderer.errorlist('subject.SRC_ID')}
	${renderer.select('subject.SRC_ID', sources)}
	%else:
	${'' if not subject.SRC_ID else [x[1] for x in sources if x[0]==subject.SRC_ID][0]}
	%endif
	</td>
</tr>
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="FieldLabelLeft">${renderer.label("descriptions." +lang.FormCulture + ".Notes", _('Notes') + " (" + lang.LanguageName + ")")}</td>
	<td>
	%if can_update:
	<span class="SmallNote">${_('Maximum 8000 characters')}</span>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Notes")}
	<br>${renderer.textarea("descriptions." +lang.FormCulture + ".Notes")}
	%else:
	${renderer.value("descriptions." +lang.FormCulture + ".Notes")}
	%endif
	</td>
</tr>
%endfor
%if can_inactivate or can_update or (SuperUserGlobal and usage.MemberID<>request.dboptions.MemberID):
	%if is_add or usage.MemberID is None or usage.MemberID==request.dboptions.MemberID:
<tr>
	<td class="FieldLabelLeft">${_('Activation')}</td>
	%if can_inactivate or subject.Inactive:
	<td>
	${renderer.errorlist("subject.Inactive")}
	%if not is_add:
	<span class="${'Alert' if not can_inactivate else 'Info'}">${_('Current Status: ') + (_('Inactive') if subject.Inactive else _('Active'))}</span>
	<br>
	%endif
	${renderer.checkbox("subject.Inactive", label=_('Make Term Inactive'))}
	<br>${_('Inactive terms will not be available to you when adding <em>new</em> Terms to records or listing Terms such as in "Browse by Subject".')|n}
	<br><span class="Alert">${_('It is still possible for a Term you deactivate to be added to your record, such as through record import or because another CIOC Member has management privileges for your records and uses this Term.')}</span>
	</td>
	%else:
	<td>${_('Active')}</td>
	%endif
</tr>
	%endif
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}">
	%if can_delete:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
%endif
</table>

<%def name="subject_selector(field, subjs)">
	${renderer.errorlist(field + "_ID")}
	<div id="${field}_existing_add_container">
	%for desc in (x for x in other_term_descs if unicode(x.Subj_ID) in subjs):
		${renderer.ms_checkbox(field + "_ID", desc.Subj_ID, label=makeSubjLink(desc))}
	%endfor
	</div>
	<table id="${field}_new_input_table" class="NoBorder cell-padding-2">
	<tr>
	<td class="FieldLabelClr">${_('Name')}</td>
	<td><input type="text" id="NEW_${field}" size="${const.TEXT_SIZE}" maxlength="200"></td>
	<td><button type="button" class="" id="add_${field}">${_('Add')}</button></td>
	</table>
	</tr>
</%def>
	
<%def name="subject_list(subjs)">
	${escape(', ').join(makeSubjLink(x) for x in other_term_descs if unicode(x.Subj_ID) in subjs)}
</%def>
</form>
</div>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<% renderinfo.list_script_loaded = True %>
<%def name="bottomjs()">
	${request.assetmgr.JSVerScriptTag('scripts/admin.js')}
	<script type="text/javascript">
	jQuery(function() {
		init_subject_checklist("${request.passvars.makeLink('~/jsonfeeds/subject_generator.asp', dict(SkipSubj=SubjID, ShowAll='on')) |n}", "${request.passvars.route_path('admin_thesaurus', action='edit', _query=[('SubjID', 'IDIDID')])|n}",
			"${_('Not Found')}");
	});
	</script>
</%def>
