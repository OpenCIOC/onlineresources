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
	confirm:true
*/
window['only_items_chk_add_html'] = function($, field, before_add) {
	return function (chkid, display) {
		if (before_add) {
			before_add();
		}
		$('#' + field + '_existing_add_container').
			append($('<label>').
				append(
					$('<input>').
						prop({
							id: field + '_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: field + '_ID',
							value: chkid
							})
				).
				append('&nbsp;').
				append(document.createTextNode(display))
			).
			append(' ; ');
	};
};

window['init_check_for_autochecklist'] = function(confirm_string) {
	var $ = jQuery;

	var go_to_unadded_check = function() {
		var check_add = $(this).data('jump_location');
		var input = document.getElementById(check_add);
		if (input) {
			input.scrollIntoView(true);
		}
	};

	var create_list_item = function() {
		return $('<li>').
			append($('<span>').
			data('jump_location', this.id).
			addClass('UnaddedChecklistJump SimulateLink').
			append($(this).parentsUntil('td[data-field-display-name]').parent().data('fieldDisplayName')));
	};

	var entry_form_items = $('input[id^=NEW_]');
	if (!entry_form_items.length) {
		// no elements, do nothing
		return;
	}
	$('#EntryForm').submit(function (event) {
			var fields = entry_form_items.map(function () { return this.value ? this : null; }),
				error_box, error_list;
			if (fields.length && !event.isDefaultPrevented()) {
				var docontinue = confirm(confirm_string);
				if (!docontinue) {
					event.preventDefault();
					$("#SUBMIT_BUTTON").prop('disabled',false);

					error_box = $('#unadded_checklist_error_box');
					error_list = $('#unadded_checklist_error_list');
					var error_list_visible = error_box.is(':visible');

					if (error_list_visible) {
						error_list.children('ul:first').hide('slow',
							function() {
								$(this).remove();
							});
					}
					var ul = $("<ul>");

					if (error_list_visible) {
						ul.hide();
					}


					error_list.append(ul);


					$.each( fields.map(create_list_item),
							function () { ul.append(this); });

					if (error_list_visible) {
						ul.show('slow');
					} else {
						error_box.show('slow');
					}

					return;

				}
				return;
			} else if (event.isDefaultPrevented()) {
				error_box = $('#unadded_checklist_error_box');
				error_list = $('#unadded_checklist_error_list');

				error_box.hide('slow',
						function() {
							error_list.children().remove();
						});
			}
		});

	$(document).on('click', ".UnaddedChecklistJump", go_to_unadded_check);


};
window['init_entryform_items'] = function(jqarray, delete_text, undo_text) {
	var $ = jQuery;
	jqarray.each(function() {
		var sortable = null;
		var obj = this;
		var jqobj = $(obj);
		var next_new_id = 1;
		var ids_dom = jqobj.find('.EntryFormItemContainerIds')[0];
		if (!ids_dom) {
			return;
		}

		var max_add = jqobj.data('maxAdd');
		if (max_add) {
			max_add = parseInt(max_add, 10);
		}

		var ids = [];
		if (ids_dom.value) {
			ids = $.map(ids_dom.value.split(','), function(value) {
					if (value.indexOf('NEW') === 0 && value.indexOf('NEWFB') !== 0) {
						return null;
					}
					return value;
				});
		}
		var deleted_items = {};



		var update_numbering = function() {
			jqobj.find('.EntryFormItemBox').each(function(i) {
					$(this).find('.EntryFormItemCount').text(i+1);
				});
		};
		var endis_restore_add = function(en) {
			if (max_add) {
				var buttons = jqobj.find(".EntryFormItemContent:hidden").parent().find('button.EntryFormItemDelete').prop('disabled', !en);
				add_button.prop('disabled', !en);

				if (en) {
					buttons.removeClass('ui-state-disabled');
					add_button.removeClass('ui-state-disabled');
				} else {
					buttons.addClass('ui-state-disabled');
					add_button.addClass('ui-state-disabled');
				}
			}
		};
		var disable_restore_add = function() {
			endis_restore_add(false);
		};

		var get_enabled_count = function() {
			var deleted = 0;
			var i;
			for (i in deleted_items) {
				deleted++;
			}
			return ids.length - deleted;
		};

		var add = function(force) {
			var count = 0;
			if (max_add && !force) {
				count = get_enabled_count();
				if (count >= max_add) {
					alert("over");
					return;
				}
			}
			var template = jqobj.data('addTmpl');
			ids.push("NEW" + next_new_id++);
			ids_dom.value = ids.join(",");
			var new_item = $(template.replace(/\[COUNT\]/g, ids.length).replace(/\[ID\]/g, ids[ids.length-1]));
			new_item.find('.DatePicker').autodatepicker();
			new_item.find('.Province').combobox({source: window.cioc_province_source});
			if (entryform.service_titles) {
				new_item.find('.ServiceTitleField').combobox({ source: entryform.service_titles });
			}
			jqobj.append(new_item);
			if (sortable) {
				sortable.sortable('refresh');
				update_numbering();
			}
			if (max_add && !force && (count+1 === max_add)) {
				disable_restore_add();
			}
		};

		var add_button = jqobj.parent().find(".EntryFormItemAdd").click(function() { add(false); });

		jqobj.on('click', 'button.EntryFormItemDelete', function() {
				var self = this;
				var entryformbox = $(this).parents('.EntryFormItemBox');
				var hide_target = entryformbox.find('.EntryFormItemContent');
				var my_id = this.id.split('_');
				my_id = my_id[my_id.length-2];

				if (hide_target.is(':visible')) {
					hide_target.hide('slow', function() {
							deleted_items[my_id] = get_form_values(hide_target);

							$(self).text(undo_text);

							// Clear form elements
							hide_target.find('input,select,textarea').each(function() {
									if (this.nodeName.toLowerCase() === 'input' && ( this.type === 'checkbox' || this.type === 'radio')) {

										this.checked = false;
										return;
									}

									if (this.nodeName.toLowerCase() === 'select') {
										$(this).find('option').each(function () {
												this.selected = false;
											});
										return;
									}

									this.value = '';
								});
							endis_restore_add(true);
						});


				} else {
					var count = 0;
					if (max_add) {
						count = get_enabled_count();
						if (count >= max_add) {
							alert("over");
							return;
						}
					}
					var values = deleted_items[my_id];
					if (!values) {
						// XXX how did we get here?
						return;
					}

					delete deleted_items[my_id];
					restore_form_values ( hide_target, values);

					hide_target.show('slow', function () {
								$(self).text(delete_text);
							});

					if (max_add && (count + 1 === max_add)) {
						disable_restore_add();
					}

				}


			});
		if (jqobj.hasClass('sortable')) {
			sortable = jqobj.sortable({items:'.EntryFormItemBox'});
			sortable.bind('sortstart', function(event, ui) {
					ui.helper.bgiframe();
					jqobj.addClass('sorting');
				});
			sortable.bind('sortstop', function() {
					var order = sortable.sortable('toArray');
					ids = $.map(order, function(item) {
							item = item.split('_');
							return item[item.length-2];
						});
					ids_dom.value = ids.join(',');
					setTimeout(function() {
						jqobj.removeClass('sorting');
						update_numbering();
					},1);
				});
		}

		var onbeforeunload = function(cache) {
			cache[obj.id + '_ids'] = ids;
			cache[obj.id + '_deletes'] = deleted_items;
			if (sortable) {
				cache[obj.id + '_order'] = sortable.sortable('toArray');
			}
		};
		cache_register_onbeforeunload(onbeforeunload);

		var onbeforerestorevalues = function(cache) {
			if (cache[obj.id + '_ids']) {
				$.each(cache[obj.id + '_ids'], function(index, value) {
					if (value.indexOf('NEW') === 0) {
						add(true);
					}
				});
			}

			if (cache[obj.id + '_deletes']) {
				deleted_items = cache[obj.id + '_deletes'];
				jqobj.find('.EntryFormItemContent').each(function() {
					var id = this.id.split('_');
					id = id[id.length-2];
					if (deleted_items[id]) {
						$(this).hide().parent().
							find('button.EntryFormItemDelete').text(undo_text);
					}
				});
			}

			if (max_add) {
				var count = get_enabled_count();
				if (count >= max_add) {
					disable_restore_add();
				}
			}

			if (sortable) {
				var order = cache[obj.id + '_order'];
				if (order) {
					order.reverse();
					$.each(order, function(i, item) {
							$('#' + item).detach().prependTo(jqobj);
						});
					sortable.sortable('refresh');
					update_numbering();
				}

			}
		};

		cache_register_onbeforerestorevalues(onbeforerestorevalues);
	});
};

