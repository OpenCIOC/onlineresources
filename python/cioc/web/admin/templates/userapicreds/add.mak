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
<%! from operator import itemgetter %>
<p style="font-weight:bold">[
	%if cred_user.User_ID != request.user.User_ID:
	<a href="${request.passvars.makeLinkAdmin('user_edit.asp', [('UserID', cred_user.User_ID)])}">${_('Return to User "%s"') % cred_user.UserName}</a>
	%else:
	<a href="${request.passvars.makeLinkAdmin('account.asp')}">${_('Return to Account')}</a>
	%endif
]</p>

<form method="post" id="add-form" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="User_ID" value="${cred_user.User_ID}">
</div>

<table class="BasicBorder cell-padding-4 form-table responsive-table clear-line-below max-width-lg">
<tr>
	<th class="RevTitleBox" colspan="2">${_('Add User API Credential')}</th>
</tr>
<tr>
	${self.fieldLabelCell('UsageNote', _('Usage Note'), _('Where is this API credential to be used?'))}</td>
	<td class="field-data-cell">
	${renderer.errorlist("UsageNote")}
	${renderer.text("UsageNote", maxlength=150, class_="form-control")}
	</td>
</tr>
</table>

<input type="submit" name="Submit" value="${_('Add')}" class="btn btn-default">
<input type="reset" value="${_('Reset Form')}" class="btn btn-default">

</form>
<%def name="bottomjs()">
	<div class="modal fade" id="results-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
	  <div class="modal-dialog" role="document">
		<div class="modal-content">
		  <div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-label="${_('Close')}"><span aria-hidden="true">&times;</span></button>
			<h4 class="modal-title" id="myModalLabel">${_('User API Credentials')}</h4>
		  </div>
		  <div class="modal-body">
			<div id="display-loading">
			<div class="progress">
				<div class="progress-bar progress-bar-striped active" style="width: 100%">
					<span class="sr-only">${_('Loading...')}</span>
				</div>
			</div>
			</div>
			<div id="display-results-error" style="display: none;">
				<div class="alert alert-danger" role="alert"><strong>${_('Error:')}</strong> <span id="error-message-target"></span></div>
			</div>
			<div id="display-results-success" style="display: none;">
				<div class="alert alert-success" role="alert"><strong>${_('Success:')}</strong> ${_('The credentials were created.')}</div>
				<div class="alert alert-info" role="alert"><strong>${_('NOTE:')}</strong> ${_('This is the only time you will be able to see the password. Make a note of it now.')}</div>
				<table class="table">
					<tr><th>${_('Cred ID')}</th><td id="cred-id"></td></tr>
					<tr><th>${_('Cred Password')}</th><td id="cred-password"></td></tr>
				</table>
			</div>
		  </div>
		  <div class="modal-footer">
			<button type="button" class="btn btn-default" data-dismiss="modal">${_('Close')}</button>
		  </div>
		</div>
	  </div>
	</div>

	<script type="text/javascript">
	$(document).ready(function(){
		var result = null;
		$('[data-toggle="popover"]').popover();
		$('#results-modal').modal({'show': false}).on('hide.bs.modal', function() {
			if (result && result.success) {
				window.location.href = '${request.passvars.route_path("admin_userapicreds_index", _query=[("User_ID", cred_user.User_ID)])}';
			}
		});

		$('#add-form').submit(function(evt) {
			evt.preventDefault();
			$('#results-modal').modal('show');

			var loading = $('#display-loading').show();
			$('#display-results-success,#display-results-error').hide()

			var self = $(this);
			$.ajax({
				'type': 'POST',
				'url': this.action,
				'data': self.serialize(),
				'dataType': 'json'
			}).done(function(data) {
				result = data;
				if(data.success) {
					$('#cred-id').text(data.cred_id);
					$('#cred-password').text(data.cred_password);
					$('#display-results-success').show();
				} else {
					$('#error-message-target').text(data.errormessage);
					$('#display-results-error').show();
				}
				loading.hide();
			}).fail(function(jqXHR, textStatus, errorThrown) {
				$('#error-message-target').text("${_('Server Error: ')}" + textStatus);
				$('#display-results-error').show();
				loading.hide();
			});
		});
	});
	</script>
</%def>
