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

(function($) {
var admin_chk_add = function(field, fndisplay) {
	return function (chkid, display) {
		display = fndisplay(chkid, document.createTextNode(display))
		$('#' + field + '_existing_add_container').
			append($('<label>').
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
				append('&nbsp;').
				append(display)
			).append($('<br>'));
	};
}
var init_checklist_mgr = function(field, url, fndisplay, txt_not_found) {
	init_autocomplete_checklist($, {field: field,
			source: url,
			add_new_html: admin_chk_add(field, fndisplay),
			txt_not_found: txt_not_found
			});
};

window['init_publication_checklist'] = function(pub_complete_url, txt_not_found) {
	init_cached_state();
	init_checklist_mgr('PUB', pub_complete_url, function(chkid, display) { return display; }, txt_not_found);
	init_checklist_mgr('ADDPUB', pub_complete_url, function(chkid, display) { return display; }, txt_not_found);
	restore_cached_state();
};

window['init_subject_checklist'] = function(subject_complete_url, subject_edit_url, txt_not_found) {
	var fndisplay = function(chkid, display) {
		//console.log(display)
		return $('<a>').
				prop('href', subject_edit_url.replace(/IDIDID/g, chkid.toString())).
				append(display);
	};

	init_cached_state();
	init_checklist_mgr('UseSubj', subject_complete_url, fndisplay, txt_not_found)
	init_checklist_mgr('BroaderSubj', subject_complete_url, fndisplay, txt_not_found)
	init_checklist_mgr('RelatedSubj', subject_complete_url, fndisplay, txt_not_found)

	restore_cached_state()

};
})(jQuery);
