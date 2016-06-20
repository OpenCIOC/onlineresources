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

(function(){
var $ = jQuery;
var configure_entry_form_button = function() {
	$("#SUBMIT_BUTTON").click(function(evt) { 
		var btn = $('#SUBMIT_BUTTON');
		if (btn.prop('disabled')) {
			return;
		}
		btn.prop('disabled', true);
		setTimeout(function() {
			$("#EntryForm").submit();
		}, 1);
	});

	$(document).bind('keydown', function(evt) {
		if (evt.ctrlKey && String.fromCharCode( evt.which).toLowerCase() === 's') {
			setTimeout(function() {
				$('#SUBMIT_BUTTON').click();
			}, 1);
			evt.preventDefault();
			evt.stopPropagation();
			return false;
		}
	});
	$("#SUBMIT_BUTTON").prop('disabled',false);
}
window['configure_entry_form_button'] = configure_entry_form_button;

var configure_feedback_submit_button = function() {
	 var value = $("#SUBMIT_BUTTON").prop('value');
	$("#SUBMIT_BUTTON").replaceWith($('<input type="button" class="btn btn-default" id="SUBMIT_BUTTON">').prop('value', value));
	$('#EntryForm').submit(function() {
		var retval = validateForm();
		if (retval === false) {
			$("#SUBMIT_BUTTON").prop('disabled', false);
		}
		return retval;
	});
}
window['configure_feedback_submit_button'] = configure_feedback_submit_button;

})();
