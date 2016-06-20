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

/*global cache_register_onbeforeunload:true cache_register_onbeforerestorevalues:true restore_form_values:true get_form_values:true */
(function() {
var $ = jQuery;
var init_pubs_dropdown = function(url) {
	var pubs = $('#GHPBID');
	if (pubs.length === 0) {
		return;
	}

	var pb_selection_state = {};
	var gh_selection_state = {};

	var last_non_pub_selection = null;
	var last_gh_ui = null;

	var gh_search_selection = $('#general_heading_search_selection');
	var pub_search_selection = $('#publication_search_selection');
	var pubs_dom = pubs[0];


	var apply_gh_ui = function() {
		if (!last_gh_ui) {
			$("GHID").empty();
			$("GHIDx").empty();
			return;
		}
		$("#GHID").parent().html('<select id="GHID" name="GHID" multiple>' + last_gh_ui + '</select>');
		$("#GHIDx").parent().html('<select id="GHIDx" name="GHIDx" multiple>' + last_gh_ui + '</select>');

	};
	pubs.change(function(evt) {
		var target = evt.target;
		if (target.value === '') {
			gh_search_selection.addClass('NotVisible');
			pub_search_selection.removeClass('NotVisible');
			restore_form_values(pub_search_selection, pb_selection_state);

			gh_selection_state = get_form_values(gh_search_selection);
			$("#GHID").empty();
			$("#GHIDx").empty();

		} else {
			gh_search_selection.removeClass('NotVisible');
			pub_search_selection.addClass('NotVisible');

			pb_selection_state = get_form_values(pb_selection_state);

			if (last_non_pub_selection === target.value) {
				apply_gh_ui();
				if (last_gh_ui !== null) {
					restore_form_values(gh_search_selection, gh_selection_state);
				}
			} else {
				$.getJSON(url, {PBID: target.value}, function(result) {
					var innerHTML = result['innerHTML'];
					if (!innerHTML) {
						last_gh_ui = "";
						$("#GHID").empty();
						$("#GHIDx").empty();
						return;
					}
					last_non_pub_selection = target.value;

					last_gh_ui = innerHTML;

					apply_gh_ui();
				});
			}


		}

	});


	cache_register_onbeforeunload(function(cache) {
		cache["pubsearch"] = {
			last_gh_ui: last_gh_ui,
		pb_selection_state: pb_selection_state,
		gh_selection_state: gh_selection_state,
		last_non_pub_selection: last_non_pub_selection,
		pubs_value: pubs_dom.value
		};
	});

	cache_register_onbeforerestorevalues(function(cache) {
		var pubsearch = cache['pubsearch'];
		if (!pubsearch) {
			return;
		}

		last_gh_ui = pubsearch.last_gh_ui;
		last_non_pub_selection = pubsearch.last_non_pub_selection;
		pb_selection_state = pubsearch.pb_selection_state;
		gh_selection_state = pubsearch.gh_selection_state;

		if (pubsearch.pubs_value) {
			gh_search_selection.removeClass('NotVisible');
			pub_search_selection.addClass('NotVisible');
			apply_gh_ui();
		}
	});
};
window['init_pubs_dropdown'] = init_pubs_dropdown;

var checklist_ui;
var get_advsrch_checklist = function(url, chklst, chklst_src) {
	var title = $('#Chk' + chklst).remove().html();

	if (chklst_src[0].options.length === 0) {
		$("#CheckListSourceContainer").addClass('NotVisible');
	}


	return $.getJSON(url, { ChkType: chklst }).done(function(result) {
		var html = result['innerHTML'];
		if(!html) {
			return;
		}

		checklist_ui.append($('<p>').html('<div class="FieldLabelLeftClr">' + title + '</div>' + html));

		return result;
	});
};

var init_checklist_search = function(url) {
	checklist_ui = $("#CheckListSourceContainer").parent();
	var initial_checklist_html = checklist_ui.html();


	checklist_ui.delegate('#AddChecklistCriteria', 'click', function(evt) {
		evt.preventDefault();
		evt.stopPropagation();

		var chklst_src = $('#CheckListSource');
		if (chklst_src[0].options.length === 0) {
			return;
		}

		var chklst = chklst_src[0].value;

		get_advsrch_checklist(url, chklst, chklst_src);

	});

	$('#ResetForm').click(function() {
		checklist_ui.html(initial_checklist_html);
	});
	cache_register_onbeforeunload(function(cache) {
		cache['checklist_ui'] = checklist_ui.html();
	});

	cache_register_onbeforerestorevalues(function(cache) {
		var html = cache['checklist_ui'];
		if (!html) {
			return;
		}
		checklist_ui.html(html);
	});

};

window['init_checklist_search'] = init_checklist_search;
window['get_advsrch_checklist'] = get_advsrch_checklist;
})();

