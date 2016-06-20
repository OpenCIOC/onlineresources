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
/*global alert:true entryform:true get_form_values:true restore_form_values:true cache_register_onbeforeunload:true cache_register_onbeforerestorevalues:true
  default_cache_search_fn:true init_autocomplete_checklist:true create_caching_source_fn:true only_items_chk_add_html:true create_checklist_onbefore_fns:true make_required_group:true remove_required_group:true basic_chk_add_html:true
  */
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
					if (value.indexOf('NEW') === 0) {
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

function create_org_level_complete($, fields, caches) {
	var my_field = fields.pop();
	var my_cache = caches.shift();

	var source = create_caching_source_fn($,entryform.org_level_complete_url, my_cache, null,
			default_cache_search_fn($, my_cache, null, '^'));
	$(my_field).autocomplete({
			focus:function() {
				return false;
			},
			source: function(request, response) {
				var i;
				for (i = 0; i < fields.length; i++) {
					if (!fields[i].value || (my_cache[fields[i].name] && my_cache[fields[i].name].value && fields[i].value !== my_cache[fields[i].name])) {
						//response([]);
						delete my_cache.term;
						delete my_cache.content;
						for (var j = 0; j < fields.length; j++) {
							delete my_cache[fields[i].name];
						}
						if (!fields[i].value) {
							response([]);
							return;
						}
					}
					request[fields[i].name] = fields[i].value;
				}
				source(request, function(data) {
					for (i = 0; i < fields.length; i++) {
						my_cache[fields[i].name] = fields[i].value;
					}

					response(data);
				});
			},
			minLength: my_field.id.slice(-1) === 1 ? 5 : 3
		}).
	keypress(function (evt) {
			if (evt.keyCode === 13) {
				evt.preventDefault();
				$(my_field).autocomplete('close');
			}
		});

}
window['init_orglevels'] = function($) {

	var org_levels = $.makeArray($("#ORG_LEVEL_1, #ORG_LEVEL_2, #ORG_LEVEL_3, #ORG_LEVEL_4"));
	var caches = [];
	var i;
	for (i = 0; i < org_levels.length; i++) {
		caches.push({});
	}

	for (i = 0; i < org_levels.length; i++) {
		if (org_levels[i].name !== 'ORG_LEVEL_' + (i + 1)) {
			return;
		}

		create_org_level_complete($, $.makeArray(org_levels).slice(0, i+1), $.makeArray(caches).slice(i));

	}

// Service name 1 completes with matching ORG_Name
// service name 2 completes with matching location_name
	org_levels = $.makeArray($("#ORG_LEVEL_1, #ORG_LEVEL_2, #ORG_LEVEL_3, #ORG_LEVEL_4, #ORG_LEVEL_5, #ORG_NUM, #NUM, #SERVICE_NAME_LEVEL_1"));
	caches = [{}];
	if (!org_levels.length || org_levels[org_levels.length-1].name !== 'SERVICE_NAME_LEVEL_1') {
		return;
	}
	create_org_level_complete($, org_levels, caches);
};

window['init_areas_served'] = function($, txt_not_found) {
	var base_add_new_html = basic_chk_add_html($, 'CM');
	var add_new_html = function(chkid, display, label) {
		return base_add_new_html(chkid, label);
	};
	init_autocomplete_checklist($, {
			field:'CM',
			source: entryform.community_complete_url,
			minLength: 3,
			txt_not_found: txt_not_found,
			add_new_html: add_new_html
		});
};

window['init_inarea_schools'] = function($, txt_not_found) {
	init_autocomplete_checklist($, {field: 'INAREA_SCH', source: entryform.sch_source, txt_not_found: txt_not_found});
};

window['init_escort_schools'] = function($, txt_not_found) {
	init_autocomplete_checklist($, {field: 'ESCORT_SCH', source: entryform.sch_source, txt_not_found: txt_not_found});
};

window['init_distribution'] = function($, txt_not_found) {
	init_autocomplete_checklist($, {field: 'DST',
			source: entryform.dst_complete_url,
			add_new_html: only_items_chk_add_html($, 'DST'),
			match_prop: 'label',
			txt_not_found: txt_not_found
			});
};

window['init_busroutes'] = function($) {
	var added_values = [];
	var add_fn = function (chkid, display) {
		var existing_val = $('#BR_ID_' + chkid);
		if (existing_val.length) {
			existing_val[0].checked = true;
			return;
		}
		added_values.push({chkid: chkid, display: display});
		$('#BR_existing_add_table').
			append($('<tr>').
				append($('<td>').
					append($('<input>').
						prop({
							id: 'BR_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: 'BR_ID',
							value: chkid
							})
					).
					append(document.createTextNode(' ' + display))
				));
	};

	var new_br = $('#NEW_BR');
	$('#add_BR').click(function() {
			var value = new_br[0].value;
			var label = new_br.children('[value=' + value + ']').text();
			add_fn(value, label);
		});

	create_checklist_onbefore_fns ($, 'BR', added_values, add_fn);
};

window['init_subjects'] = function($, txt_not_found) {
	var show_subject_added_title = function() {
		$('#Subj_existing_add_title').removeClass('NotVisible');
	};
	init_autocomplete_checklist($, {field: 'Subj',
			source: entryform.subj_complete_url,
			add_new_html: only_items_chk_add_html(
				$, 'Subj', show_subject_added_title
			),
			txt_not_found: txt_not_found});
};

window['init_fees'] = function($) {
	var assistance_targets = $('#FEE_ASSISTANCE_FOR, #FEE_ASSISTANCE_FROM'),
		disable_fee_assistance = function() {
			assistance_targets.prop('disabled', !$(this).prop('checked'));
		};
	$('#FEE_ASSISTANCE_AVAILABLE').click(disable_fee_assistance).each(disable_fee_assistance);
};

window['init_org_num'] = function($) {
	$('#FIELD_ORG_NUM').next().on('click', '.suggested-num', function() {
		$('#ORG_NUM').val(this.value).trigger('change');
		
		return false;
	});
};

window['init_locations_services'] = function($, txt_invalid_record) {
	var new_entry_template_template = '<li><label><input type="checkbox" name="[FIELD]" value="[VALUE]" id="[FIELD]_[VALUE]" checked> [VALUE]</label></li>',
	create_locations_services_widget = function (loc_services_list, field, needs_ols_type) {
		var new_entry_template = new_entry_template_template.replace(/\[FIELD\]/g, field),
		add_locations_services_container = loc_services_list.siblings('.locations-services-new-container'),
		new_value_el = add_locations_services_container.find('.locations-services-new'),
		add_location_services_button = add_locations_services_container.find('.locations-services-add'),
		suggestions_container = loc_services_list.siblings('.locations-services-list-suggestions'),
		ols_checkbox = $(needs_ols_type),
		onbeforeunload = function(cache) {
			cache[field + '_STATE'] = loc_services_list.html();
		}, onbeforerestorevalues = function(cache) {
			var state = cache[field + '_STATE'];
			if (state){
				loc_services_list.html(state);
			}
		}, do_show_error = function() {
			if (!loc_services_list.siblings(".locations-services-error").length) {
				//console.log('error');
				$('<p>').
					hide().
					addClass('Alert').
					addClass('locations-services-error').
					append(document.createTextNode(txt_invalid_record)).
					insertBefore(add_locations_services_container).
					show('slow');
			}
		}, add_new_entry = function(new_value) {
				var existing_el = $('#' + field + '_' + new_value), new_entry;
				if (existing_el.length) {
					existing_el[0].checked = true;
				} else {
					new_entry = new_entry_template.replace(/\[VALUE\]/g, new_value);
					loc_services_list.append($(new_entry));
				}
		};

		if(loc_services_list.length) {
			cache_register_onbeforeunload(onbeforeunload);
			cache_register_onbeforerestorevalues(onbeforerestorevalues);
		}

		add_locations_services_container.on('click', '.locations-services-add', function() {
			var new_value = $.trim(new_value_el[0].value);
			if (new_value) {
				if (!/^[A-Z]{3}[0-9]{4,5}$/.test(new_value)) {
					do_show_error();
					return false;
				}

				add_new_entry(new_value);

				loc_services_list.siblings('.locations-services-error').hide('slow', function() {
					$(this).remove();
				});
				new_value_el[0].value = '';
			}

			return false;
		}).on('keypress', '.locations-services-new', function(evt) {
			if (evt.keyCode === 13) {
				evt.preventDefault();
				add_location_services_button.trigger('click');
			}
		});

		suggestions_container.on('click', '.locations-services-suggestion', function(evt) {
			evt.preventDefault();
			add_new_entry(this.value);
			return false;
		});

		if (!ols_checkbox.length) { // || ols_checkbox.attr('disabled') || loc_services_list.children().length) {
			return;
		}

		// Handle dynamically showing hiding location services
		var my_table_row = loc_services_list.parents('tr').first(),
		on_ols_checkbox_clicked = function() {
			var self = $(this), other;
			if (this.checked) {
				my_table_row.show();
				if (self.data('maybeRequired')) {
					if (self.is('.ols-type-TOPIC,.ols-type-SERVICE')) {
						if (self.is('.ols-type-TOPIC')) {
							other = $('.ols-type-SERVICE');
						} else {
							other = $('.ols-type-TOPIC');
						}

						if (other.prop('checked')) {
							if (other.prop('disabled')) {
								other.prop('disabled', false);
								$('#OLS_ID_' + other.prop('value') + '_forceon').remove();
							}
							if (this.disabled) {
								this.disabled = false;
								$('#OLS_ID_' + this.value + '_forceon').remove();
							}
						} else {
							if (!this.disabled) {
								this.disabled = true;
								self.parent().after($('<input type="hidden" name="OLS_ID" id="OLS_ID_' + this.value + '_forceon" value="' + this.value + '">'));
							}
						}
					} else {
						if (!this.disabled) {
							this.disabled = true;
							self.parent().after($('<input type="hidden" name="OLS_ID" id="OLS_ID_' + this.value + '_forceon" value="' + this.value + '">'));
						}
					}
				}
			} else {
				if (self.is('.ols-type-SITE')) {
					my_table_row.hide();
				} else if (!$( self.is('.ols-type-SERVICE') ? '.ols-type-TOPIC' : '.ols-type-SERVICE').prop('checked')) {
					my_table_row.hide();
				}
				if (self.data('maybeRequired')) {
					if (self.is('.ols-type-TOPIC,.ols-type-SERVICE')) {
						this.disabled = false;
						if (self.is('.ols-type-TOPIC')) {
							other = $('.ols-type-SERVICE');
						} else {
							other = $('.ols-type-TOPIC');
						}
						if (other.prop('checked')) {
							var value = other.prop('value');
							if (!other.prop('disabled')) {
								other.prop('disabled', 'true');
								other.parent().after($('<input type="hidden" name="OLS_ID" id="OLS_ID_' + value + '_forceon" value="' + value + '">'));
							}
						} else {
							$('#ols-type-SERVICE-warning').show();
						}
					}
				}
			}
		};
		ols_checkbox.click(on_ols_checkbox_clicked);
		setTimeout(function() {
			ols_checkbox.each(function(i, el) {
				on_ols_checkbox_clicked.call(el);
			});
		}, 1);

	};

	$('.locations-services-list').each(function() {
		var self = $(this), field_name = self.data('fieldName'), needs_ols_type = self.data('needsOlsType');
		create_locations_services_widget(self, field_name, needs_ols_type);
	});
};

if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement, fromIndex) {
      if ( this === undefined || this === null ) {
        throw new TypeError( '"this" is null or not defined' );
      }

      var length = this.length >>> 0; // Hack to convert object.length to a UInt32

      fromIndex = +fromIndex || 0;

      if (Math.abs(fromIndex) === Infinity) {
        fromIndex = 0;
      }

      if (fromIndex < 0) {
        fromIndex += length;
        if (fromIndex < 0) {
          fromIndex = 0;
        }
      }

      for (;fromIndex < length; fromIndex++) {
        if (this[fromIndex] === searchElement) {
          return fromIndex;
        }
      }

      return -1;
    };
}

