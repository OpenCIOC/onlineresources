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

/*global cache_register_onbeforeunload:true cache_register_onbeforerestorevalues:true init_cached_state:true restore_cached_state:true */
(function($) {
	var toggle_name_rows = function(speed) {
		var tax_name = $('#generalheading_TaxonomyName');
		if (tax_name.prop('checked') && !tax_name.prop('disabled')) {
			$('.name-row').hide(speed);
		} else {
			$('.name-row').show(speed);
		}
	};
	var append_edit_icon = function(target) {
		var self = $(target);
		self.find('.remove-link').before('<a class="SimulateLink edit-link"><img src="/images/edit.gif"></a> ');
		return self;
	};
	window['init_gh_tax_edit'] = function(frame_url, no_terms) {
		init_cached_state();
		
		cache_register_onbeforeunload(function(cache) {
			cache['tax_selection'] = $('#tax-selection').html();
		});

		cache_register_onbeforerestorevalues(function(cache) {
			var selection = cache['tax_selection'];
			if (selection) {
				$('#tax-selection').html(selection);
			}
		});

		restore_cached_state();

		toggle_name_rows();

		$('#generalheading_TaxonomyName').click(function() { toggle_name_rows('slow'); });

		$(document).on('click', 'a.remove-link', function() {
			var parent = $(this).parents('li').first(), ul = parent.parent(), div = ul.parent(),
				which = div.data('match');
			parent.remove();
			if (ul.children().length === 0) {
				ul.remove();
				div.text(no_terms);
			} else {
				ul.children().each(function(index) {
					var prefix = which + '-' + index + '.Code-';
					$(this).find('input').prop('name', function(index) {
						return prefix + index;
					});
				});
			}
			check_can_auto_name();
		});
		var check_can_auto_name = function() {
			if (old_contents) {
				return;
			}
			var tax_selection = $('#tax-selection'), mm_count = tax_selection.find('.MustMatchTermList li').length,
				ma_count = tax_selection.find('.MatchAnyTermList li').length,
				cant_set_auto_name = ma_count > 1 || (mm_count  && ma_count);
				//tax_name = $('#generalheading_TaxonomyName'), was_disabled = tax_name.prop('disabled');

			$('#generalheading_TaxonomyName').prop('disabled', cant_set_auto_name);
			toggle_name_rows();
		};
		var searchFrame = $('#searchFrame');
		var win = $(window).resize(function() {
			dialog.dialog("option", {
				width: win.width() - 30,
				height: win.height() - 30
			});
			dialog.dialog('option','position', 'center');
			searchFrame.prop('height', dialog.height());

		});
		var dialog = $('#tax-selection-dialog').dialog({
			autoOpen: false,
			resizable: false,
			draggable: false,
			modal: true,
			open: function() {
				dialog.dialog('option', {
					width: win.width() - 30,
					height: win.height() - 30
				});
				dialog.dialog('option', 'position', 'center');
				searchFrame.prop('height', dialog.height());
			},
			close: function() {
				$("html").css("overflow", "");
				$('#dialog-selected-target').empty();
				if (old_contents) {
					$('#tax-selection').append(old_contents);
					old_contents = null;
				}
				check_can_auto_name();
			}
		});
		var old_contents = null;
		$('#modify-term-selection').click(function() {
			var tax_selection = $('#tax-selection');
			old_contents = tax_selection.contents().remove();

			searchFrame.prop('src', frame_url);

			$('#dialog-selected-target').empty().append(append_edit_icon(old_contents.clone()));
			$("html").css("overflow", "hidden");
			dialog.dialog('open');
		});

		var term_sort_fn = function(a,b) {
			if (a.code < b.code) { return -1; }
			if (a.code > b.code) { return 1; }
			return 0;
		};
		window['addBuildTerm'] = function(code, term) {
			var term_list = $('#BuildTermList'),
				term_text_el = $('#BuildTermText'),
				existing_terms = term_list.data('existingTerms') || [];

			if (!existing_terms.length) {
				term_text_el = $('<span id="BuildTermText">');
				term_list.empty().append(term_text_el).append($('<a id="clear-build-term-list" class="SimulateLink"><img src="/images/x.gif"></a>'));
				$('#SelectDiv,#SuggestDiv').show();
			} else if ($.inArray(code, $.map(existing_terms, function(x) { return x.code; })) >= 0) {
				return;
			}
			

			existing_terms.push({code: code, term: term});
			existing_terms.sort(term_sort_fn);

			term_list.data('existingTerms', existing_terms);

			term_text_el.text($.map(existing_terms, function(x) { return x.term; }).join(' ~ ') + ' ');

		};

		dialog.on('click', '#clear-build-term-list', function() {
			$('#BuildTermList').data('existingTerms', []).empty().text(no_terms);
			$('#SelectDiv,#SuggestDiv').hide();
		}).on('click', '.edit-link', function() {
			var self = $(this), li = self.parent(), term=$.trim(li.text()), terms = term.split(' ~ '),
				codes = li.find('input').map(function() { return this.value; }),
				existing_terms = [], i;

			for (i = 0; i < codes.length; i++) {
				existing_terms.push({code: codes[i], term: terms[i]});
			}


			$('#BuildTermList').data('existingTerms', existing_terms).empty().
				append($('<span id="BuildTermText">').text(term + ' ')).
				append($('<a id="clear-build-term-list" class="SimulateLink"><img src="/images/x.gif"></a>'));

			$('#SelectDiv,#SuggestDiv').show();
		});

		$('#add-match-all,#add-match-any').click(function() {
			var term_list = $('#BuildTermList'), which = $(this).data('target'),
				target_parent = dialog.find('.' + which + 'TermList'),
				target = target_parent.children('ul'),
				count = target.length ? target.children().length : 0,
				li = $('<li class="TermItem">').html($('#BuildTermText').html()).append($('<a class="SimulateLink remove-link"><img src="/images/x.gif"></a>')),
				prefix = '<input type="hidden" name="' + which + '-' + count + '.Code-';

			append_edit_icon(li);

			if (!target.length) {
				target = $('<ul>');
				target_parent.empty().append(target);
			}
			
			$.each(term_list.data('existingTerms'), function(index, el) {
				li.append($(prefix + index + '" value="' + el.code + '">"'));
			});

			target.append(li);
			
			$('#clear-build-term-list').trigger('click');

		});
		$('#suggest-link,#suggest-term').click(function() {
			var term_list = $('#BuildTermList'), st = $(this).data('st'),
				existing_terms = term_list.data('existingTerms'),
				display = $.map(existing_terms, function(x) { return x.term; }).join(' ~ '),
				codes = $.map(existing_terms, function(x) { return x.code; }).join(','),
				params = {ST: st, TC: codes, TCD: display};

			$('#searchFrame').prop('src', frame_url + '&' + $.param(params));
		});
		$('#save-tax-form').click(function() {
			$('#tax-selection').append($('#dialog-selected-target').contents().find('.edit-link').remove().end());
			old_contents = null;
			dialog.dialog('close');
		});
		$('#reset-tax-form').click(function() {
			$('#dialog-selected-target').empty().append(append_edit_icon(old_contents.clone()));
		});
		$('#cancel-tax-form').click(function() {
			dialog.dialog('close');
		});
		$('#clear-tax-form').click(function() {
			$('#dialog-selected-target').find('.MustMatchTermList,.MatchAnyTermList').empty().text(no_terms);
			$('#generalheading_TaxonomyRestrict').prop('checked', false);
		});

	};

})(jQuery);
