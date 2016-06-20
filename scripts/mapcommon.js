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
	/*global google:true Globalize:true pageconstants:true */
	var map_canvas = null;
	var map = null;
	var default_center = [59.888937,-101.601562];
	var geocoder = null;
	var current_overlay = null;
	var was_blank_map = true;
	var draggable = false;
	var last_geocode_address = null;

	// different
	var current_overlay_drag_evt = null;

	var map_default = function() {
		map.setCenter(new google.maps.LatLng(default_center[0],default_center[1]), 2);
	};

	var clear_overlay = function() {
		if (current_overlay) {
			current_overlay.setMap(null);
		}
		current_overlay = null;

		if (current_overlay_drag_evt) {
			google.maps.event.removeListener(current_overlay_drag_evt);
			current_overlay_drag_evt = null;
		}
	};


	var store_coordinates = function(lat, lng) {
		document.getElementById('LATITUDE').value = Globalize.format(lat, 'n6');
		document.getElementById('LONGITUDE').value = Globalize.format(lng, 'n6');
	};

	var map_lat_lng = function(lat, lng) {
		var point = new google.maps.LatLng(lat, lng);
		if (was_blank_map) {
			map.setZoom(14);
		}
		map.setCenter(point);
		was_blank_map = false;
		var marker = new google.maps.Marker({
			position: point,
			map: map,
			clickable:false
		});
		
		clear_overlay();

		current_overlay = marker;

		//different
		//if (draggable) {
		//	var evt = google.maps.event.addListener(marker, "dragend", marker_drag_end);
		//	current_overlay_drag_evt = evt;
		//}
	};
	var marker_drag_end = function() {
		$('#GEOCODE_TYPE_SITE_REFRESH, #GEOCODE_TYPE_INTERSECTION_REFRESH').addClass('NotVisible');
		$('#GEOCODE_TYPE_MANUAL').prop('checked', true);
		var point = this.getPosition();
		store_coordinates(point.lat(), point.lng());
	};

	var store_and_map_point = function(place) {
		if (place) {
			last_geocode_address = pending_geocode_address;
			store_coordinates(place.lat(), place.lng());
			map_lat_lng(place.lat(), place.lng());
		}
	};

	var get_response_message = function(status) {
		var msg = null
		switch (status) {
			case google.maps.GeocoderStatus.ZERO_RESULTS:
				msg = pageconstants.txt_geocode_unknown_address;
				break;
			case google.maps.GeocoderStatus.REQUEST_DENIED:
				msg = pageconstants.txt_geocode_map_key_fail;
				break;
			case google.maps.GeocoderStatus.OVER_QUERY_LIMIT:
				msg = pageconstants.txt_geocode_too_many_queries;
				break;

			default:
				msg = pageconstants.txt_geocode_unknown_error + status;
				break;

		}
		return msg;
	};
	window['get_response_message'] = get_response_message;

	var handle_geocode = function(callback) {
		return function(results, status) {
			if (status !== google.maps.GeocoderStatus.OK) {
				callback(null, status);
			} else {
				callback(results[0].geometry.location, status);
			}
			
		};
	};
	window['handle_geocode'] = handle_geocode;

	var start_geocode = function(address, callback) {
		pending_geocode_address = address;
		if ( !address ) {
			clear_overlay();
			store_coordinates("", "");
			return;
		}
		geocoder.geocode({address: address}, callback);
	};
	
	var create_geocoder = function() {
		if (!geocoder) {
			geocoder = new google.maps.Geocoder();
		}
	};

	var create_map = function() {
		var mapOptions = {
			zoom: 13,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		map_canvas = document.getElementById("map_canvas")
		map = new google.maps.Map(map_canvas, mapOptions);
		map_default();

		create_geocoder();


		var lat = $('#LATITUDE')[0].value, lng = $('#LONGITUDE')[0].value;
		if (lat && lng) {
			map_lat_lng(Globalize.parseFloat(lat), Globalize.parseFloat(lng));
		}
	};


	var maps_loaded_callbacks = [], maps_loaded_done = false;
	

	window['maps_loaded'] = function() {
		maps_loaded_done = true;
		$.each(maps_loaded_callbacks, function(idx, fn) {
			fn();
		});
		maps_loaded_callbacks = [];
	};

	window['add_maps_loaded_callback'] = function(fn) {
		if (maps_loaded_done) {
			fn();
		} else {
			maps_loaded_callbacks.push(fn);
		}
	};
	window['initialize_maps'] = function(culture, key_arg, loaded_fn, add_places) {
		if (!window['cioc_map_script_added']) {
			window['cioc_map_script_added'] = true
			Globalize.culture(culture);
			var places = ''
			if (add_places) {
				places = '&libraries=places';
			}
			$.getScript('//maps.googleapis.com/maps/api/js?v=3&' + key_arg + '&sensor=false&callback=maps_loaded&language=' + culture + places);
		}
		add_maps_loaded_callback(loaded_fn);
	};
