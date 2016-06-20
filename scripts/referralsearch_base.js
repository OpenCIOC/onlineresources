// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
	var $ = jQuery;

	function toggle_ui(show, hide) {
		return function() {
			$(show).removeClass('NotVisible');
			$(hide).addClass('NotVisible');
		}
	}

	var set_form_action = function(action) {
		$('#the_form').prop('action', action);
	}
	var set_email_to = function(email_to) {
		$('#EmailTo').prop('value', email_to);
	}

	var check_all = function(checked) {
		return function() {
			$('input.FollowUpUIChecks').prop('checked', checked);
		};
	};

	$(function() {
		var op_ui = $('#options_ui');
		if (!op_ui.length) {
			return;
		}

		var fn = toggle_ui('', '.FollowUpUI, .FollowUpEmailUI, .FollowUpUIChecks');
		$('#ToggleUINone').click(fn);

		fn = toggle_ui('.FollowUpUI, .FollowUpUIChecks', '.FollowUpEmailUI');
		var chk = $('#ToggleUIFollowUpFlag').click(fn);
		if (chk[0].checked) {
			fn();
		}

		fn = toggle_ui('.FollowUpEmailUI, .FollowUpUIChecks', '.FollowUpUI');
		chk = $('#ToggleUIEmailFollowUp').click(fn);
		if (chk[0].checked) {
			fn();
		}
		
		$("#FollowUpCheckAll, #FollowUpEmailCheckAll").click(check_all(true));
		$("#FollowUpUnCheckAll, #FollowUpEmailUnCheckAll").click(check_all(false));


		$("#FollowUpSubmitCheck, #FollowUpSumbitUnCheck").click(function() {set_form_action( '');})

		$("#FollowUpEmailOrg").click(function() {
			set_form_action('referral_email_prep.asp');
			set_email_to('O');
		});
		$("#FollowUpEmailVol").click(function() {
			set_form_action('referral_email_prep.asp');
			set_email_to('V');
		});

		op_ui.removeClass('NotVisible');
	});
})();
