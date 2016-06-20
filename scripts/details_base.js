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
	/*global google:true */
	var map = null;
	var map_canvas = null;

	var draw_map_start = function() {

		var myLatlng = new google.maps.LatLng(map_canvas.attr('latitude'), map_canvas.attr('longitude')),
		mapOptions = {
			center: myLatlng,
			zoom: 13,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		}, marker = new google.maps.Marker({
			position: myLatlng
		});

		map_canvas.show();

		map = new google.maps.Map(map_canvas[0], mapOptions);
		marker.setMap(map);

		return;
	};

	window['initialize_record_maps'] = function(keyarg, culture) {
		window['draw_map'] = draw_map_start;
		map_canvas = $('#map_canvas');
		if (map_canvas.length) {
			$.getScript("//maps.googleapis.com/maps/api/js?v=3&" + keyarg + "&sensor=false&callback=draw_map&language=" + culture);
		}
	};

})();
