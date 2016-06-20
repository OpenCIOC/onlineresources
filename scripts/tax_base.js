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
	var $ = jQuery,
	add_rows = function(parent_row) {
		return function(data) {
			parent_row.after(data.join(""));
		};
	},
	handle_plusminus_click = function(e) {
		var me = $(this);
		var parent_row = me.parents('tr').first();
		if (me.data('closed')) {
			//open
			var url = me.data('url');
			$.ajax({success: add_rows(parent_row), data: {LV: me.data('level') + 1}, dataType:'json', url:url});
			me.data('closed', false);
			me.find('img').prop('src', function(i, src) { return src.replace('plus', 'minus'); }); 
		} else {
			//close
			parent_classes = ['.TaxRowLevel' + me.data('level')];
			for (var i = 1; i < me.data('level'); i++) {
				parent_classes.push('.TaxRowLevel' + i);
			}
			parent_row.nextUntil(parent_classes.join(",")).remove();
			me.data('closed', true);
			me.find('img').prop('src', function(i, src) { return src.replace('minus', 'plus'); }); 
		}
	},

	add_term_detail = function(target) {
		return function(data) {
			if (data) {
				target.html('<div class="MoreTermInfo">' + data[0] + '</div>');
			}
		};
	},
	handle_term_click = function(e) {
		var me = $(this);
		var target = me.parents('td').first().find('.taxDetail');
		if (me.data('closed')) {
			//open
			var url = me.data('url');
			$.ajax({success: add_term_detail(target), dataType: 'json', url: url});
			me.data('closed', false);
		} else {
			//close
			target.empty();
			me.data('closed', true);
		}
	},

	sort_tax_table = function(e) {
		var me = $(this), which = me.data('which'), other = 1,
			state = me.data('state'), direction = 1, dirstring = "up";
		if (state === 'up') {
			direction = -1;
			dirstring = "down";
		}

		me.parents('tr').first().find('img').prop('src', function(index, val) {
			var prefix = val.substring(0, val.lastIndexOf('/')+1);
			var suffix = val.substring(val.lastIndexOf('.'));
			if (index === which) {
				return prefix + dirstring + suffix;
			} else {
				return prefix + 'noplusminus' + suffix;
			}
		});
		me.parents('tr').first().find('.taxHeaderSort').each(function(index, item) {
			if (index === which) {
				$(item).data('state', dirstring);
			} else {
				$(item).data('state', 'noplusminus');
			}
		});

		var sortfn = function (a, b) {
			var left = $(a).data('sortkey')[which].toUpperCase(),right= $(b).data('sortkey')[which].toUpperCase();
			if (left < right) { return (-1 * direction); }
			if (left > right) { return (1 * direction); }
			return 0;
		};

		var tbody = me.parents('table').first().find('tbody');
		var rows = tbody.find('tr').get();
		rows.sort(sortfn);

		$.each(rows, function(index, item) { tbody.append(item); });

	},activation_url = null,
	activation_base = {},

	tax_activations = function(action) {
		if (activation_url === null) {
			activation_url = $('#activations-table').data('url');
			activation_base = $('#activations-table').data('paramBase');
		}
		return function() {
			var self=$(this), tax_container = self.parent().find('span:first'), code=tax_container.data('taxcode');
			$.ajax({url: activation_url, type: 'POST', dataType: 'json', 
				data: $.extend({}, activation_base, {TC: code, action: self.data('action'), LV: tax_container.data('level') + 1}),
				success: function(data) {
					if (data.buttonstates) {
						$.each(data.buttonstates, function(index, value) {
							var code_item = $('#tax-code-' + value.code.replace(/\./, '-')), 
								tax_span = code_item.find('.taxExpandTerm').first();
							if (value.active === null) {
								code_item.find('.rollup-indicator').removeClass('hidden');
							} else {
								code_item.find('.rollup-indicator').addClass('hidden');
							}
							if (value.active) {
								tax_span.removeClass('TaxLinkInactive');
								tax_span.addClass('TaxLink');
							} else {
								tax_span.addClass('TaxLinkInactive');
								tax_span.removeClass('TaxLink');
							}

							if (value.activate) {
								code_item.find('.activate').removeClass('hidden');
							} else {
								code_item.find('.activate').addClass('hidden');
							}

							if (value.deactivate) {
								code_item.find('.deactivate').removeClass('hidden');
							} else {
								code_item.find('.deactivate').addClass('hidden');
							}

							if ( value.rollup ) {
								code_item.find('.rollup').removeClass('hidden');
							} else {
								code_item.find('.rollup').addClass('hidden');
							}
							
						});
					}

				},
				failure: function() {
				// XXX What will I do here?
				}
			});
		};
	};


	$(function() {
		$('#page_content').on('click',"span.taxPlusMinus", handle_plusminus_click).
		on('click', "span.taxExpandTerm", handle_term_click).
		on('click', ".taxHeaderSort", sort_tax_table).
		on('click', ".activate", tax_activations('activate')).
		on('click', ".deactivate", tax_activations('deactivate')).
		on('click', ".rollup", tax_activations('rollup'));
	});

	window['init_taxcode_autocomplete'] = function(url) {
		var input_el = $('#TC').autocomplete({
			focus:function(event,ui) {
				return false;
			},
			source: create_caching_source_fn($,url, 'value'),
			minLength: 1
		});

		input_el.data('autocomplete')._renderItem = function( ul, item ) {
			return $( "<li></li>" )
				.data( "item.autocomplete", item )
				.append( $( "<a></a>" ).text(item.value + ' - ' + item.label))
				.appendTo( ul );
		};
	};
})();
