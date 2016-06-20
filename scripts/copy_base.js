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

(function(){
/*global
	confirm:true
*/
var changeAutoAssign= function(autoBoxObj, newNUMObj, newNUMButtonObj) {
	if (autoBoxObj.checked) {
		newNUMObj.value='';
		newNUMObj.disabled=true;
		newNUMButtonObj.disabled=true;
	} else {
		newNUMObj.disabled=false;
		newNUMButtonObj.disabled=false;
	}
};
window['changeAutoAssign'] = changeAutoAssign;

var $ = jQuery;

var make_required = function(parents) {
	parents.find(':input').not('input[type="hidden"]').filter('[name]').addClass('require-group');
};

var remove_required = function(parents) {
	parents.find(':input').not('input[type="hidden"]').filter('[name]').removeClass('require-group');
};

window['make_required_group'] = make_required;
window['remove_required_group'] = remove_required;

var update_required = function(field, required) {
	var edit_field = field.parent().find('td[data-field-display-name]');
	var display_name = edit_field.data('fieldDisplayName');

	if (required) {
		field.text(display_name).append(' <span class="Alert">*</span>');
		make_required(edit_field);
	} else {
		field.text(display_name);
		remove_required(edit_field);
	}
};

var update_copy_form_required = function() {
	var org_level_2_field = $("#FIELD_ORG_LEVEL_2");
	if (!org_level_2_field.length) {
		return;
	}

	var required = $("#RECORD_TYPE").find(":selected").data('progorbranch');
	update_required(org_level_2_field, required);
};

var update_form_make_required_org_level = function() {
	var orglvl;
	for (var i = 0; i < 6; i++) {
		orglvl = $('#FIELD_ORG_LEVEL_' + i);
		if (orglvl.length) {
			update_required(orglvl, true);
			return;
		}
	}

};
window['update_form_make_required_org_level'] = update_form_make_required_org_level;

var init_client_validation = function(selector, txt_validation_error) {
	var form = $(selector), culture = form.prop('lang') || form.parents('[lang]').first().prop('lang') || 'en-CA';

	var checkable = function(element) {
		return (/radio|checkbox/i).test(element.type);
	};
	/*
	var idOrName = function(element) {
		return this.checkable(element) ? element.name : element.id || element.name;
	};
	*/
	var not_all_empty = function(elements) {
		var one_not_empty = false;
		try {
			elements.each(function() {
				if (!this.name) {
					return;
				}
				if (checkable(this)) {
					if (this.checked && this.value) {
						one_not_empty = true;
						throw { name: 'StopIteration', message:'StopIteration'};
					}
					return;
				}
				if ($.trim(this.value)) {
					one_not_empty = true;
					throw { name: 'StopIteration', message:'StopIteration'};
				}
			});

		} catch (e) {
			if (e.name !== 'StopIteration') {
				throw e;
			}
		}

		return one_not_empty;
	};

	var email_regex = null;
	$.validator.addMethod('email', function(value, element) {
		if (!email_regex) {
			var one_email = "([A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+(\\.[A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+)*@[A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+(\\.[A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+)*)";
			var many_email = "^((" + one_email + "(\\s*,*\\s*))*)$";
			//email_regex = /^([A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*@[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*)$/

			email_regex = new RegExp(many_email);

		}
		return this.optional(element) || email_regex.test(value);

	});
	var url_regex = null;
	$.validator.addMethod('url', function(value, element) {
		if (!url_regex) {
			url_regex = /^((\d{1,3}(\.\d{1,3}){3})|([\w_\-]+(\.[\w\._\-]+)*)(:[0-9]+)?((\/|\?)[^\s]*)?)$/;
		}
		return this.optional(element) || url_regex.test(value);

	});
	var protourl_regex = null;
	$.validator.addMethod('protourl', function(value, element) {
		if (!protourl_regex) {
			protourl_regex = /^(https?:\/\/)?((\d{1,3}(\.\d{1,3}){3})|([\w_\-]+(\.[\w\._\-]+)*)(:[0-9]+)?((\/|\?)[^\s]*)?)$/;
		}
		return this.optional(element) || protourl_regex.test(value);

	});
	var posint_regex = null;
	$.validator.addMethod('posint', function(value, element) {
		if (!posint_regex) {
			posint_regex = /^\d+$/;
		}
		return this.optional(element) || posint_regex.test(value);

	});
	var posdbl_regex = null;
	$.validator.addMethod('posdbl', function(value, element) {
		if (!posdbl_regex) {
			var sep = '\\.';
			if (culture === 'fr-CA') {
				sep = ',';
			}
			posdbl_regex = new RegExp("^((\\d+)|(\\d*" + sep + "\\d+))$");
		}
		return this.optional(element) || posdbl_regex.test(value);

	});
	var num_regex = null;
	$.validator.addMethod('record-num', function(value, element) {
		if (!num_regex) {
			// XXX limit to specific num length?
			num_regex = /^[A-Z]{3}[0-9]{4,5}$/;
		}
		return this.optional(element) || num_regex.test(value);

	});

	$.validator.addMethod('unique', function(value, element, params) {
		if (!value) {
			return true;
		}
		value = string_ci_ai(value);
	    var prefix = params;
		var selector = jQuery.validator.format("[name!='{0}'][unique='{1}']", element.name, prefix);
		var matches = new Array();
		$(selector).each(function(index, item) {
			if (value == string_ci_ai($(item).val())) {
				matches.push(item);
			}
		});

		return matches.length == 0;	
	}, 'A unique value is required.');

	$.validator.addMethod('require-group', function(value, element) {
		var module = $(element).parents('td[data-field-display-name]');

		var fieldname = module.parent().children('td:first').prop('id');
		fieldname = fieldname.slice(-(fieldname.length - 6));
		var fields = module.find(':input').not('[type=hidden]').not('button');
		// alterations to field list
		switch(fieldname) {
			case 'ACCESSIBILITY':
			case 'AREAS_SERVED':
			case 'LANGUAGES':
			case 'FUNDING':
			case 'SCHOOL_ESCORT':
			case 'SCHOOLS_IN_AREA':
			case 'TYPE_OF_CARE':
				fields = fields.not("input:text");
				break;

			case 'ALT_ORG':
			case 'LEGAL_ORG':
				fields = fields.not("input:checkbox");
				break;

			case 'FORMER_ORG':
				fields = fields.not("input:checkbox").not("[name^=FORMER_ORG_DATE]");
				break;

			case 'FEES':
				fields = fields.not("input:text").add('#FEE_ASSISTANCE_FOR, #FEE_ASSISTANCE_FROM');
				break;

			case 'VACANCY_INFO':
				fields = fields.filter("[name!=VUT_ID]");
				break;
		}

		var result = not_all_empty(fields);
		if (result) {
			module.children('div.required-notice').hide();
		}/* else {
			module.find("label[for='" + this.idOrName(element) + "']").remove();
		}*/
		return result;

	}, "Field Required");

	var errorsDialog = $('<div id="a_test"></div>').dialog({
		autoOpen: false,
		title: txt_validation_error,
		closeOnEscape: false,
		position: ['right', 'bottom'],
		resizable: false,
		//width: 200,
		//height: 200,
		dialogClass: 'ValidationErrors'
		});
	var errorsNotice = $('#validation_error_box');

	$(document).on('click', '.FieldErrorJump', function(e) {
				var target = e.currentTarget;
				var field = $(target).prop('fieldname');
				var td = document.getElementById(field);
				if (td) {
					td.scrollIntoView(true);
				}
			});
	$(".ValidationErrors.ui-dialog").css({position: "fixed"}).position({my: 'right bottom', at: 'right bottom', of: window});

	make_required($(selector).find('td[data-field-required]'));

	var validator = $(selector).validate({
			ignore: 'input[type=hidden]',
			ignoreTitle: true,
			errorPlacement: function(error,element) {
				var require_container = [];
				var el = element[0];
				var module = null;
				if (element.hasClass('require-group')) {
					module = element.parents('td[data-field-display-name]');
					require_container = module.children('div.required-notice');
					var empty = false;
					if (checkable(el)) {
						if (!(el.checked && el.value)) {
							empty = true;
						}
					} else if (!$.trim(el.value)) {
						empty = true;
					}
					if (empty) {

						if (require_container.length) {
							require_container.empty();
							require_container.show();
							require_container.append(error);
						} else {
							error.removeAttr('for');

							module.prepend($('<div class="required-notice"></div>').append(error));
						}
						return;
					}
				}
				if (require_container.length) {
					require_container.hide();
				}
				error.insertAfter(element);
			},

			showErrors: function(errorMap, errorList) {
				this.defaultShowErrors();
				if (errorList.length === 0) {
					errorsDialog.dialog('close');
					errorsNotice.hide('slow');
					return;
				}

				var field_map = {};
				var container = $('<ul>');
				jQuery.each(errorList, function(index,el) {
						el = el.element;
						var module = $(el).parents('td[data-field-display-name]');
						var fieldname = module.parent().children('td:first').prop('id');
						if (field_map[fieldname]) {
							return;
						}
						field_map[fieldname] = true;
						container.append($('<li>').append($('<span>').prop({fieldname: fieldname, 'className': 'FieldErrorJump SimulateLink'}).text(module.data('fieldDisplayName'))));

					});
				errorsDialog.empty().append(container);

				errorsDialog.dialog('open');
				errorsNotice.show('slow');
				$('#SUBMIT_BUTTON').prop('disabled', false);

			},
			focusInvalid: false, onfocusout: false,
			onkeyup: false, onclick: false


		});

	if (culture === 'fr-CA') {
		jQuery.extend(jQuery.validator.messages, {
			/* default messages */
			required: "Ce champ est requis.",
			remote: "Veuillez remplir ce champ pour continuer.",
			email: "Veuillez entrer une adresse email valide.",
			url: "Veuillez entrer une URL valide.",
			date: "Veuillez entrer une date valide.",
			dateISO: "Veuillez entrer une date valide (ISO).",
			number: "Veuillez entrer un nombre valide.",
			digits: "Veuillez entrer (seulement) une valeur num\u00e9rique.",
			creditcard: "Veuillez entrer un num\u00e9ro de carte de cr\u00e9dit valide.",
			equalTo: "Veuillez entrer une nouvelle fois la m\u00eame valeur.",
			accept: "Veuillez entrer une valeur avec une extension valide.",
			maxlength: jQuery.validator.format("Veuillez ne pas entrer plus de {0} caract\u00e8res."),
			minlength: jQuery.validator.format("Veuillez entrer au moins {0} caract\u00e8res."),
			rangelength: jQuery.validator.format("Veuillez entrer entre {0} et {1} caract\u00e8res."),
			range: jQuery.validator.format("Veuillez entrer une valeur entre {0} et {1}."),
			max: jQuery.validator.format("Veuillez entrer une valeur inf\u00e9rieure ou \u00e9gale \u00e0 {0}."),
			min: jQuery.validator.format("Veuillez entrer une valeur sup\u00e9rieure ou \u00e9gale \u00e0 {0}."),

			/* new messages */
			protourl: "Veuillez entrer une URL valide.",
			posint: 'Veuillez entrer un nombre positif.',
			posdbl: 'Veuillez entrer un nombre positif.',
			'record-num': 'Please enter a valid record number.',
			'require-group': 'Ce champ est requis.',
			unique: 'Une valeur unique est requise.'

		});
	} else {
		jQuery.extend(jQuery.validator.messages, {
			/* new messages */
			protourl: "Please enter a valid URL.",
			posint: 'Please enter a positive number.',
			posdbl: 'Please enter a positive number.',
			'record-num': 'Please enter a valid record number.',
			'require-group': 'Field Required.',
			unique: 'A unique value is required.'
		});
	}

	return validator;
};
window['init_client_validation'] = init_client_validation;


var init_record_type_form = function(num, url, org_levels) {
	var last_record_type = null;
	var record_type_field_name = null;
	var record_type_form_cache = {};
	var fields = [
		'ORG_LEVEL_1', 'ORG_LEVEL_2', 'ORG_LEVEL_3', 'ORG_LEVEL_4',
		'ORG_LEVEL_5', 'LOCATION_NAME', 'SERVICE_NAME_LEVEL_1', 'SERVICE_NAME_LEVEL_2'
	];

	var onload = function() {
		$('#RecordTypeName').html(record_type_field_name);
		$.each(fields, function(field_name) {
			var org = org_levels[field_name];
			var field = $('#' + field_name);
			if (field.length) {
				field[0].value = org;
				if (org) {
					$('#' + field_name + '_DISPLAY').text(org);
					$('#HIDDEN_' + field).prop('value', org);
				}
			}
		});
		$("#RECORD_TYPE").prop('value', last_record_type[0].value);
		update_copy_form_required();

	};
	var onchange = function() {
		var oldoptval = last_record_type[0].value;
		if(!last_record_type.data('hasform')) {
			oldoptval = null;
		}

		last_record_type = $(this).find('option:selected');
		var newoptval = last_record_type[0].value;
		if(!last_record_type.data('hasform')) {
			newoptval = null;
		}
		if (newoptval !== oldoptval) {
			record_type_form_cache[oldoptval] = $('#copyFieldsForm').contents().detach();
			if (record_type_form_cache[newoptval]) {
				$('#copyFieldsForm').append(record_type_form_cache[newoptval]);
				$("#RECORD_TYPE").prop('value', last_record_type[0].value);
				return;
			}

			$('#copyFieldsForm').load(url + ' #copyFieldsInner', {'NUM': num, 'RT': newoptval || last_record_type[0].value},
				onload);
		} else {
			update_copy_form_required();
		}
	};

	jQuery(function() {
		record_type_field_name = $('#RecordTypeName').html();
		var rt = $('#RECORD_TYPE');

		$(document).on('change', '#RECORD_TYPE', onchange);

		last_record_type = rt.find('option:selected');

		update_copy_form_required();
	});

};

window['init_record_type_form'] = init_record_type_form;

var init_validate_duplicate_org_names = function(options) {
	var opt = $.extend({
		selector: '#EntryForm',
		fields: [
			'#ORG_LEVEL_1', '#ORG_LEVEL_2', '#ORG_LEVEL_3', '#ORG_LEVEL_4',
			'#ORG_LEVEL_5', '#LOCATION_NAME', '#SERVICE_NAME_LEVEL_1', '#SERVICE_NAME_LEVEL_2',
			'#OLS_SELECT input', '#ORG_NUM'
		].join(","),
		only_warn: true,
		num: null,
		org_levels: [],
		url: null // needs to be provided
	}, options), verrified_values = [], valid = opt.num !== null, error_types=[];

	var form = $(opt.selector).submit(function(event) {
		var i, val, changed=false,
			new_values = $(opt.fields).serializeArray();
		
		if (opt.num) {
			new_values.push({name: 'NUM', value: opt.num});
		}

		if (new_values.length !== verrified_values.length) {
			changed = true;
		} else {
			for (i=0; i < new_values.length; i++) {
				val = new_values[i];
				if (val.name !== verrified_values[i].name || val.value !== verrified_values[i].value) {
					changed = true;
					break;
				}
			}
		}

		if (!changed && valid) {
			return true; // continue with submit
		}

		var show_error = function() {
			// XXX show errors specfific to duplicate type
			if (opt.only_warn && confirm(opt.confirm_string)) {
				valid = true;
				$('#duplicate_name_error_box').hide();
				form.submit();
			} else {
				$('#SUBMIT_BUTTON').prop('disabled', false);
				$('#duplicate_name_error_box').show();
			}
		};

		event.stopPropagation();
		event.preventDefault();

		if (!changed) {
			// already checked if valid above,
			// so not changed implies error
			show_error();
			return false;
		}

		// There was a change in the values, check the server
		$.ajax({
			url: opt.url,
			dataType: 'json',
			method: 'get',
			data: new_values,
			success: function(result) {
				valid = true;
				error_types = [];
				for (var i = 0; i < result.length; i++) {
					valid &= result[i].count === 0;
					if (result[i].count !== 0) {
						error_types.push(result[i].type);
					}
				}
				verrified_values = new_values;
				if (valid) {
					$('#duplicate_name_error_box').hide();
					form.submit();
				} else {
					// error condition, show error
					show_error();
				}
			}
		});

		return false;
	});

};

window['init_validate_duplicate_org_names'] = init_validate_duplicate_org_names;
})();
