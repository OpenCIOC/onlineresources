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
var map_pins = null;
var calc_map_pins_order = function (map_pins) {
	var map_pins_order = [];
	var count = 0;
	for (var i in map_pins) {
		var mp = map_pins[i];
		mp.order_index = count;
		map_pins_order.push(i);
		count++;
	}
	return map_pins_order;
};
var map = null;
var mgr = null;
var update_cluster_labels = function(clusters)
{
	$.each(clusters, function(which_cluster, cluster) {
		var markers = cluster.getMarkers();
		var num;
		$.each(markers, function(i,marker) {
			num = marker.num;
			var cell = document.getElementById('map_pin_number_' + num);
			cell.innerHTML = which_cluster + 1;
		});
		cluster.getIcon().useStyle({ text: which_cluster + 1, index: map_pins[markers.length > 1 ? 0 : mapped_pin[num]].order_index + 1 });
	});
	
}
var mapped_pin = {};
window['start_map'] = function() {
	var default_center = [59.888937,-101.601562];
	var mapOptions = {
		center: new google.maps.LatLng(default_center[0],default_center[1]),
		zoom: 2,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	}
	map = new google.maps.Map(document.getElementById('map_canvas'), mapOptions);

	var cluster_styles = [];
	for(var pin_num=0; pin_num < map_pins_order.length; pin_num++) {
		var mappin = map_pins_order[pin_num];
		var mp = map_pins[mappin];
		cluster_styles.push({url: 'images/mapping/' + mp.image, height: mappin != 0 ? 25 : 30, width: mappin != 0 ? 25 : 30,  textColor: '#' + mp.textColour});
	}
	mgr = new MarkerClusterer(map, [], {gridSize: 21, maxZoom:99, minimumClusterSize:1, styles: cluster_styles});
	google.maps.event.addListener(mgr, "clusteringend", function() { update_cluster_labels(mgr.getClusters()) });
	

	var bounds = new google.maps.LatLngBounds();
	var legend_items = {};

	var markers = [];
	var map_rows = $('#page_content tr.MapRow').each(function(index) {
		var mr = $(this), info = mr.data('mapinfo');
		var lat = Globalize.parseFloat(info.latitude),
			lng = Globalize.parseFloat(info.longitude),
			num = info.num,
			pin = info.mappin,
			point = new google.maps.LatLng(lat, lng),
			marker = new google.maps.Marker({position: point, clickable:false});

		legend_items[pin] = true;

		marker.num = num;
		markers.push(marker);

		mapped_pin[num] = parseInt(pin, 10);

		bounds.extend(point);
		
	});
	mgr.addMarkers(markers);

	if (map_rows.length) {
		map.fitBounds(bounds);
		//map.setCenter(bounds.getCenter());
	} else {
		map.setCenter(new google.maps.LatLng(59.888937,-101.601562));
		map.setZoom(2);
	}
	//map.savePosition();
}
window['init'] = function(options) {
	map_pins = options.map_pins;
	map_pins_order = calc_map_pins_order(map_pins);
	$.getScript('//maps.googleapis.com/maps/api/js?v=3&' + options.key_arg + '&sensor=false&callback=start_map&language=' + options.culture);
	
	var pageTitle= prompt('Please enter a Title for the map', '');
	if ((pageTitle!='') && (pageTitle!=null)) { 
		$('#PrintMapPageTitle').text(pageTitle).show();
	}
}

})();
