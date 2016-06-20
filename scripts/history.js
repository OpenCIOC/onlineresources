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
/*global diff_match_patch:true */
var init_history_dialog = function($, field_history) {
    var diff_match_patch_loaded = false;
	var dmp = null;

	var current_revision = null;
	var current_compare = null;
	
	var replace_history = function(data) {
		if (data.fail) {
			$('#HistoryFieldContent').html('<em>' + data.errinfo + '</em>');
		} else if (data.compare) {
			if (dmp === null) {
				dmp = new diff_match_patch();
			}

			var d = dmp.diff_main(data.text2, data.text1);
			dmp.diff_cleanupSemantic(d);
			var ds = dmp.diff_prettyHtml(d);
			$('#HistoryFieldContent').html(ds);
		} else {
			$('#HistoryFieldContent').html(data.text1);
		}
	};
	var history_select_changed = function(field, display, id) {
		return function() {
			var lang = $('#HistoryLanguage').prop('value');
			var revision = $('#HistoryRevision').prop('value');
			var compare = $('#HistoryCompare').prop('value');

			if (compare !== current_compare && (
					(current_compare === '' && compare === revision) ||
					(compare === '' && current_compare === current_revision))) {
				current_revision = revision;
				current_compare = compare;
				return;
			}

			var comp = compare;
			if (compare === '' || compare === revision) {
				comp = '';
			}
			$.getJSON(field_history.fielddiff_url.
					replace('[ID]', id).
					replace('[LANG]', lang).
					replace('[FIELD]', field).
					replace('[REV]', revision).
					replace('[COMP]', comp), replace_history);

			current_revision = revision;
			current_compare = compare;
		};
	};

	var add_history_events = null;
	var change_language = function(field, display, id, lang) {
		$('select.HistorySelect').unbind('change');
		$('#HistoryLanguage').unbind('change');

		$("#field_history").
			html('<p class="Info">' + field_history.txt_loading + '</p>').
			dialog('close').
			dialog('open').
			dialog('option', 'title', field_history.txt_fielddifftitle +
					id + " (" + display + ')').
			load(field_history.fielddiffui_url.
				replace("[ID]", id).
				replace('[FIELD]', field).
				replace('[LANG]', lang),
				add_history_events(field, display, id));
	};

	var language_changed = function(field, display, id) {
		return function() {
			var lang = $(this).prop('value');
			change_language(field, display, id, lang);
		};
	};
	
	add_history_events = function(field, display, id) {
		return function() {
			$('select.HistorySelect').
				change(history_select_changed(field, display, id));

			$('#HistoryLanguage').
				change(language_changed(field, display, id));

			current_revision = $('#HistoryRevision').prop('value');
			current_compare = $('#HistoryCompare').prop('value');
		};
	};


	$(".ShowVersions").click(function() {
		var field = $(this).data('ciocfield');
		var display = $(this).data('ciocfielddisplay');
		var id = $(this).data('ciocid');

		if (!diff_match_patch_loaded) {
			diff_match_patch_loaded = true;
			$.getScript(field_history.path_to_start + "scripts/diff_match_patch.min.js");
		}

		change_language(field, display, id, '');

	});

	var toggle_history_fields = function(e) {


		$(e.currentTarget).parent().children('ul').toggle("fast");
	};
	var go_to_field = function(e) {
		var field = $(e.currentTarget).data('fieldname');
		var td = document.getElementById('FIELD_' + field);
		if (td) {
			td.scrollIntoView(true);
		}
	};
	$(document).on('click', '.FieldHistoryJump', go_to_field);
	$(document).on('click', '.HistoryFieldsToggle', toggle_history_fields);

	var hide_children = function() {
		$('.HistoryFieldsToggle').
			parent().children('ul').hide();
	};
	$(".HistorySummary").click(function() {
		var lang = $(this).data('cioclang');
		var id = $(this).data('ciocid');

		$('#revision_history').
			html('Loading...').
			load(field_history.revhistory_url.
				replace('[ID]', id).
				replace('[LANG]', lang), hide_children).
			dialog('open');

	});

	$("#revision_history").dialog({autoOpen: false, width: 330, height: 280, position: ['right', 'top' ], resizable: false, dialogClass: 'RevHistory'});
	$("#field_history").dialog({autoOpen: false, width: 620, height: 280, position: ['right', 'bottom']});

	$(".RevHistory.ui-dialog").css({position:"fixed"});

};

window['init_history_dialog'] = init_history_dialog;
})();


