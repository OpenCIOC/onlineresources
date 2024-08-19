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
/*global cache_register_onbeforerestorevalues:true cache_register_onbeforeunload:true initialize_vacancy_ui:true*/
	var init_grouped_quicklist = function(any_value_txt) {
		$('.fix-group-single option').each(function() {
			var group = $(this).data('group');
			if (group) {
				this.value = group;
			}
		});
		$('.fix-group-multi').each(function() {
			var self = $(this), group = self.data('group');
			if (group) {
				$('<option>').attr('value',group).data('group', group).insertAfter(self.find('option:first')).text(any_value_txt);


			}
		});
		$('#page_content').on('change', '.fix-group-single, .fix-group-multi', function() {
			var basename = this.name.replace('_GRP', ''), selected = $(this).find('option:selected');
			if (selected.data('group')) {
				this.name = basename + '_GRP';
			} else {
				this.name = basename;
			}

		});

		cache_register_onbeforeunload(function(cache) {
			var quicklist = {};
			$('.fix-group-single, .fix-group-multi').each(function() {
				quicklist[this.id] = this.name;
			});

			cache['QuickList'] = quicklist;
		});
		cache_register_onbeforerestorevalues(function(cache) {
			var quicklist = cache['QuickList'];
			if (!quicklist) {
				return;
			}
			$('.fix-group-single, .fix-group-multi').each(function() {
				var name = quicklist[this.id];
				if (name) {
					this.name = name;
				}
			});

		});

	};
	window['init_grouped_quicklist'] = init_grouped_quicklist;
})();
(function() {
/*global cache_register_onbeforeunload:true */
	var parseQueryParams = function(q, urlParams) {
		var e,
			a = /\+/g,  // Regex for replacing addition symbol with a space
			r = /([^&=]+)=?([^&]*)/g,
			d = function (s) { return decodeURIComponent(s.replace(a, " ")); };
		q = q || window.location.search.substring(1);

		urlParams = urlParams || {};

		/* double parens to indicated this is supposed to be an assignment and
		 * condition at the same time. Stops jshint warning */
		while ((e = r.exec(q))) {
			urlParams[d(e[1])] = d(e[2]);
		}
		return urlParams;
	}, init_bsearch_tabs = function(defaultParams, default_tab) {
		var tabs = $('.make-me-tabbed');
		var hash = window.location.hash;
		hash = /^#search-tab-(\d+)/.exec(hash);
		if (hash) {
			default_tab = parseInt(hash[1], 10);

		}

		if (tabs.length) {
			defaultParams.InlineMode = 'on';

			tabs.find('ul:first a').each(function(index, elem) {
					var href = $(elem).attr('href'), params = jQuery.extend({}, defaultParams);
					if (href[0] === '#') {
						return;
					}
					href = href.split('?');
					if (href.length > 1) {
						parseQueryParams(href[1], params);
						href = href[0];
					}
					if (params) {
						href = href + '?' + jQuery.param(params);
					}
					elem.href = href;

				});
			tabs.tabs({
				active: default_tab,
				beforeLoad: function( event, ui ) {
				if ( ui.tab.data( "loaded" ) ) {
					event.preventDefault();
					return;
				}

				ui.jqXHR.success(function() {
					ui.tab.data( "loaded", true );
				});
				},
				load: function() {
					initialize_vacancy_ui();
				},
				activate: function(event, ui) {
					if (google.maps.event.trigger) {
						var map = ui.newPanel.find('#map_canvas');
						if(map.length) {
							google.maps.event.trigger(map[0], 'resize');
						}
					}
				}
			}).css('overflow', 'auto');

			cache_register_onbeforeunload(function(cache) {
				cache['last_tab'] = tabs.tabs('option', 'selected');
			});
			cache_register_onbeforerestorevalues(function(cache) {
				if (cache['last_tab']) {
					tabs.tabs('option', 'selected', cache['last_tab']);
				}
			});

		}
	};
	window['init_bsearch_tabs'] = init_bsearch_tabs;
	window['init_placeholder_select'] = function() {
		var change = function() {
			var self = $(this);
			self.toggleClass('placeholder', !self.val());
		};
		$('.check-placeholder').on('change', change).each(change);
	};
	window['init_bsearch_community_dropdown_expand'] = function(txt_select_a, comm_generator_url) {
		// There could be more than one community drop down but they will all have the same enabled value
		var enabled = $('.community-dropdown-expand').data('enableCommExpand') == 1;
		if (enabled) {
			$(document).on('change', '.community-dropdown-expand select', function() {
				var name = this.name;
				if (name.slice(-1) === "3") {
					// CMID3 is the last one inserted, no more are allowed
					return;
				}
				var self = $(this), expand=self.parent(), wrap=expand.parent(), value = self.val(),
					child_comm_type = self.find('option[value=' + value + ']').data('childCommunityType'),
					select_count = parseInt(expand.data('selectCount') || "0", 10);

				// remove drop downs that are lower than this one
				wrap.find('.community-dropdown-expand').map(function() {
					return parseInt($(this).data('selectCount') || "0", 10) > select_count ? this : null
				}).remove();

				if (!child_comm_type) {
					return;
				}
				if (value == self.find('option:first').prop('value')) {
					return;
				}

				$.getJSON(comm_generator_url, {CMID: value}, function(data) {
					var new_expand = expand.clone(), select = new_expand.find('select');
					new_expand.data('selectCount', select_count + 1);
					select.prop('name', 'CMID' + (select_count + 1)).prop('id', null).empty().append($('<option>').text(txt_select_a + " " + child_comm_type).prop('value', '').data('childCommunityType', null));
					$.each(data, function(idx, el) {
						$("<option>").text(el.label).prop('value', el.chkid).data('childCommunityType', el.child_community_type).appendTo(select);
					});
					new_expand.appendTo(wrap);
				});

			});
		}
	};

	window['init_located_near_autocomplete'] = function($) {
		if (!(pageconstants && pageconstants.maps_key_arg)) {
			$('.cm-select option, input.cm-select').each(function() {
				var self = $(this);
				if (this.value == 'S' || this.value == 'L') {
					return;
				}
				if (this.tagName === 'input') {
					// TODO do we need to wrap the radio buttons with span/div and remve them all at once?
					self = self.parent();
				}
				self.remove();
			});
		}
		var change = function() {
			var self = $(this);
			var suffix = self.data('suffix');
			if (this.tagName == 'input') {
				self = $('.cm-select' + suffix + ':checked');
			}
			var value = self.val();
			if (value == 'L' || value == 'S') {
				$('#located-serving-community-wrap' + suffix).show();
				$('#located-near-wrap' + suffix).hide();
			} else {
				$('#located-serving-community-wrap' + suffix).hide();
				$('#located-near-wrap' + suffix).show();
			}
		};

		$('input.cm-select').on('change', change);
		$('select.cm-select').on('change', change);

		var selectors = $('input.cm-select:checked, select.cm-select');
		if (window.pageconstants && window.pageconstants.maps_key_arg) {
			selectors.each(function(){
				$('.cmtype-located-near').show();
				var self = $(this);
				var suffix = self.data('suffix');
				var autocomplete_input = $('#GeoLocatedNearAddress' + suffix).on('keypress', function(evt) {
					if (evt.keyCode == '13') {
						evt.preventDefault();
					}
				}).on('paste keyup', function() {
					if(!$.trim(this.value)) {
						$('#LATITUDECommunity' + suffix).val('');
						$('#LONGITUDECommunity' + suffix).val('');
					}
				});
				var geocoder = null;
				var form = autocomplete_input.parents('form').submit(function(evt) {
					if (autocomplete_input.data('last-location') == autocomplete_input.val() || !$.trim(autocomplete_input.val())) {
						return;
					}
					if (!google) {
						return;
					}
					if (!geocoder) {
						geocoder = new google.maps.Geocoder();
					}
					evt.preventDefault()
					console.log('geocode')
					geocoder.geocode({address: autocomplete_input.val()}, handle_geocode(function(results, status) {
						if (! results) {
							alert(get_response_message(status));
						} else {
							$('#LATITUDECommunity' + suffix).val(Globalize.format(results.lat(), 'n6'));
							$('#LONGITUDECommunity' + suffix).val(Globalize.format(results.lng(), 'n6'));
							autocomplete_input.data('last-location', autocomplete_input.val())
							form.submit();
						}
					}));
				});
				initialize_maps(pageconstants.culture, pageconstants.maps_key_arg, function() {
					var autocomplete = new google.maps.places.Autocomplete(autocomplete_input[0]);
					autocomplete.addListener('place_changed', function() {
						var place = autocomplete.getPlace();
						if (!place.geometry) {
							$('#LATITUDECommunity' + suffix).val('');
							$('#LONGITUDECommunity' + suffix).val('');
							autocomplete_input.data('last-location', autocomplete_input.val())
							return;
						}
						$('#LATITUDECommunity' + suffix).val(Globalize.format(place.geometry.location.lat(), 'n6'));
						$('#LONGITUDECommunity' + suffix).val(Globalize.format(place.geometry.location.lng(), 'n6'));
						autocomplete_input.data('last-location', autocomplete_input.val())
					});
				}, true);
			})

		}
		selectors.each(change);
	};
})();
