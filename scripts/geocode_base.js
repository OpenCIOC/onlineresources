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

(function(status_messages) {
/*global google:true Globalize:true */
	var geocoder = null;
	var geocode_delay = 200;
	var geocode_type_target;
	var map_pin_target = null;
	var stateField = null;
	var types = null;
	var url = null;
	var status_messages;

	var get_num = function(row) {
		return row.id.substr('row_to_code_'.length);
	};

	var set_status_message = function(row, msg) {
		var num = get_num(row);
		var status_span = document.getElementById('status_' + num);
		status_span.innerHTML = msg;
		status_span.className = "";
	};

	var next_row = function(current_row) {
		stateField.value = current_row.rowIndex;
		var next = current_row.nextSibling;
		while (next && ( !/\bRowToCode\b/.test(next.className) ||
				next.nodeName.toLowerCase() !== 'tr' )) {
			next = next.nextSibling;
		}
		return next;
	};

	var cioc_postback = function(row, place, only_pin) {
		var num = get_num(row);
		set_status_message(row, status_messages['updating']);
		var geocode_type = geocode_type_target === types.current ? row.getAttribute('geocode_type') : geocode_type_target;
		var map_pin = map_pin_target === null ? row.getAttribute('map_pin') : map_pin_target;

		var params = {
			NUM: num,
			GEOCODE_TYPE: geocode_type,
			MAP_PIN: map_pin,
			LATITUDE: place ? Globalize.format(place.lat(), "n6") : '',
			LONGITUDE: place ? Globalize.format(place.lng(), "n6") : ''
		};

		$.ajax(url, {
			data: params, type:'post', dataType: 'json',
			success: function(response/*, status*/) { set_status_message(row, response.msg); if(only_pin) { only_pin(); }},
			error: function(/* xhr, textStatus */) { set_status_message(row, status_messages.error_server); if(only_pin) { only_pin(); }}
		});

	};
	var got_geocode = function(row, try_no_postal) {
		return function (response, status, other) {
			if (status !== google.maps.GeocoderStatus.OK ) {
				if (status === google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
					geocode_delay += 100;
					geocode_entry(row);
					return;
				} else if(status === google.maps.GeocoderStatus.ZERO_RESULTS && !try_no_postal){
					geocode_entry(row, true);
					return;
				} else {
					var msg = null;
					switch (status) {
						case google.maps.GeocoderStatus.ZERO_RESULTS:
							msg = status_messages.error_unknown_address;
							break;
						case google.maps.GeocoderStatus.REQUEST_DENIED:
							msg = status_messages.error_map_key_fail;
							break;
						case google.maps.GeocoderStatus.OVER_QUERY_LIMIT:
							msg = status_messages.error_too_many_queries;
							break;

						default:
							msg = status_messages.error_unknown_error + status;
							break;

					}
					set_status_message(row, msg);
				}
			} else {
				if(try_no_postal) {
					// second attempt successful
					document.getElementById('status_no_pc_' + get_num(row)).className = "Alert";
				}
				cioc_postback(row, response[0].geometry.location);
			}
			row = next_row(row);
			geocode_entry(row);
		};
	};
	var geocode_entry = function(row, try_no_postal) {
		if ( ! row ) {
			// XXX Alert?
			return;
		}
		var can_update = row.getAttribute('can_update');
		var geocode_type = row.getAttribute('geocode_type');
		if (can_update !== '1' ||
				(map_pin_target === null &&
				(geocode_type_target === types.dont_change ||
				(geocode_type_target === types.current &&
					( geocode_type === types.blank.toString() ||
						geocode_type === types.manual.toString()))))) {
			set_status_message(row, status_messages['nochange']);
			row = next_row(row);
			geocode_entry(row);
			return;
		}

		if (geocode_type_target === types.dont_change) {
			cioc_postback(row, null, function () {
					row = next_row(row);
					geocode_entry(row);
				});

			return;
		}

		if ( geocode_type_target === types.blank ) {
			if (geocode_type !== types.blank ) {
				cioc_postback(row, null);
				row = next_row(row);
				geocode_entry(row);
			}
			return;

		}

		var address;
		if (try_no_postal) {
			address = row.getAttribute('geocode_query_no_pc');
		} else {
			address = row.getAttribute('geocode_query');
		}
		if (!address || address === 'Canada') {
			if (try_no_postal) {
				set_status_message(row, status_messages.unknown);
			}else{
				set_status_message(row, status_messages['nochange']);
			}
			row = next_row(row);
			geocode_entry(row);
			return;
		}


		setTimeout(function () {
				set_status_message(row, status_messages['coding']);
				geocoder.geocode({address: address}, got_geocode(row, try_no_postal));
			}, geocode_delay);

	};
	window['maps_loaded'] = function() {
		geocoder = new google.maps.Geocoder();

		var row = document.getElementById('table_header');
		if(stateField.value !== '0') {
			row = document.getElementById('geocode_table').rows[stateField.value];
		}
		row = next_row(row);
		geocode_entry(row);
	};
	var load_maps = function(culture, key_arg) {
		$.getScript('https://maps.googleapis.com/maps/api/js?v=3&' + key_arg + '&sensor=false&callback=maps_loaded&language=' + culture);
	};
	window['initialize'] = function(options) {
		map_pin_target = options.map_pin_target;
		types = options.types;
		url = options.url;
		geocode_type_target = options.geocode_type_target;
		Globalize.culture(options.culture);
		status_messages = options.status_messages;
		stateField = document.getElementById('stateField');
		if (stateField.value !=='0') {
			var restart_btn = document.getElementById('restart_geocode');
			var continue_btn = document.getElementById('continue_geocode');
			restart_btn.className='';
			restart_btn.onclick = function () {
				stateField.value = '0';
				restart_btn.className='NotVisible';
				continue_btn.className='NotVisible';
				load_maps(options.culture, options.key_arg);
			};

			if (document.getElementById('geocode_table').rows.length - 1 > stateField.value) {
				continue_btn.className='';
				continue_btn.onclick = function () {
					restart_btn.className='NotVisible';
					continue_btn.className='NotVisible';
					load_maps(options.culture, options.key_arg);
				};
			}


			return;
		}
		load_maps(options.culture, options.key_arg);
	};

})();

