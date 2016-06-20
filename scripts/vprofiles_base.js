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
window['init_vprofiles'] = function(show_tab, root_path, strRemove, specific_interest_url) {
	var tabs, interests, default_results_area=null, dlg_selected_interests,
	selected_interests, 
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
	find_interests = function(event) {
		if (specific_interest_url) {
			$.get(specific_interest_url, null, interests_callback, 'html');
		} else if (default_results_area) {
			$('#results_area').html(default_results_area);
		}
		dlg_selected_interests.empty().append(selected_interests.children().clone(true));
		if (!interests) {
			interests = $('#interest_dialog').dialog({ modal: true, width: 675, height: 400 });
		} else {
			interests.dialog('open');
		}
		return false;
	},
	interests_callback = function(data) {
		var results_area = $('#results_area'),
			interests_input = dlg_selected_interests.find('.selected_interests_input'),
			val = $.trim(interests_input[0].value), interest_ids = (val && val.split(',')) || [];

		if (! default_results_area) {
			default_results_area = results_area.html();
		}
		results_area.html(data).
			find('.InterestResult').each(function() {
				var self = $(this), id=self.data('id');
				if ($.inArray(id.toString(), interest_ids) !== -1) {
					self.find('.interest_add').hide();
					self.find('.interest_added').show();
				}
			});
	},
	interests_submit = function(event) {
		var data = $(this).serialize();
		$.post('../interestfind.asp', data, interests_callback, 'html');
		return false;
	},
	sortfn = function(a,b) {
		var left = $(a).text().toUpperCase(), right = $(b).text().toUpperCase();
		if (left < right) { return (-1 * direction); }
		if (left > right) { return (1 * direction); }
		return 0;
	},
	add_interest = function(event) {
		var self = $(this), parent = self.parents('li.InterestResult:first');
			id = parent.data('id'), interests_input = dlg_selected_interests.find('.selected_interests_input'),
			val = $.trim(interests_input[0].value), interest_ids = (val && val.split(',')) || [];

		if ($.inArray(id.toString(), interest_ids) === -1) {
			dlg_selected_interests.find('.NoSelectedInterests').hide();

			interest_ids.push(id);
			interests_input[0].value = interest_ids.join(',');
			
			
			dlg_selected_interests.append($('<div class="selected_interest">' + parent.find('.source_interest_text').html() + ' [ <a href="#" class="remove_interest"><img src="' + root_path + 'images/redx.gif" alt="' + strRemove + '"></a> ]</div>').data('id', id));

			
			var interests = dlg_selected_interests.find('div.selected_interest').get();
			$.each(interests, function(index, item) { dlg_selected_interests.append(item); });

		}
		self.hide();
		parent.find('.interest_added').show();
		return false;
	},
	remove_interest = function(event) {
		var self = $(this), parent = self.parents('.selected_interest:first');
			id = parent.data('id'), term_list= parent.parents('.TermList'), 
			interests_input = term_list.find('.selected_interests_input'),
			val = $.trim(interests_input[0].value), interest_ids = (val && val.split(',')) || [];

		interest_ids = $.grep(interest_ids, function(item, index) { return item !== id.toString(); });
		interests_input[0].value = interest_ids.join(',');

		parent.remove();

		$('#interest_add_' + id).show();
		$('#interest_added_' + id).hide();

		if (interest_ids.length === 0) {
			term_list.find('.NoSelectedInterests').show();
		}
		
		return false;
	},
	clear_interests = function(event) {
		var self = $(this), parent = self.parents('.InterestList:first');

		parent.find('.selected_interests_input')[0].value = '';
		parent.find('.selected_interest').remove();
		parent.find('.NoSelectedInterests').show();
		
		return false;
	},
	dlg_clear_interests = function(event) {
		var results_area = $('#results_area');

		results_area.find('.interest_added').hide();
		results_area.find('.interest_add').show();
		clear_interests.call(this);


		return false;
	},
	accept_interests = function(event){
		interests.dialog('close');
		selected_interests.empty().append(dlg_selected_interests.children());
		return false;
	};
	
	$(function($) {
		tabs = $("#TabbedDisplayTabArea").tabs({selected: show_tab});
		init_cached_state('#criteria_form');
		
		cache_register_onbeforeunload(onbeforeunload);
		cache_register_onbeforerestorevalues(onbeforerestore);

		restore_cached_state();

		dlg_selected_interests = $('#dlg_selected_interests');
		selected_interests = $('#selected_interests');



		$(document).on('click', 'input.referral_outcome_edit', edit_outcome);
		$(document).on('click', 'input.referral_hide', do_referral_hide);
		$('#confirm_cancel').click(do_referral_hide_cancel);
		$('#confirm_okay').click(do_referral_hide_okay);
		$('#outcome_cancel').click(do_outcome_cancel);
		$('#outcome_form').submit(do_outcome_submit);
		$('#interests_button').click(find_interests);
		$('#interest_search_form').submit(interests_submit);
		$('#interest_dialog').delegate('.interest_add', 'click', add_interest);
		$('#interest_dialog, #selected_interests').delegate('.remove_interest', 'click', remove_interest);
		$('#clear_button').click(dlg_clear_interests);
		$('#clear_interests').click(clear_interests);
		$('#accept_button').click(accept_interests);

		var interests_cache = selected_interests.html();
		$('#criteria_reset_button').click(function() {
			$('#criteria_form')[0].reset();
			selected_interests.html(interests_cache);
			return false;
		});
	});
};
})(jQuery);