window['init_schedule'] = function($) {
	var on_recur_type_change = function() {
		var container = $(this).parents('.EntryFormItemBox'), type = this.value;

		if (type === '0') {
			container.find('.recurs-ui').hide();
		} else if (type == '1') {
			container.find('.repeat-every-ui, .repeats-on-ui, .recurs-week-label').show();
			container.find('.repeat-week-of-month-ui, .repeat-day-of-month-ui, .recurs-month-label').hide();
		} else if (type == '2') {
			container.find('.repeat-every-ui, .repeat-day-of-month-ui, .recurs-month-label').show();
			container.find('.repeat-week-of-month-ui, .repeats-on-ui, .recurs-week-label').hide();
		} else {
			container.find('.repeat-week-of-month-ui, .repeats-on-ui, .recurs-month-label').show();
			container.find('.repeat-every-ui, .repeat-day-of-month-ui, .recurs-week-label').hide();

		}
	};
	var apply_feedback = function(evt) {
		var self = $(this), container = self.parents('.EntryFormItemBox'), values=self.data('schedule');
		restore_form_values(container, values);
		return false;
	}
	$('#ScheduleEditArea').on('change', '.recur-type-selector', on_recur_type_change).on('click', '.schedule-ui-accept-feedback', apply_feedback).find('.recur-type-selector').each(on_recur_type_change);
};

})();
