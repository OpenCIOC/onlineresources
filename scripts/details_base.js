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

	var draw_map_start = function(keyarg, culture) {

		var iframeurl = 'https://www.google.com/maps/embed/v1/place?' + keyarg;
		var myLatlng = map_canvas.attr('latitude') + ',' + map_canvas.attr('longitude');
		var mapOptions = {
			center: myLatlng,
			zoom: 13,
			q: myLatlng,
			maptype: 'roadmap',
			language: culture
		};
		iframeurl = iframeurl + '&' + $.param(mapOptions)

		map_canvas.show();
		map_canvas.append(
			$('<iframe>').prop({
				src: iframeurl,
				frameborder: 0
			}).css({border: 0, height: '100%', width: '100%'})
		);

		return;
	};

	window['initialize_record_maps'] = function(keyarg, culture) {
		map_canvas = $('div#map_canvas');
		if (map_canvas.length) {
			draw_map_start(keyarg, culture);
		}
	};

})();
