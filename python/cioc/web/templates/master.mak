<%namespace file="cioc.core:templates/header.mak" name="header" />
<%namespace file="cioc.core:templates/footer.mak" name="footer" />
%if not request.params.get('InlineMode'):
<%call expr="header.header()">
	<%def name="headerextra()">
	%if hasattr(self, 'headerextra'):
		${self.headerextra()}
	%endif
	</%def>
</%call>
%endif
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
from markupsafe import Markup
%>

${self.body()}

%if not request.params.get('InlineMode'):
<%call expr="footer.footer()">
	<%def name="bottomjs()">
	%if hasattr(self, 'bottomjs'):
		${self.bottomjs()}
	%endif
	</%def>
</%call>
%else:
	%if hasattr(self, 'inlinebottomjs'):
		${self.inlinebottomjs()}
	%endif
%endif

<%def name="requiredFieldMarker()">
<span class="Alert glyphicon glyphicon-star" title="${_('Required')}"></span>
</%def>

<%def name="helpBubble(label_text,help_text)">
	%if help_text:
<a data-toggle="popover" data-trigger="focus" title="${_('Help: ') + (label_text or '')}" data-placement="top" data-content="${help_text}" tabindex="0">
	<span class="glyphicon glyphicon-question-sign SimulateLink"></span>
</a>
	%endif
</%def>

<%def name="fieldLabelCell(field_id,label_text,help_text,is_required=False)">
<td class="field-label-cell">
	${renderer.label(field_id, label_text)}
	%if is_required:
	${requiredFieldMarker()}
	%endif
	${helpBubble(label_text,help_text)}
</td>
</%def>

<%def name="makeMgmtInfo(model, show_created=True, show_modified=True)">

<%
if show_created:
	created_date = getattr(model, 'CREATED_DATE', None)
	created_by = getattr(model, 'CREATED_BY', None)
if show_modified:
	modified_date = getattr(model, 'MODIFIED_DATE', None)
	modified_by = getattr(model, 'MODIFIED_BY', None)
%>
<tr>
	<td class="field-label-cell">
		${_('Admin History')}
		${helpBubble(_('Admin History'),_('set automatically'))}
	</td>
	<td class="field-data-cell">
		<div class="row">
			%if show_created:
			<div class="col-md-3 padding-sm-top">
				<strong>${_('Date Created')}${_(': ')}</strong>
				<br class="hidden-xs hidden-sm">${format_date(created_date) if created_date else _('Unknown')}
			</div>
			<div class="col-md-3 padding-sm-top">
				<strong>${_('Created by')}${_(': ')}</strong>
				<br class="hidden-xs hidden-sm">${created_by if created_by else _('Unknown')}
			</div>
			%endif
			%if show_modified:
			<div class="col-md-3 padding-sm-top">
				<strong class="no-wrap">${_('Last Modified')}${_(': ')}</strong>
				<br class="hidden-xs hidden-sm">${format_date(modified_date) if modified_date else _('Unknown')}
			</div>
			<div class="col-md-3 padding-sm-top">
				<strong class="no-wrap">${_('Last Modified by')}${_(': ')}</strong>
				<br class="hidden-xs hidden-sm">${modified_by if modified_by else _('Unknown')}
			</div>
			%endif
		</div>
	</td>
</tr>
</%def>
