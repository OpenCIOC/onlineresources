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
window['entryform'] = window['entryform'] || {};

window['create_checklist_onbefore_fns'] = function($, field, added_values, add_new_value) {
	cache_register_onbeforeunload(function(cache) {
		cache[field + '_added'] = added_values;
	});
	cache_register_onbeforerestorevalues(function (cache) {
		var array = cache[field + '_added'];
		if (!array) {
			return;
		}
		$.each(array, function (index, item) {
			add_new_value(item.chkid, item.display, "");
		});
	});
};

window['basic_chk_add_html'] = function($, field) {
	return function (chkid, display) {
		var new_row = $('<tr>').
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: field + '_ID',
							value: chkid
							})
					).
					append(document.createTextNode(' ' + display))
				).
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_NOTES_' + chkid,
							name: field + '_NOTES_' + chkid,
							size: entryform.chk_notes_size,
							maxlength: entryform.chk_notes_maxlen
							})
					)
				);
		$('#' + field + '_existing_add_table').append(new_row);
		return new_row.find('input[type="checkbox"]')[0];
		
	};
};

var already_added_checklists = {};
var do_autocomplete_call = function(field) {
		$('#NEW_' + field).autocomplete(already_added_checklists[field]);
};
window['init_autocomplete_checklist'] = function($, options) {
	var field = options.field;

	if (already_added_checklists[field]) {
		do_autocomplete_call(field);
		return;
	}

	var source = options.source;
	options.minLength = options.minLength || 1;
	options.delay = options.delay || 300;
	options.add_new_html = options.add_new_html || basic_chk_add_html($, field);
	options.match_prop = options.match_prop || 'value';
	options.txt_not_found = options.txt_not_found || 'Not Found';

	var delegate_root = $(options.delegate_root || document);

	var added_values = options.added_values || [];
	var add_new_value = function(chkid, display, label) {
		//console.log('add');
		var existing_chk = document.getElementById(field + '_ID_' + chkid);
		if (existing_chk) {
			existing_chk.checked = true;
			if (options.after_add_new_value) {
				options.after_add_new_value.call(existing_chk);
			}
			//already exists
			return;
		}

		added_values.push({chkid: chkid, display: display, label: label});

		var new_chk = options.add_new_html(chkid, display, label);
		if (options.after_add_new_value) {
			options.after_add_new_value.call(new_chk);
		}

	};

	create_checklist_onbefore_fns($, field, added_values, add_new_value);

	var cache = {};

	var after_add = function(evt) {
		//console.log('after add');
		$('#NEW_' + field).
			data({chkid: "", display: "", label: ""}).
			prop('value', "").
			focus();

		$('#' + field + '_error').hide('slow', function() {
				$(this).remove();
		});
	};

	var look_for_value = null;
	var source_fn = null;
	(function (source) {
		var array, url;
		if ( $.isArray(source) ) {
			array = source;
			source_fn = function( request, response ) {
				// escape regex characters
				var matcher = new RegExp( $.ui.autocomplete.escapeRegex(string_ci_ai(request.term)));
				response( $.grep( array, function(value) {
					return matcher.test( string_ci_ai(value[options.match_prop] || value));
				}) );
			};
			look_for_value = function(invalue, response) {
				var inputvalue = string_ci_ai(invalue);
				var values = $.grep(array, function(value) {
							return string_ci_ai(string_ci_ai(value[options.match_prop] || value)) === inputvalue;
						});
				if (values.length === 1) {
					response(values[0]);
					return true;
				} else {
					response();
				}

			};
		} else if ( typeof source === "string" ) {
			url = source;
			source_fn = create_caching_source_fn($, url, cache, options.match_prop),
			look_for_value = function(invalue, response, dont_source) {
				var inputvalue = string_ci_ai(invalue);
				var content = cache.content;
				if (cache.content) {
					var values = $.grep(cache.content, function(value) {
								return string_ci_ai(value[options.match_prop]) === inputvalue;
							});
					if (values.length === 1) {
						response(values[0]);
						return;
					}
				}
				if (dont_source || string_ci_ai(cache.term || "") === inputvalue) {
					response();
					return;
				}

				source_fn({term: inputvalue}, function(data) {
							look_for_value(invalue, response, true);
						});
			};
		} else {
			source_fn = source;
			look_for_value = options.look_for_fn;
		}
	})(source);

	var do_show_error = function() {
		if ($("#" + field + "_error").length === 0) {
			//console.log('error');
			$('#' + field + '_new_input_table').before($('<p>').
					hide().
					addClass('Alert').
					prop('id', field + '_error').
					append(document.createTextNode(options.txt_not_found)));

			$("#" + field + "_error").show('slow');
		}
	};

	var on_add_click = function(evt) {
		//console.log('onclick');
		var newfield = $('#NEW_' + field);
		var chkid = newfield.data('chkid');
		var display = newfield.data('display');
		var label = newfield.data('label');
		var newfieldval = newfield[0].value;
		if (chkid && display && display == newfieldval) {
			add_new_value(chkid, display, label);
			after_add();
			return false;

		}
		look_for_value(newfield[0].value, function(item) {
			if (item) {
				add_new_value(item.chkid, item.value, item.label);
				after_add();
			} else {
				do_show_error();
			}
		});
		return false;

	};
	delegate_root.on('click', "#add_" + field, on_add_click);

	already_added_checklists[field] = {
		focus: function(e,ui) {
			return false;
		},
		source: source_fn,
		minLength: options.minLength,
		delay: options.delay,
		select: function(evt, ui) {
			$('#NEW_' + field).data({
				chkid: ui.item.chkid,
				display: ui.item.value,
				label: ui.item.label
				});
		}
	};

	delegate_root.on('keypress', '#NEW_' + field, function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				$('#NEW_' + field).autocomplete('close');
				$('#add_' + field).trigger('click');
			}
		});

	do_autocomplete_call(field);

};
window['init_languages'] = function($, txt_not_found) {
	var add_button = null, template = null, table = $('#LN_existing_add_table');
	var change_fn = function() {
		var self = $(this), entry = self.parents('.language-entry'), details = entry.find('.language-details-notes');
		if (this.checked) {
			details.slideDown();
		} else {
			details.slideUp();
		}
	}
	var options = {
		field: 'LN',
		source: entryform.languages_source,
		txt_not_found: txt_not_found,
		after_add_new_value: change_fn,
		add_new_html: function(chkid, display) {
			if (add_button === null) {
				add_button = $('#add_LN');
				template = add_button.data('newTemplate');
			}

			var html = template.replace(/LANGNAMELANGNAME/g, display).replace(/IDIDID/g, chkid);
			table.append(html);

		}

	};
	init_autocomplete_checklist($, options);
	table.on('change', '.language-primary', change_fn).uitooltip({
		items: '[data-help-text]',
		content: function() {
			var self = $(this);
			return '<div class="language-help-text">' + self.data('helpText') + "</div>";
		},
		position: {
			my: "center bottom-20",
			at: "center top",
			using: function( position, feedback ) {
			  $( this ).css( position );
			  $( "<div>" )
				.addClass( "arrow" )
				.addClass( feedback.vertical )
				.addClass( feedback.horizontal )
				.appendTo( this );
			}
		}
	});
	
	window['languages_check_state'] = change_fn;
	
};

})();
