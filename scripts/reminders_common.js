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
/*global
 init_autocomplete_checklist:true
*/
	jQuery.fn.autoShorten = function(max, more, less) {
		return this.each(function(){
			max = max || 350;
			more = more || '[read more]';
			less = less || '[less]';
			var self = $(this), html = self.html();
			if (html.length > max) {
				var words = html.substring(0,max).split(" ");
				var shortText = $('<div>').html(words.slice(0, words.length - 1).join(" ") + ' ').append('<span class="ellipse-toggle SimulateLink">&hellip; ' + more +'</span>').html();
				$(this).data('replacementText', html + ' <span class="ellipse-toggle SimulateLink">' + less + '</span>')
				.html(shortText)
				.on('click', 'span.ellipse-toggle', function() {
					var tempText = self.html();
					self.html(self.data('replacementText'));
					self.data('replacementText', tempText);
				});
			}
		});
	};

	var add_new_html = function($, field, name) {
		name = name || (field + '_ID');
		return function(chkid, display) {
			var button = $('#add_' + field), my_cell = button.parent(), my_row = my_cell.parent(), last_row = my_row.prev('tr'),
				col_target = parseInt(my_cell.prop("colspan"), 10), last_row_cols = last_row.find('td').length;
			if (!last_row.length || col_target === last_row_cols) {
				last_row = $('<tr>').insertBefore(my_row);
			}
			last_row.append(
				$('<td>').append(
					$('<label>').
					text(' ' + display).
					prepend(
						$('<input type="checkbox" checked>').prop({
							id: field +'_ID_' + chkid,
							value: chkid,
							name: name
						})
					)
				)
			);
		};
	};

	var init_user_autocomplete = function(url, txt_not_found) {
		init_autocomplete_checklist($, {
			source: url,
			field: 'reminder_user',
			add_new_html: add_new_html($, 'reminder_user'),
			txt_not_found: txt_not_found
		});
	};

	var initialize_reminders_form = function() {
		$(document).on('click', '#add_reminder_agency', function(evt) {
			evt.preventDefault();
			var agency_select = $('#NEW_reminder_agency');
			var agency_add_html = add_new_html($, 'reminder_agency');
			var val = agency_select[0].value;
			if (val) {
				var target_input = $('#reminder_agency_ID_' + val);
				if (target_input.length) {
					target_input.prop('checked', true);
				} else {
					agency_add_html(val, val);
				}
				agency_select.find('option').first().prop({selected: true});
			}
			return false;
		});
		$.each(['NUM', 'VNUM'], function(index, field) {
			$(document).on('click', '#add_' + field, function(evt) {
				evt.preventDefault();
				var field_input = $('#NEW_' + field);
				var field_add_html = add_new_html($, field, field);
				var val = field_input[0].value;
				if (val) {
					var target_input = $('#' + field + '_ID_' + val);
					if (target_input.length) {
						target_input.prop('checked', true);
					} else {
						field_add_html(val, val);
					}
				}
				field_input[0].value = '';
				return false;
			}).on('keypress', '#NEW_' + field, function(evt) {
				if (evt.keyCode === 13) {
					evt.preventDefault();
					$('#add_' + field).trigger('click');
				}
			});

		});
	};
	var hide_empty_headers = function() {
		$('.reminder-section').each(function() {
			if (!$(this).find('.reminder-item:not(.dismissed)').length) {
				$(this).hide();
			}
		});
	};
	var initialize_reminder_list = function(existing_reminders, txt_more, txt_less) {
		$('#reminder-items-inactive').hide();
		hide_empty_headers();
		$('#reminder-header-inactive').addClass("SimulateLink").prepend($('<span class="ui-icon ui-icon-triangle-1-e" style="display: inline-block">'));
		$('#reminder-add-link, #reminder-show-dismissed, #show-closed-notices').uibutton();

		if (!$('#existing-reminders-page').addClass('hide-dismissed').find('.dismissed').length) {
			$('#reminder-dismiss-ui').hide();
		}
		existing_reminders.find('.AutoShorten').autoShorten(null, txt_more, txt_less);
	};

	window['initialize_reminders'] = function(title, userurl, reminder_url, reminder_dismiss_url, txt_colon, txt_more, txt_less, txt_loading, delete_link, txt_not_found) {
		var reminder_dialog = null;
		init_user_autocomplete(userurl, txt_not_found);
		initialize_reminders_form();
		initialize_reminder_list($('#existing-reminders-page'), txt_more, txt_less);
		var reminders_list_div = $('#existing-reminders-page').on('click', '#reminder-header-inactive', function() {
			var inactive = $('#reminder-items-inactive'),
				icon = $(this).find('span.ui-icon');
			if ( inactive.is(':hidden') ) {
				inactive.slideDown('slow');
				icon.removeClass('ui-icon-triangle-1-e').addClass('ui-icon-triangle-1-s');
			} else {
				inactive.slideUp('slow');
				icon.removeClass('ui-icon-triangle-1-s').addClass('ui-icon-triangle-1-e');
			}
		}).on('click', '#reminder-show-dismissed', function() {
			if (this.checked) {
				reminders_list_div.removeClass('hide-dismissed');
				$('.reminder-section').show();
			} else {
				reminders_list_div.addClass('hide-dismissed');
				hide_empty_headers();
			}
		}).uitooltip({
			items: 'span.details-link',
			content: function() {
				return $(this).data('tooltip');
			}
		}).on('click', '.dismiss-reminder,.restore-reminder', function() {
			var self = $(this), is_dismiss = self.is('.dismiss-reminder'),
				reminder_id = self.data('reminderId');
			$.when($.ajax(reminder_dismiss_url.replace('IDIDID', reminder_id), {
				dataType: 'json',
				type: 'post',
				cache: false,
				data: {dismiss: is_dismiss ? 'on' : null, json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					var row = self.parents('tr').first();
					if (data.dismissed) {
						row.addClass('dismissed');
						$('#reminder-dismiss-ui').show();
					} else {
						row.removeClass('dismissed');
						if (!$('#existing-reminders-page .dismissed').length) {
							$('#reminder-dismiss-ui').hide();
						}
					}
				} else {
					/// XXX
				}
			});
			
		});
		var reminders_popup_link = $('#reminders').click(function() {
			var existing_reminders = $('#existing-reminders-page').empty().text(txt_loading);
			$.when($.ajax(reminder_url, {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					existing_reminders[0].innerHTML = data.reminders;
					initialize_reminder_list(existing_reminders, txt_more, txt_less);
					if (reminder_dialog.height() > $(window).height() - 10) {
						reminder_dialog.dialog('option', 'height', $(window).height() - 10);
					}
					reminder_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			if ( ! reminder_dialog ) {
				reminder_dialog = $('#reminder-dialog').dialog({
					title: title,
					width: 500,
					maxHeight: $(window).height() - 10,
					open: function() {
						$(this).dialog({position: "center"});
					}
				});
				$(window).resize($.throttle(250, function() {
					reminder_dialog.dialog('option', 'maxHeight', $(this).height() - 10);
				}));
			} else {
				reminder_dialog.dialog('option', 'height', 'auto');
				reminder_dialog.dialog('open');
			}
		});
		var reminder_edit_dialog = null;
		$('#reminder-dialog').on('click', '.edit-link', function(evt) {
			evt.preventDefault();
			$('#reminder-edit-dialog').empty().text(txt_loading);
			$.when($.ajax(this.href, {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.find('.DatePicker').autodatepicker();
					init_user_autocomplete(userurl);
					reminder_edit_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_edit_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			if (!reminder_edit_dialog) {
				reminder_edit_dialog = $('#reminder-edit-dialog').dialog({width: 'auto', height: 'auto'});
			} else {
				reminder_edit_dialog.dialog('open');
			}
			return false;
		});
		$('#reminder-edit-dialog').on('submit', 'form', function(evt) {
			evt.preventDefault();
			var form = $(this);
			$.when($.ajax(form.prop('action'), {
				dataType: 'json',
				data: form.serialize(),
				type: form.prop('method')
			})).done(function(data) {
				if (!data.success) {
					//error condition
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.find('.DatePicker').autodatepicker();
					init_user_autocomplete(userurl);
				} else {
					reminders_popup_link.trigger('click');
					reminder_edit_dialog.dialog('close');
				}
			});
			return false;
		}).on('click', '#delete-reminder', function(evt) {
			evt.preventDefault();
			$('#reminder-edit-dialog').empty().text(txt_loading);
			$.when($.ajax(delete_link.replace('IDIDID', $(this).data('reminderId')), {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_edit_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			return false;
		});
	};
})();
