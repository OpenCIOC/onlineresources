(function () {

	var $ = jQuery;

	var init_interests = function (txt_not_found, interest_complete_url) {
		var added_values = [];
		var add_item_fn = only_items_chk_add_html($, 'AI');
		init_autocomplete_checklist($, {
			field: 'AI',
			source: interest_complete_url,
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
				append($($.map(data, function (item, index) {
					var el = $('<li>').append(
						$('<label>').append(
							$('<input>').
								prop({
									type: 'checkbox',
									value: item.chkid
								}).
								data('cioc_chk_display', item.value)
						).
							append(document.createTextNode(' ' + item.value)
							)
					)[0];
					return el;
				})));


			ai_list.show('slow');
			if (ai_list_old.length) {
				ai_list_old.hide('slow', function () {
					ai_list_old.remove();
				});
			}


		};
		interest_group = $('#InterestGroup').
			change(function () {
				$.getJSON(interest_complete_url,
					{ IGID: interest_group.prop('value') },
					update_interest_list);
			});


		$("#FIELD_INTERESTS").next().on('click', "#AreaOfInterestList input:checkbox",
			{ added_values: added_values, add_item_fn: add_item_fn }, function (event) {
				var me = $(this);
				var existing_chk = document.getElementById('AI_ID_' + this.value);
				if (existing_chk) {
					existing_chk.checked = true;
				} else {

					var display = me.data('cioc_chk_display');

					event.data.added_values.push({ chkid: this.value, display: display });
					event.data.add_item_fn(this.value, display);
				}

				me.parent().parent().hide('slow', function () { me.remove(); });

			});
	};
	window['init_interests'] = init_interests;

})();
