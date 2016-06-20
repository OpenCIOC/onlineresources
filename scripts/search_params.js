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

/*global restore_form_values:true get_advsrch_checklist */
(function() {
	var urlParams;
	(function () {
		var match,
			pl = /\+/g,  // Regex for replacing addition symbol with a space
			search = /([^&=]+)=?([^&]*)/g,
			decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
			query = window.location.search.substring(1);

		urlParams = {};
		while ((match = search.exec(query)) !== null) {
			var name = decode(match[1]);
			if (!urlParams[name]) {
				urlParams[name] = [];
			}
			urlParams[name].push(decode(match[2]));
		}
	})();
	if (urlParams['SearchParameterKey']) {
		jQuery(function($) {
			var td_selector = 'form > table > tbody > tr > td, .field-data-cell';
			var fields_selector = 'input[name],textarea[name],select[name]';
			var update_info_for_td = function(td) {
				var container = td.find('.HighLight.SearchParamKey');
				if (!container.length) {
					container = $('<div class="HighLight SearchParamKey"></div>').prependTo(td);
				}
				var val = td.find(fields_selector).not(function(){ return !this.value; }).serialize() || '';
				container.text(val);
			};

			var update_all = function() {
				$(td_selector).has(fields_selector).each(function() {
					update_info_for_td($(this));
				});
			};
			
			$('form > table, .form-table').on('change keyup click', fields_selector, function() {
				update_info_for_td($(this).parents(td_selector));
			});

			$(document).on('click', 'input[type=reset]', function() {
				setTimeout(update_all, 1);
			});

			update_all();
		});
	}

	window['init_pre_fill_search_parameters'] = function(url, communityfield, communityidfield) {
		var $ = jQuery;
		var cache_dom = document.getElementById('cache_form_values');
		var display, chkid;
		if (cache_dom && cache_dom.value) {
			return;
		}
		var restore_values = function() {
			$('form').has('> table, .auto-fill-table').each(function() {
				restore_form_values(this, urlParams);
			});

			if (communityfield && communityidfield) {
				communityfield = $(communityfield);
				communityidfield = $(communityidfield);
				if (communityfield.length && communityidfield.length) {
					display = urlParams[communityfield[0].name];
					chkid = urlParams[communityidfield[0].name];
					if (display && chkid) {
						communityfield.data({
							chkid: chkid[0],
							display: display[0]
						});
					}
				}
			}
		};
		if (urlParams) {
			var deferreds = [];
			var chklst_src = $('#CheckListSource');
			if (urlParams['CHKLOAD'] && chklst_src.length && window['get_advsrch_checklist']) {
				$.each(urlParams['CHKLOAD'], function(idx, val) {
					if ($('#Chk' + val).length) {
						deferreds.push(get_advsrch_checklist(url, val, chklst_src));
					}
				});

				$.when.apply(null, deferreds).then(restore_values);
			} else {
				restore_values();
			}
		}
	};
})();
