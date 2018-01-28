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

var search_handle_geocode = function() {
	return handle_geocode(function(results, status) {
		if (! results) {
			alert(get_response_message(status));
		} else {
			//console.log('search_handle_geocode')
			store_and_map_point(results);
		}
	});
};

var search_do_geocode = function() {
	if (map) {
		var address = document.getElementById('located_near_address').value;
		if (last_geocode_address == address) {
			return false;
		}
		last_geocode_address = address;
		start_geocode(address, search_handle_geocode());
	}
	return false;
};

window['searchform_map_loaded'] = function() {
	create_map();

	var located_near_check_button = $('#located_near_check_button').click(search_do_geocode);
	var autocomplete_input = $('#located_near_address').keydown(handle_address_enter).blur( function() { located_near_check_button.click(); });
	if (google.maps.places) {
		var autocomplete = new google.maps.places.Autocomplete(autocomplete_input[0]);	
		autocomplete.addListener('place_changed', function() {
			var place = autocomplete.getPlace();
			if (place.geometry && place.geometry.location) {
				pending_geocode_address = autocomplete_input.val();
				//console.log('searchform_map_loaded')
				store_and_map_point(place.geometry.location);
			}
		});
	}
};

var handle_address_enter = function(e)
{
    if (null == e) {
        e = window.event ;
	}

    if (e.keyCode == 13)  {
        document.getElementById('located_near_check_button').click();
        return false;
    }
};


})();
