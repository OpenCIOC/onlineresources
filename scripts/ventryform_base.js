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
	$('#CM_existing_add_table').
		removeClass('NotVisible').
		append($('<tr>').
			append($('<td>').
				append($('<input>').
					prop({
						id: 'CM_ID_' + chkid,
						type: 'checkbox',
						checked: true,
						defaultChecked: true,
						name: 'CM_ID',
						value: chkid
						})
				)
			).
			append($('<td>').
				addClass('FieldLabelLeftClr').
				append(document.createTextNode(' ' + display))
			).
			append($('<td>').
				prop('align', 'center').
				append($('<input>').
					prop({
						id: 'CM_NUM_NEEDED_' + chkid,
						name: 'CM_NUM_NEEDED_' + chkid,
						size: 3,
						maxlength: 3
						})
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

var init_interests = function(txt_not_found) {
	var added_values = [];
	var add_item_fn = only_items_chk_add_html($, 'AI');
	init_autocomplete_checklist($, {field: 'AI',
			source: entryform.interest_complete_url,
			add_new_html: add_item_fn,
			added_values: added_values,
			txt_not_found: txt_not_found
	});

	var interest_group;
	var update_interest_list = function (data) {
		var ai_list_old = $("#AreaOfInterestList");
		if (ai_list_old.length) {
			ai_list_old.prop('id', 'AreaOfInterestListOld');

		}
		var ai_list = $('<ul>').hide().
			insertAfter(interest_group).
			prop('id', 'AreaOfInterestList').
			append($($.map(data, function(item, index) {
					var el =  $('<li>').append(
						$('<input>').
							prop({
							type: 'checkbox',
							value: item.chkid
								}).
							data('cioc_chk_display', item.value)
						).
						append(document.createTextNode(' ' + item.value))[0];
					return el;
					})));


		ai_list.show('slow');
		if (ai_list_old.length) {
			ai_list_old.hide('slow', function ()
						{
							ai_list_old.remove();
						});
		}


	};
	interest_group = $('#InterestGroup').
		change(function() {
			$.getJSON(entryform.interest_complete_url,
				{IGID: interest_group.prop('value')},
				update_interest_list);
		});


	$("#FIELD_INTERESTS").next().on('click', "#AreaOfInterestList input:checkbox",
		{added_values: added_values, add_item_fn: add_item_fn}, function (event) {
			var me = $(this);
			var existing_chk = document.getElementById('AI_ID_' + this.value);
			if (existing_chk) {
				existing_chk.checked = true;
			} else {

				var display = me.data('cioc_chk_display');

				event.data.added_values.push({chkid: this.value, display: display});
				event.data.add_item_fn(this.value, display);
			}

			me.parent().hide('slow',function () { me.remove(); });

		});
};
window['init_interests'] = init_interests;

})();
