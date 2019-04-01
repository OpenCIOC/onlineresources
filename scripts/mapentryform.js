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


	var trim_string = function(sInString) {
	  sInString = sInString.replace( /^\s+/g, "" );// strip leading
	  return sInString.replace( /\s+$/g, "" );// strip trailing
	};
	var entryform_handle_geocode = function(callback, skip_postal) {
		return handle_geocode(function (place, status) {
			if (place) {
				if (skip_postal) {
					$('#geocode_no_postal_code').show();
				}
				callback(place)
			} else if (status == google.maps.GeocoderStatus.ZERO_RESULTS && !skip_postal && document.getElementById('GEOCODE_TYPE_SITE').checked) {
				geocode_address(callback, true);
			} else {
				alert(get_response_message(status));
				callback(null);
			}
		})
	}

	var get_address_to_geocode = function(skip_postal) {
		var form = document.getElementById('EntryForm');
		var address_parts = [];

		if (!form.SITE_STREET_NUMBER) {
			return null;
		}

		var val = [form.SITE_STREET_NUMBER.value, form.SITE_STREET.value, 
						form.SITE_STREET_TYPE.value, form.SITE_STREET_DIR.value].join(' ');
		val = trim_string(val);
		if (val) {
			address_parts.push(val);
		}

		var address_fields = ['SITE_CITY', 'SITE_PROVINCE']
		if (!skip_postal) {
			address_fields.push('SITE_POSTAL_CODE');
		}
		for (var i = 0; i < address_fields.length; i++) {
			var val = form[address_fields[i]].value;
			if ( val ) {
				address_parts.push(val);
			}
		}

		val = form.SITE_COUNTRY.value;
		if (val) {
			address_parts.push(val);
		} else { 
			address_parts.push('Canada');
		}

		var address = address_parts.join(', ');

		if (! address || address == 'Canada') {
			return null;
		}

		return address;
	}

	var get_intersection_to_geocode = function() {
		var form = document.EntryForm;
		var address_parts = [];

		if ( !form.INTERSECTION && !form.INTERSECTION.value ) {
			return null;
		}
		
		var address_fields = ['INTERSECTION', 'SITE_CITY', 'SITE_PROVINCE']
		for (var i = 0; i < address_fields.length; i++) {
			var val = form[address_fields[i]].value;
			if ( val ) {
				address_parts.push(val);
			}
		}

		val = form.SITE_COUNTRY.value;
		if (val) {
			address_parts.push(val);
		} else { 
			address_parts.push('Canada');
		}

		return address_parts.join(', ');
		

	}

	var pending_geocode_address = null;
	var entryform_start_geocode = function(address, callback, skip_postal) {
		pending_geocode_address = address;
		start_geocode(address, entryform_handle_geocode(callback, skip_postal));
		if (! address ) {
			callback(null);
			return;
		}
		$('#geocode_no_postal_code').hide();
	};

	var geocode_address = function(callback, skip_postal) {
		var address = get_address_to_geocode(skip_postal);
		entryform_start_geocode(address, callback, skip_postal);
	}

	var geocode_intersection = function(callback) {
		var address = get_intersection_to_geocode();
		entryform_start_geocode(address, callback);
	}

	var handle_geocode_entryform_feedback = function(lat, lng) {
		if (typeof(lat) != 'undefined' && lat !== null && 
				typeof(lng) != 'undefined' && lng !== null) {
			last_geocode_address = pending_geocode_address;
			store_and_map_point(google.maps.LatLng(Globalize.parseFloat(lat), Globalize.parseFloat(lng)));
		}
	}
	window['handle_geocode_entryform_feedback'] = handle_geocode_entryform_feedback;

	var verify_geocode = function(place) {
		store_and_map_point(place);
	}

	var clear_map = function() {
		clear_overlay();
		map_default();
		was_blank_map = true;
		$('#geocode_no_postal_code').hide();
	}


	var do_geocode_type_manual = function(skip_geocode_address) {
		set_lat_lng_readonly(false);
		$('#GEOCODE_TYPE_SITE_REFRESH,#GEOCODE_TYPE_INTERSECTION_REFRESH').hide();
		if (!current_overlay && !skip_geocode_address) {
			geocode_address(function(place) {
				if (place) {
					store_and_map_point(place);
				} else {
					was_blank_map = false;
					var center = map.getCenter()
					center = center.toUrlValue().split(',');
					store_coordinates.apply(null,center);
					map_lat_lng.apply(null,center);
					last_geocode_address = null;
					pending_geocode_address = null;
				}

			});
		} 
	}
	window['do_geocode_type_manual'] = do_geocode_type_manual;

	var set_lat_lng_readonly = function(readonly) {
		var map_refresh_area = document.getElementById('map_refresh_ui_area');
		if (map_refresh_area) {
			document.getElementById('LONGITUDE').readOnly = readonly;
			document.getElementById('LATITUDE').readOnly = readonly;
			if (readonly) {
				$(map_refresh_area).hide();
			} else {
				$(map_refresh_area).show();
			}
		}
	}
	window['entryform_maps_loaded'] = function() {
		draggable = true;
		create_map();

			var geocode_type_intersection_refresh = $('#GEOCODE_TYPE_INTERSECTION_REFRESH'),
				geocode_type_site_refresh = $('#GEOCODE_TYPE_SITE_REFRESH'),
				geocode_type_site = $('#GEOCODE_TYPE_SITE').click(function() {
					geocode_type_intersection_refresh.hide();
					geocode_type_site_refresh.show();
					set_lat_lng_readonly(true);
					geocode_address(store_and_map_point);
				}),
				geocode_type_intersection = $('#GEOCODE_TYPE_INTERSECTION').click( function() {
					geocode_type_intersection_refresh.show();
					geocode_type_site_refresh.hide();
					set_lat_lng_readonly(true);
					geocode_intersection(store_and_map_point);
				});
			$('#GEOCODE_TYPE_MANUAL').click(function() { 
				do_geocode_type_manual(false); 
			});

			$('#GEOCODE_TYPE_BLANK').click( function () {
				$('#GEOCODE_TYPE_SITE_REFRESH,#GEOCODE_TYPE_INTERSECTION_REFRESH').hide();
				set_lat_lng_readonly(true);
				clear_map(); 
				store_coordinates('', '');
				pending_geocode_address = null;
				last_geocode_address = null;
			});
			geocode_type_site_refresh.click( function () { 
				geocode_address(store_and_map_point); 
			});

			geocode_type_intersection_refresh.click( function () { 
				geocode_intersection(store_and_map_point); 
			});

			// Check address and geocode
			var form = document.EntryForm;

			var map_refresh_button = document.getElementById('map_refresh');
			if (map_refresh_button) {
				$(map_refresh_button).click(function() {
					map_lat_lng(Globalize.parseFloat(form.LATITUDE.value), Globalize.parseFloat(form.LONGITUDE.value));
				});
			}



			if (!form.SITE_STREET_NUMBER) {
				form.GEOCODE_TYPE_SITE.disabled = true;
				geocode_type_site_refresh.hide();
			} else if ( document.getElementById('GEOCODE_TYPE_SITE').checked ) {
				geocode_address(verify_geocode);
				geocode_type_site_refresh.show();
			}

			if (!form.INTERSECTION) {
				form.GEOCODE_TYPE_INTERSECTION.disabled = true;
				geocode_type_site_refresh.hide();
			} else if (document.getElementById('GEOCODE_TYPE_INTERSECTION').checked ) {
				geocode_intersection(verify_geocode);
				geocode_type_intersection_refresh.show();
			}

			set_lat_lng_readonly(!form.GEOCODE_TYPE_MANUAL.checked);

			$(form).submit(function (e) {
				var check_address = null;
				var check_msg = null;
				if ( document.getElementById('GEOCODE_TYPE_SITE').checked) {
					check_address = get_address_to_geocode();
					check_msg = pageconstants.txt_geocode_address_changed;
				} else if (document.getElementById('GEOCODE_TYPE_INTERSECTION' ).checked ) {
					check_address = get_intersection_to_geocode();
					check_msg = pageconstants.txt_geocode_intersection_change;
				}

				if (check_msg && check_address != last_geocode_address) {
					if ( ! confirm(check_msg) ) {
						map_canvas.scrollIntoView(true);
						document.documentElement.scrollTop = document.documentElement.scrollTop - 10;
						e.preventDefault();
						e.stopImmediatePropagation();
						$("#SUBMIT_BUTTON").prop('disabled',false);

					}
				}
			});
			
			var on_menu_click = function(e) {
				var self = $(this);
				$("#dropdownMAP_PIN .selection").html(self.html());
				$('#MAP_PIN').val(self.data('value'));
				if (e) {
					e.preventDefault()
				}
			};
			$('#dropdownMAP_PINmenu li a').click(on_menu_click);
			on_menu_click.call($('#dropdownMAP_PINmenu li a[data-value=' + $('#MAP_PIN').val() + ']'))
	}

})();