window['init_name_editable_toggle'] = function(defaults) {
	var org_num=$('#ORG_NUM'), display_org_name=$('#DISPLAY_ORG_NAME');
	var check_disable_org_names = function() {
		if ((org_num.length && !org_num.val()) || (!org_num.length && !defaults.org_num)) {
			display_org_name.prop('disabled', true);
			return false;
		}
		display_org_name.prop('disabled', false);
		return (display_org_name.length && display_org_name.prop('checked')) || (!display_org_name.length && defaults.display_org_name);
	};
	var disable_other = function(targets) {
		return function(toggle_trigger) {
			var not_display_org_name = toggle_trigger.not('#DISPLAY_ORG_NAME');

			var checked_triggers = not_display_org_name.filter(':checked');
			if (!not_display_org_name.length) {
				checked_triggers = $.map(targets, function(val) { return defaults[val] ? val : null; });
			}
			if (!checked_triggers.length) {
				return true;
			}

			if (not_display_org_name.length) {
				if (checked_triggers.is(':not(.ols-type-TOPIC)')) {
					return false;
				}
			} else {
				if ($.map(checked_triggers, function(val) { return val === 'TOPIC' ? null: val; }).length) {
					return false;
				}
			}
			
			// only ols-type-TOPIC disable if not display org name
			var retval = !check_disable_org_names();
			return retval;
		};
	};
	var after_location_site_names = function() {
		var first=true,
		after_disable_function = function(disabled, toggle_items) {
			if (first) {
				toggle_items.each(function() {
					var self = $(this);
					self.data('was_required', self.hasClass('require-group'));
				});
				first = false;
			}

			toggle_items.each(function() {
				var self = $(this);
				if (self.data('was_required')) {
					var parent = self.parents('td[data-field-display-name]');
					if (disabled) {
						remove_required_group(parent);
					} else {
						make_required_group(parent);
					}
				}
			});
		};
		return after_disable_function;
	};
	var register_toggle_events = function(toggle_trigger, toggle_items, check_fn, after_fn) {
		var toggle;

		toggle_trigger = $(toggle_trigger);
		toggle_items = $(toggle_items);
		toggle = function() {
			var disabled = check_fn(toggle_trigger);
			toggle_items.prop('disabled', disabled);
			if (after_fn) {
				after_fn(disabled, toggle_items);
			}
		},
		toggle_trigger.on('click keyup change', toggle);
		toggle();
	};

	register_toggle_events('#DISPLAY_ORG_NAME,#ORG_NUM', '#ORG_LEVEL_1,#ORG_LEVEL_2,#ORG_LEVEL_3,#ORG_LEVEL_4,#ORG_LEVEL_5', check_disable_org_names);
	register_toggle_events('.ols-type-SITE', '#LOCATION_NAME', disable_other(['SITE']), after_location_site_names());
	register_toggle_events('.ols-type-SERVICE,.ols-type-TOPIC,#DISPLAY_ORG_NAME', '#SERVICE_NAME_LEVEL_1,#SERVICE_NAME_LEVEL_2', disable_other(['SERVICE','TOPIC']), after_location_site_names());

};

})();
