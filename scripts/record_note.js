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
var init_entryform_notes = function(jqarray, show_text, hide_text) {
	var $= jQuery;
	jqarray.each(function() {
		var sortable = null;
		var obj = this;
		var order = [];
		var jqobj = $(obj);
		var parent = jqobj.parent();
		var next_new_id = 1;
		var updates_dom = jqobj.find('.EntryFormNotesUpdateIds')[0];
		if (!updates_dom) {
			return;
		}
		var deletes_dom = jqobj.find('.EntryFormNotesDeleteIds')[0];
		var cancels_dom = jqobj.find('.EntryFormNotesCancelIds')[0];
		var restores_dom = jqobj.find('.EntryFormNotesRestoreIds')[0];

		var updates = [];
		var deletes = [];
		var cancels = [];
		var cancel_reason = {};
		var restores = [];

		var add_templated = function(data, isnew) {
			updates.push(data.id);
			updates_dom.value = updates.join(',');
			var count = jqobj.find('.EntryFormItemBox').length + 1;
				template = jqobj.data('addTmpl'),
				new_item = $(template.replace(/\[COUNT\]/g, count).
						replace(/\[ID\]/g, data.id).
						replace(/\[MODIFIED_DATE\]/g, data.modified_date || '').
						replace(/\[MODIFIED_BY\]/g, data.modified_by || '').
						replace(/\[CREATED_DATE\]/g, data.created_date || '').
						replace(/\[CREATED_BY\]/g, data.created_by || '').
						replace(/\[NOTE_VALUE\]/g, data.note_value || ''));
			if (data.note_type) {
				new_item.find("option[value='" + data.note_type + "']").prop('selected', true);
			}

			if (data.created_date) {
				new_item.find('tr.CreatedField').show();
			}
			if (data.modified_date && (data.modified_date !== data.created_date || data.modified_by !== data.created_by)) {
				new_item.find('tr.ModifiedField').show();
			}

			if (isnew) {
				new_item.find('.NewFlag').show();
			}

			jqobj.append(new_item);

		};

		var add = function() {
			var id = "NEW" + next_new_id++;

			add_templated({id: id}, true);
		};

		var add_button = parent.find(".EntryFormItemAdd").click(function() { add(false); });

		var do_update = function(button) {
			var container = $(button).parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent');

			add_templated(entry.data('formValues'));
			container.hide(); // remove?

		};
		var do_delete = function(button) {
			var id = button.id.split('_'), btn = $(button),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent');

			entry.css('text-decoration', 'line-through');
			deletes.push(id[id.length-2]);
			deletes_dom.value = deletes.join(',');
			container.data('actionToRestore', 'delete');

			// hide button, show restore button
			btn.parent().hide().prev().show();
			
		};
		var do_cancel = function(button, selected_action) {
			var id = button.id.split('_'), btn = $(button),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent'),
				splitpoint = button.id.lastIndexOf('_'),
				fieldname = button.id.substring(0,splitpoint) + '_CANCEL_REASON';

			id = id[id.length-2];
			entry.prepend(selected_action.data('cancelTemplate'));
			cancels.push(id);
			cancels_dom.value = cancels.join(',');
			cancel_reason[id] = selected_action.data('cancelType');
			jqobj.append($('<input>').prop({
				type: 'hidden', 
				id: fieldname, 
				name: fieldname, 
				value: selected_action.data('cancelType')
			}));
			container.data('actionToRestore', 'cancel');

			// hide button, show restore button
			btn.parent().hide().prev().show();
		};
		var menu_actions = { 
			'update': do_update, 
			'delete': do_delete, 
			'cancel': do_cancel
		};
		var menu = parent.find('.EntryFormItemActionMenu').menu({
			select: function(event, ui) {
				$(this).hide();
				menu_actions[ui.item.data('action')](menu.data('activeButton'), ui.item);
			}
		}).hide().css({position: 'absolute', zIndex: 1});
		parent.on('click', '.EntryFormItemAction', function(event) {
			menu.data('activeButton', this);
			if (menu.is(':visible') ){
				menu.hide();
				return false;
			}
			menu.menu('blur').show();
			menu.position({
				my: "right top",
				at: "right bottom",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});

		parent.find('.EntryFormItemViewHidden').click(function(event) {
			var self = $(this), hide_target = self.next();
			if (hide_target.is(':visible')) {
				self.text(show_text);
				hide_target.hide();
			} else {
				self.text(hide_text);
				hide_target.show();
			}	

		});

		var restore_delete = function(id, btn, container, entry) {
			entry.css('text-decoration', 'none');
			deletes = $.grep(deletes, function(value) { return value !== id;});
			deletes_dom.value = deletes.join(',');

			// hide button, show restore button
			btn.parent().hide().next().show();
		};
		var restore_cancel = function(id, btn, container, entry) {
			var button = btn[0],
				splitpoint = button.id.lastIndexOf('_'),
				fieldname = button.id.substring(0,splitpoint) + '_CANCEL_REASON';

			entry.find('.EntryFormItemCancelledDetails').remove();
			cancels = $.grep(cancels, function(value) { return value !== id;}),
			cancels_dom.value = cancels.join(',');
			delete cancel_reason[id];
			$('#' + fieldname).remove();

			btn.parent().hide().next().show();
		};
		var restore_fns = {
			'delete': restore_delete,
			'cancel': restore_cancel
		};

		parent.on('click', '.EntryFormItemRestoreAction', function(event) {
			var id = this.id.split('_'), btn = $(this),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent');

			restore_fns[container.data('actionToRestore')](id[id.length-2], btn, container, entry);
		});

		var do_restore_cancel = function(event) {
			var id = this.id.split('_'), btn = $(this),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemCancelledDetails');

			entry.css('text-decoration', 'line-through');
			btn.parent().hide().prev().show();

			restores.push(id[id.length-2]);
			restores_dom.value = restores.join(',');

		};
		parent.on('click', '.EntryFormItemRestoreCancel', do_restore_cancel);

		parent.on('click', '.EntryFormItemDontRestoreCancel', function(event) {
			var id = this.id.split('_'), btn = $(this),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemCancelledDetails');

			entry.css('text-decoration', 'none');
			btn.parent().hide().next().show();
			id = id[id.length - 2];
			restores = $.grep(restores, function(value) { return value !== id;}),
			restores_dom.value = restores.join(',');

		});

		var onbeforeunload = function(cache) {
			cache[obj.id + '_updates'] = updates;
			cache[obj.id + '_deletes'] = deletes;
			cache[obj.id + '_restores'] = restores;
			cache[obj.id + '_cancels'] = cancels;
			cache[obj.id + '_cancel_reason'] = cancel_reason;
		};
		cache_register_onbeforeunload(onbeforeunload);

		var onbeforerestorevalues = function(cache) {
			var id_prefix = obj.id.substring(0, obj.id.lastIndexOf('_')) + '_';
			if (cache[obj.id + '_updates']) {
				
				$.each(cache[obj.id + '_updates'], function(index, value) {
					if (value.indexOf('NEW') === 0) {
						next_new_id++;
						add_templated({id: value}, true);
					} else {
						var entry = $('#' + id_prefix + value + '_DISPLAY');
						add_templated(entry.data('formValues'));
						$('#' + id_prefix + value + '_CONTAINER').hide();
					}
				});
			}
			if (cache[obj.id + '_deletes']) {
				$.each(cache[obj.id + '_deletes'], function(index, value) {
					do_delete(document.getElementById(id_prefix + value + '_ACTION'));
				});
			}
			if (cache[obj.id + '_restores']) {
				$.each(cache[obj.id + '_restores'], function(index, value) {
					do_restore_cancel.call(document.getElementById(id_prefix + value + '_RESTORECANCEL'));
				});
				parent.find('.EntryFormItemViewHidden').click();
			}

			if (cache[obj.id + '_cancels']) {
				var cancel_reason = cache[obj.id + '_cancel_reason'];
				$.each(cache[obj.id + '_cancels'], function(index, value) {
					do_cancel(document.getElementById(id_prefix + value + '_ACTION'), menu.find("li[data-cancel-type='" + cancel_reason[value] + "']"));
				});
				
			}
		};

		cache_register_onbeforerestorevalues(onbeforerestorevalues);
	});
};
window['init_entryform_notes'] = init_entryform_notes;
})();

