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

(function($) {
	window['init_vprofiles'] = function (show_tab, root_path, strRemove, txt_not_found, interest_complete_url) {

	var tabs, default_results_area = null, initial_interest = null,
	onbeforeunload = function(cache) {
		cache['personal_values'] = get_form_values('#personalform');
		cache['last_tab'] = tabs.tabs('option', 'active');
	},
	onbeforerestore = function(cache) {
		if (cache['last_tab']) {
			tabs.tabs('option', 'active', cache['last_tab']);
		}
		if (cache['personal_values']) {
			restore_form_values('#personalform', cache['personal_values']);
		}
	},
	edit_outcome = function(event) {
		var parent = $(this).parents('tr').first(), refid=parent.data('refid'),
			dlg = $("#outcome_dialog"), outcome = $('#referral_outcome_' + refid).data('outcome'),
			notes = parent.find(".OutcomeNotes").text(), title = parent.find('.PositionTitle').html(),
			ref_date = parent.find('.ReferralDate').html();


		$('#outcome_dialog_title').html(title + " (" + ref_date + ")");
		$('#outcome_refid')[0].value = refid;
		$('#outcome_state').find("option[value='" + outcome + "']").prop('selected', true);
		$('#outcome_notes')[0].value = notes;

		if (dlg.data('created')) {
			dlg.dialog('open');
		} else {
			dlg.dialog({ modal: true, width: 810});
			dlg.data('created', true);
		}
		return false;
	},
	do_outcome_cancel = function(event) {
		$("#outcome_dialog").dialog("close");
	},
	outcome_callback = function (result) {
		if (result.error) {
			return;
		}

		do_outcome_cancel();

		var parent = $('#referral_outcome_' + result.RefID),
			state = $("#outcome_state")[0].value,
			notes = $.trim($("#outcome_notes")[0].value);

		parent.data('outcome', state);
		if(state === 'N') {
			parent.find('.OutcomeContainer').hide();
		}else{
			if (state === 'S') {
				parent.find('.OutcomeSuccessfull').show();
				parent.find('.OutcomeUnsuccessful').hide();
			} else {
				parent.find('.OutcomeSuccessfull').hide();
				parent.find('.OutcomeUnsuccessful').show();
			}
			parent.find('.OutcomeContainer').show();
		}

		parent.find('.OutcomeNotes').text(notes);
		if (notes) {
			parent.find('.OutcomeNotesContainer').show();
		} else {
			parent.find('.OutcomeNotesContainer').hide();
		}


	},
	do_outcome_submit = function(event) {
		var data = $(this).serialize();
		$.post('outcome2.asp', data, outcome_callback, 'json');
		return false;
	},
	do_referral_hide = function(event) {
		var refid = $(this).parents('tr').first().data('refid'),
			dlg = $('#confirm_hide_dialog');

		$('#hide_confirm_refid')[0].value = refid;
		if (dlg.data('created')) {
			dlg.dialog('open');
		} else {
			dlg.dialog({ modal: true, width: 500});
			dlg.data('created', true);
		}
		return false;
	},
	do_referral_hide_cancel = function(event) {
		$('#confirm_hide_dialog').dialog('close');
		return false;
	},
	do_referral_hide_okay = function(event) {
		do_referral_hide_cancel();
		$.post('hideref.asp', $('#hide_confirm_form').serialize());
		$('#referral_table_row_' + $('#hide_confirm_refid')[0].value).remove();
		if ($('#referral_tab tbody tr').length === 0) {
			// Remove the tab
			tabs.find( ".ui-tabs-nav li:eq(2)" ).remove();
			// Remove the panel
			$( "#referral_tab").remove();
			// Refresh the tabs widget
			tabs.tabs( "refresh" );
		}
	},
	restore_initial_areas_of_interest = function(event) {
		$('#AI_existing_add_container').html(initial_interests);
	},
	do_clear_interests = function(event) {
		$('#AI_existing_add_container input:checked').prop('checked', false);
	};

	$(function($) {
		tabs = $("#TabbedDisplayTabArea").tabs({selected: show_tab});
		init_cached_state('#criteria_form');

		cache_register_onbeforeunload(onbeforeunload);
		cache_register_onbeforerestorevalues(onbeforerestore);

		init_interests(txt_not_found, interest_complete_url);

		restore_cached_state();
		initial_interests = $('#AI_existing_add_container').html();

		$(document).on('click', 'button.referral_outcome_edit', edit_outcome);
		$(document).on('click', 'button.referral_hide', do_referral_hide);
		$('#confirm_cancel').click(do_referral_hide_cancel);
		$('#confirm_okay').click(do_referral_hide_okay);
		$('#outcome_cancel').click(do_outcome_cancel);
		$('#outcome_form').submit(do_outcome_submit);
		$('#criteria_reset_button').click(restore_initial_areas_of_interest);
		$('#clear_interests').click(do_clear_interests);

	});
};
})(jQuery);
