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
/*global */
	var config = {}, $=jQuery, vacancy_elements=null;
	var initialize_vacancy_options = function(options) {
		config = options;
	};
	var inserted_incrementers = {};
	var edit_button_sets = {};
	var bt_vut_ids_to_refresh = '';

	var set_button_icon = function() {
		var self = $(this);
		self.uibutton({
			icons: {
				primary: self.data('icon')
			},
			text: false
		});
	};

	var apply_vacancy_ui = function(data) {
		vacancy_elements = vacancy_elements.map(function() { return data.indexOf($(this).data('vutId')) >= 0 ? this : null ; });
		vacancy_elements.each(function() {
			var self = $(this), vut_id = self.data('vutId');
			if (!self.data('uiAdded')) {
				self.data('uiAdded', true);
				var buttonset = $('<span class="vacancy-ui vacancy-buttonset"><button class="vacancy-edit" id="vacancy-edit-' + vut_id + '" data-vut-id="' + vut_id + '" title="' + config.edit_txt + '" data-icon="ui-icon-pencil">' + config.edit_txt + '</button><button class="vacancy-history" data-icon="ui-icon-note" data-vut-id="' + vut_id + '" title="' + config.history_txt + '">' + config.history_txt + '</button></span>').buttonset().insertAfter(self);
				buttonset.find('button').each(set_button_icon);
			}
		});
	};

	var insert_incrementer_ui = function(edit_button_set, vut_id) {
		var buttonset = $('<span class="vacancy-incrementer-ui vacancy-buttonset" style="display: none;" id="vacancy-incrementer-' + vut_id + '" data-vut-id="' + vut_id + '"><button class="vacancy-incrementer-up" data-icon="ui-icon-plusthick">' + config.up_txt + '</button><button class="vacancy-incrementer-down" data-icon="ui-icon-minusthick">' + config.down_txt + '</button><button class="vacancy-incrementer-done" data-icon="ui-icon-check">' + config.done_txt + '</button></span>').buttonset().insertAfter(edit_button_set);
		buttonset.find('button').each(set_button_icon);
		return buttonset;
	};

	var insert_notification = function(vacancy_notify, className, text) {
		var notification = $(
				'<div class="alert alert-dismissable ' + className + '" style="display: none"></div>'
			).text(text).append(
				'<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
			),
			first_child = vacancy_notify.children().first();
		if (first_child.length) {
			first_child.before(notification);
		} else {
			vacancy_notify.append(notification);
		}

		notification.slideDown('slow');
	};

	var handle_vacancy_updates = function(updates) {
		$.each(updates, function(idx, data) {
			$('#vacancy-count-' + data.bt_vut_id).text(data.text);
		});
	};
	var handle_vacancy_increment_result = function(vut_id, vacancy, td, vacancy_notify) {
		return function(data) {
			td.unblock();
			if (data.updates) {
				handle_vacancy_updates(data.updates);
			}
			insert_notification(vacancy_notify, (data.success ? 'alert-highlight' : 'alert-error') + ' vacancy-notification', data.msg);
		};
	};

	var handle_vacancy_increment_failure = function(vut_id, vacancy, td, vacancy_notify) {
		return function(jqXHR, textStatus) {
			td.unblock();
			insert_notification(vacancy_notify, 'alert-error vacancy-notification', config.server_error_txt + (textStatus !== 'error' ? textStatus : jqXHR.statusText));
		};
	};

	var timeoutID;
	var request_vacancy_update = function() {
		if (!bt_vut_ids_to_refresh) {
			return;
		}
		if (timeoutID) {
			clearTimeout(timeoutID);
		}
		timeoutID = setTimeout(get_updated_vacancy, 15000);
	};

	var get_updated_vacancy = function() {
		timeoutID = null;
		$.ajax({
			dataType: "json",
			url: config.refresh_url,
			cache: false,
			data: {
				ids: bt_vut_ids_to_refresh
			}
		}).done(function(data) {
			if (data.success) {
				handle_vacancy_updates(data.updates);
			}
		}).always(request_vacancy_update);
	};

	var increment = function(value, buttonset) {
		var td = buttonset.parent().block({message: null});
		var vut_id = buttonset.data('vutId');
		var vacancy = td.find('.vacancy-count');
		var vacancy_notify = td.find('.vacancy-notify-area');
		if (!vacancy_notify.length) {
			vacancy_notify = $('<div class="vacancy-notify-area alert-stack"></div>');
			vacancy_notify.appendTo(td);
		}
		$.ajax({
			dataType: "json",
			url: config.increment_url,
			type: 'POST',
			data: {
				BT_VUT_ID: vut_id,
				Value: value
			}
		}).done(
			handle_vacancy_increment_result(vut_id, vacancy, td, vacancy_notify)
		).fail(
			handle_vacancy_increment_failure(vut_id, vacancy, td, vacancy_notify)
		);
	};

	var initialize_vacancy_ui =  function() {
		if (!config.permission_url) {
			return;
		}
		vacancy_elements = $('.vacancy-count');
		var ids = vacancy_elements.map(function() { return $(this).data('vutId'); }).get();
		ids = ids.join();
		bt_vut_ids_to_refresh = ids;
		if (!ids) {
			return;
		}
		$.ajax({
			dataType: "json",
			url: config.permission_url,
			cache: false,
			data: {ids: ids}
		}).done(apply_vacancy_ui);

		request_vacancy_update();
	};

	var vacancy_dialog = null;
	var get_dialog = function() {
		if (!vacancy_dialog) {
			vacancy_dialog = $('<div id="vacancy-dialog" style="display:none;"></div>').appendTo($('body')).dialog({
				autoOpen: false,
				closeText: config.close_txt,
				title: config.history_title_txt,
				minWidth: 500
			});

		}

		return vacancy_dialog;
	};

	var dialog_error = function(dialog, msg) {
		var error_p = $('<p class="Alert"></p>').text(msg);
		dialog.empty().append(error_p);
	};
	var handle_history_success = function(data) {
		var dialog = get_dialog();
		if (data.success) {
			dialog.empty().html(data.content);
			dialog.dialog('option', 'title', data.title);
		} else {
			dialog_error(dialog, data.content);
			dialog.dialog('option', 'title', data.title);
		}
	};

	var handle_history_fail = function(jqXHR, textStatus) {
		var dialog = get_dialog();
		dialog_error(dialog, config.server_error_txt + (textStatus !== 'error' ? textStatus : jqXHR.statusText));
	};
	var initialize_vacancy_events = function() {

		$(document).on('click', '.vacancy-edit', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var self = $(this), vut_id = self.data('vutId'), buttonset = self.parent(), incrementer_ui = inserted_incrementers[vut_id];

			if (!incrementer_ui) {
				incrementer_ui = insert_incrementer_ui(buttonset, vut_id);
				edit_button_sets[vut_id] = buttonset;
			}

			self.parent().hide();
			incrementer_ui.show();
		}).on('click', '.vacancy-incrementer-done', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var buttonset = $(this).parent(), vut_id = buttonset.data('vutId'), edit_button_set = edit_button_sets[vut_id];
			buttonset.hide();
			edit_button_set.show();

			var toremove = buttonset.parent().parent().find('.vacancy-notify-area');
			toremove.slideUp('fast', function() {
				toremove.remove();
			});

		}).on('click', '.vacancy-incrementer-up', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			increment(1, $(this).parent());
		}).on('click', '.vacancy-incrementer-down', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			increment(-1, $(this).parent());
		}).on('click', '.vacancy-history', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var self = $(this), vut_id = self.data('vutId');
			var dialog = get_dialog();

			dialog.html('<p class="Info">' + config.loading_txt + '</p>').dialog('close').dialog('open').dialog('option', 'title', config.history_title_txt);

			$.ajax({
				dataType: 'json',
				url: config.history_url,
				cache: false,
				data: {BT_VUT_ID: vut_id}
			}).done(handle_history_success).fail(handle_history_fail);

		}).on('click', '.close', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var self = $(this),
				toremove = self.parents('.' + self.data('dismiss')).first();
			toremove.slideUp('slow', function() { toremove.remove(); });
		});
	};

	window['initialize_vacancy'] = function(options) {
		initialize_vacancy_options(options);
		initialize_vacancy_ui();
		initialize_vacancy_events();
	};

	window['initialize_vacancy_options'] = initialize_vacancy_options;
	window['initialize_vacancy_ui'] = initialize_vacancy_ui;
	window['initialize_vacancy_events'] = initialize_vacancy_events;


})();

