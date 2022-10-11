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

var $ = jQuery;
var add_new_community = function(chkid, display) {
	var existing_container = $('#CM_existing_add_container'),
		addon_label = existing_container.data('addonLabel');
	existing_container.
		append($('<div>').
			addClass('row-border-bottom').
			append($('<div>').
				addClass('row form-group').
				append($('<label>').
					addClass('control-label control-label-left col-md-4').
					prop({
						for: 'CM_ID_' + chkid,
					}).
					append($('<input>').
						prop({
							id: 'CM_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: 'CM_ID',
							value: chkid
							})
					).
					append(document.createTextNode(' ' + display))
				).
				append($('<div>').
					addClass('col-md-8 form-inline').
					append($('<div>').
						addClass('input-group').
						append($('<input>').
							addClass('form-control').
							prop({
								id: 'CM_NUM_NEEDED_' + chkid,
								name: 'CM_NUM_NEEDED_' + chkid,
								size: 3,
								maxlength: 3
							})
						).
						append($('<span>').
							addClass('input-group-addon').
							text(addon_label)
						)
					)

				)
			)
		);
};
var init_num_needed = function(txt_not_found){
	init_autocomplete_checklist($, {
		field: 'CM',
		source: entryform.community_complete_url,
		add_new_html: add_new_community,
		minLength: 3,
		txt_not_found: txt_not_found
		});
};
window['init_num_needed'] = init_num_needed;


})();
