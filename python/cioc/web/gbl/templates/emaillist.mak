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
from email.utils import formataddr
import json

from cioc.core import constants as const
%>

<form method="post" class="method-changeable" autocomplete="off">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
${renderer.hidden('IDList')}
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Configure Email')}</th></tr>
<tr>
	<td class="FieldLabelLeft">${_('Reply-To:')}</td>
	<td>
### Add extra hidden ReplyTo to distinguish between no value given and false
### value because empty checkbox sends no value. Needed for default to on
		<div style="display:none"><input type="hidden" name="ReplyTo" value=""></div>
		${renderer.checkbox('ReplyTo', label=formataddr((u' '.join([x for x in [request.user.FirstName, request.user.LastName] if x]) or False, request.user.Email)))}
	</td>
</tr>
<tr><td class="FieldLabelLeft">${_('From:')}</td><td>${renderer.errorlist('FromName')}${renderer.text('FromName', size=30, maxlength=100, autocomplete="off")} &lt;${agency_email}&gt;</td></tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('EmailAddress', _('To:'))}</td>
	<td>${renderer.errorlist('EmailAddress')}${renderer.email('EmailAddress', maxlength=1000)}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Subject:')}</td>
	<td>${renderer.errorlist('Subject')}${renderer.text('Subject', maxlength=255)}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('AccessURL', _('Domain / View:'))}</td>
	<td>${renderer.errorlist('AccessURL')}${renderer.select('AccessURL', options=urloptions)}</td>
</tr>
%if request.pageinfo.DbArea == const.DM_CIC:
<tr>
	<td class="FieldLabelLeft">${_('Link Type:')}</td>
	<td>${renderer.errorlist('PDF')}
	${renderer.radio('PDF', '', label=_('Web Page Link'))}
	<br>${renderer.radio('PDF', 'on', label=_('PDF Page Link (if available in selected View)'))}
	</td>
</tr>
%endif
<tr>
<td colspan="2">
${renderer.errorlist('BodyPrefix')}
${renderer.textarea('BodyPrefix')}
%if record_data:
<pre id="rendered-record-list">${record_data}</pre>
%else:
<br><em>${_('No records available for the selected View')}</em><br>
%endif
${renderer.errorlist('BodySuffix')}
${renderer.textarea('BodySuffix')}
</td>
</tr>
<tr>
<td colspan="2">
	%if out_of_view_records:
	<p class="AlertBubble">${_('Some records are not available in the selected View and are listed below.')}</p><br>
	%endif
	%if record_data:
	<input type="submit" value="${_('Send Email')}" data-method="post" class="method-changer">
	%endif
	<input type="submit" value="${_('Preview with new settings')}" data-method="get" class="method-changer">
	%if record_data:
	<br><br><em>${_("OR")}</em> <button id="select-records">${_('Click here to select the record list')}</button> ${_('and press ctrl-c or cmd-c (on Mac) to copy and use in your own email client.')}
	%endif
</td>
</tr>
</table>
</form>
%if out_of_view_records:
<p class="Alert">${_('The following records are not available in the selected View and will not be included in the email.')}</p>
<pre>
${out_of_view_records}
</pre>
%endif

<%def name="bottomjs()">
	<script type="text/javascript">
	(function() {
	 jQuery(function($) {
		$('.method-changeable').on('click', '.method-changer', function() {
			var self = $(this), form = self.parents('form'), method = self.data('method');
			form.prop('method', method);
		});
		<% user = request.user %>
		$("#FromName").autocomplete({
			source: ${json.dumps(list(sorted([y for y in [agency_name, u' '.join([x for x in (user.FirstName, user.LastName) if x])] if y])))|n}
		});
		$('#select-records').on('click', function() {
			var el = $('#rendered-record-list');
			if (!el.length) {
				return false;
			}
			el = el[0];
			var range;
			if ((window.getSelection || document.getSelection) && document.createRange) {
				range = document.createRange();
				var sel = window.getSelection();
				range.selectNodeContents(el);
				sel.removeAllRanges();
				sel.addRange(range);
			} else if (document.body && document.body.createTextRange) {
				range = document.body.createTextRange();
				range.moveToElementText(el);
				range.select();
			}
			return false;
		})
	 });
	 })();
	</script>
</%def>
