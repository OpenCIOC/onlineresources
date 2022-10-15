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

(function($, window, document) {
/*global is_ie7:true google:true MarkerClusterer:true remove_class:true add_class:true Globalize:true */
	// workaround for bug in jq-ui 1.9.0
	var slice = Array.prototype.slice;
	jQuery.widget.extend = function( target ) {
		var input = slice.call( arguments, 1 ),
		inputIndex = 0,
		inputLength = input.length,
		key,
		value;
		for ( ; inputIndex < inputLength; inputIndex++ ) {
			for ( key in input[ inputIndex ] ) {
				value = input[ inputIndex ][ key ];
				if (input[ inputIndex ].hasOwnProperty( key ) && value !== undefined ) {
					if ( $.isPlainObject( value ) && $.isPlainObject( target[ key ] ) ) {
						target[ key ] = $.widget.extend( {}, target[ key ], value );
					} else {
						target[ key ] = value;
					}
				}
			}
		}
		return target;
	};
	// end workaround
	var createCookie = function(name,value,days) {
		var expires;
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			expires = "; expires="+date.toGMTString();
		} else {
			expires = "";
		}
		document.cookie = name+"="+value+expires+"; path=/";
	};

	var readCookie = function(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)===' ') {
				c = c.substring(1,c.length);
			}
			if (c.indexOf(nameEQ) === 0) {
				return c.substring(nameEQ.length,c.length);
			}
		}
		return null;
	};

	/*
	var eraseCookie = function(name) {
		createCookie(name,"",-1);
	};
	*/

	// We define the function first
	var MapPositionControl = function () {
	};
	
	// Creates a one DIV for each of the buttons and places them in a container
	// DIV which is returned as our control element. We add the control to
	// to the map container and return the element for the map class to
	// position properly.
	MapPositionControl.prototype.initialize = function(map) {
		var self = this, container = $('<div>').css({ fontFamily: "Arial,sans-serif", fontSize: "small" });


		this.legendButton = this.makeButton_(translations.txt_legend).
			appendTo(container).css('right',  "10.2em").hide().click(function() {
					if (self.legendPopup.is(':hidden')) {
						self.legendPopup.show();
					} else {
						self.legendPopup.hide();
					}
				});

		this.legendPopup = $('<div>').addClass('MapLegendContainer').hide().appendTo(this.legendButton);

		var toBottomDiv = this.makeButton_(translations.txt_to_bottom).appendTo(container).
			css('right', '5.1em').click(function() {
					var center = map.getCenter();

					set_map_position('Bottom');
					toBottomDiv.hide();
					toSideDiv.show();

					map.panTo(center);
				});

		var toSideDiv = this.makeButton_(translations.txt_to_side).appendTo(container).
			css('right', '5.1em').click(function() {
				var center = map.getCenter();

				set_map_position('Side');
				toSideDiv.hide();
				toBottomDiv.show();

				map.panTo(center);
			});

		this.makeButton_(translations.txt_close).appendTo(container).
			click(function() {
					var path = $.param.fragment();
					if ( path === "/SHOWMAP" ) {
						$.bbq.pushState('#');
					} else {
						var params = path.split('?');
						path = params[0];

						if (params.length > 1) {
							params = '?' + params[1];
						} else {
							params = '';
						}
						$.bbq.pushState('#' + path + ':NOMAP' + params);
					}
				});


		if (map_position === 'Side') {
			toSideDiv.hide();
		} else {
			toBottomDiv.hide();
		}

		//map.getContainer().appendChild(container);
		return container[0];
	};

	MapPositionControl.prototype.makeButton_ = function(label) {
		return $('<div>').css({
				backgroundColor: "white",
				border: "1px solid black",
				textAlign: "center",
				width: "5em",
				cursor: "pointer",
				position: "absolute",
				bottom: "0px",
				right: "0px"
			}).append(
				$('<div>').css({
					borderStyle: "solid",
					borderWidth: "1px",
					borderColor: "white rgb(176, 176, 176) rgb(176, 176, 176) white",
					fontSize: "12px"
				}).text(label));
	};

	MapPositionControl.prototype.addCategory = function(icon, categoryname, category_id, add_checkbox) {
		var entry = $('<li>').css('listStyleImage',"url('" + icon + "')").text(categoryname);

		if (this.legendButton.is(':hidden')) {
			this.legendList = $('<ul>').addClass('MapLegendList').appendTo(this.legendPopup);
			this.legendButton.show();
		}
		this.legendList.append(entry);

		if (add_checkbox) {
			$('<input type="checkbox">').prop({'checked': true, id:  'mapping_category_' + category_id}).
				prependTo(entry).click(function(evt) {
					evt.stopPropagation();
					toggle_mapping_category(category_id);
				});
		}
		
	};

var map_pins, translations, culture, key_arg;
var orig_results_col_class = null;

var toggle_subjects = function(hide) {
	var results_col = $('#results-column');
	if (!results_col.length) {
		// No subjects column
		return;
	}
	if (!orig_results_col_class) {
		orig_results_col_class = results_col[0].className;
	}
	if (hide) {
		$('#subjects_column').hide();
		$('#show_subjects_display').show();
		results_col[0].className = 'col-xs-12';
	} else {
		$('#subjects_column').show();
		$('#show_subjects_display').hide();
		results_col[0].className = orig_results_col_class;
	}
};

var do_hide_subjects = function() {
	toggle_subjects(true);
	return false;
};
window['do_hide_subjects'] = do_hide_subjects;

var do_show_subjects = function(evt) {
	evt.preventDefault();
	toggle_subjects(false);
	return false;
};
window['do_show_subjects'] = do_show_subjects;

/*
var get_scroller_width = function() {
	var sBarWidth = 0;
	var scr = null;
	var inn = null;

	if (is_ie7) {
		// create form
		scr = document.createElement('form');

		// move form off screen so no one can see it
		scr.style.position = 'absolute';
		scr.style.top = '-1000px';
		scr.style.left = '-1000px';

		// create a text area
		inn = document.createElement('textarea');

		//set id so we can grab it later
		inn.setAttribute('id', 'ta');

		// add textarea to form
		scr.appendChild(inn);

		// add the element to the document
		document.getElementsByTagName("body")[0].appendChild(scr);

		// grab the text area by id
		var tarea = document.getElementById('ta');

		// turn scroll bars off
		tarea.wrap = 'off';

		// get height
		sBarWidth = tarea.offsetHeight;

		// turn scroll bars on
		tarea.wrap = 'soft';

		// get difference
		sBarWidth -= tarea.offsetHeight;
		
	} else {
		var wNoScroll = 0;
		// Outer scrolling div
		scr = document.createElement('div');

		// move form off screen so no one can see it
		scr.style.position = 'absolute';
		scr.style.top = '-1000px';
		scr.style.left = '-1000px';

		// set binding height and width
		scr.style.width = '100px';
		scr.style.height = '50px';

		// Start with no scrollbar
		scr.style.overflow = 'hidden';

		// Inner content div
		inn = document.createElement('div');
		inn.style.width = '100%';
		inn.style.height = '200px';

		// Put the inner div in the scrolling div
		scr.appendChild(inn);

		// Append the scrolling div to the doc
		document.body.appendChild(scr);

		// Width of the inner div sans scrollbar
		wNoScroll = inn.offsetWidth;

		// Add the scrollbar
		scr.style.overflow = 'auto';

		// Width of the inner div width scrollbar
		var wScroll = inn.offsetWidth;

		// Pixel width of the scrolbar
		sBarWidth = (wNoScroll - wScroll);
	}

	return sBarWidth;
};
*/

/*
var map_level_pins = [];
*/

var map = null;
var mgr = null;
//var resize_evt = null;
var map_position = 'Side';
var map_size = [0,0];
var _scrollbar_width = null;
var extra_spacing = null;
var mapped_items = {};
var _fake_body = null;
var _fake_body_content = null;
var _map_container = null;
var _map_canvas = null;
var _map_drag_cell_bottom = null;
var _map_drag_cell_side = null;
//var _last_mouse = [0,0];
var _map_position_contol = null;

var save_map_parameters = function() {
	createCookie('cioc_map_position', [map_position].concat(map_size).join(','), 365);
};

var set_map_position = function(pos) {
	if (map_position === pos) {
		return;
	}
	map_position = pos;
	save_map_parameters();

	_map_container.show();
	_fake_body[0].className = 'MapSearchShift MapSearchShift' + map_position;
	_map_canvas[0].className = 'MapSearchResults MapSearchResults'+ map_position;
	_map_container[0].className = 'MapSearchResults MapSearchResults'+ map_position;


	var size = map_position === 'Side' ? parseInt(map_size[0], 10) : parseInt(map_size[1], 10);
	if (pos === "Side") {
		$('#bottom-handle').hide();
		$('#side-handle').show();
		if ( size ) {
			var width = parseInt(($(window).width() * size / 100).toFixed(0), 10);
			_map_container.css({width: (width).toString() + 'px', height: ''});
			_map_canvas.css({width: (width - _map_drag_cell_side.outerWidth()) + 'px', height: ''});
		} else {
			_map_container.css({width: '', height: ''});
			_map_canvas.css({width: '', height: ''});
		}
	}else {
		$('#bottom-handle').show();
		$('#site-handle').hide();
		if ( size ) {
			var height = parseInt(($(window).height() * size / 100).toFixed(0), 10);
			_map_container.css({height: (height + _map_drag_cell_bottom.outerHeight()).toString() + 'px', width: ''});
			_map_canvas.css({height: height + 'px', width:''});
		}else{
			_map_container.css({height: '', width: ''});
			_map_canvas.css({height: '', width: ''});
		}
	}



	set_body_size();

};
var hide_map = function() {
	if (!dom_modified) {
		return;
	}
	hide_mapping_column();
	$('#check_all_in_viewport').hide();
	if ($('#subjects_column').length) {
		$('#show_subjects_display').show();
	}

	$('#map_my_results_ui').show();
	_map_container.hide();
	//hide(document.getElementById('map_container'));
	set_body_size();
};

/*
var get_popup_options = function() {
	var max_width = _map_canvas.innerWidth() - 130;
	var max_height = _map_canvas.innerHeight() - 150;
	return {maxWidth: max_width, maxHeight: max_height, autoScroll: true};
};
*/

var get_popup_width = function() {
	return _map_canvas.innerWidth() - 150;
};

var map_popup_start = function() {
	return '<div id="map_popup" class="MapPopup">';
};

var map_popup_end = function() {
	return '<\/div>';
};

var open_cluster = null;
var info_window = null;
var info_window_event_listener = null;
var info_window_marker_offset = null;
var info_window_cluster_offset = null;
var after_info_window_close = function() {
	open_cluster = null;
	last_num = null;
	reset_last_map_marker_icons();
	if (info_window_event_listener) {
		google.maps.event.removeListener(info_window_event_listener);
		info_window_event_listener = null;
	}
};
var close_info_window = function() {
	if (info_window) {
		info_window.close();
		after_info_window_close();
	}
};

var open_info_window = function(html, position, offset) {
	close_info_window();
	info_window = new google.maps.InfoWindow({content: html, position: position, maxWidth: get_popup_width(), pixelOffset: offset});
	info_window_event_listener = google.maps.event.addListener(info_window, 'closeclick', after_info_window_close);
	info_window.open(map);
};

var move_info_window = function(num) {
	var mi = mapped_items[num];
	var marker = mi.marker;
	var cluster = findCluster(mgr, mi.marker);
	if (cluster && cluster.getSize() > 1) {
		info_window.setOptions({position:cluster.getCenter(),
			pixelOffset: info_window_cluster_offset});
	} else {
		info_window.setOptions({position: marker.getPosition(),
			pixelOffset: info_window_marker_offset});
	}
};

var marker_cluster_clicked = function(cluster)
{
	var i, num;
	if ( open_cluster !== cluster || !info_window) {
		if (cluster.getSize() > 9 && map.getZoom() <
				map.mapTypes.get(map.getMapTypeId()).maxZoom) {
			return true;
		}

		var markers = cluster.getMarkers();
		var html = map_popup_start() + '<ul>';
		
		var nums = [];
		for(i = 0; i < markers.length; i++)
		{
			var marker = markers[i];
			num = marker.num;
			var mi = mapped_items[num];
			nums.push(num);

			html += '<li style="list-style-image: url(\'' + map_pins[mi.mappin].image_small_circle + '\');"><b>' + mi.orgname + '<\/b><br><a href="#/'+ num + '">' + translations.txt_more_info + '<\/a></li>';
		}

		html += '</ul>' + map_popup_end();
		open_info_window(html, cluster.getCenter(), info_window_cluster_offset);
		open_cluster = cluster;

		for(i = 0; i < nums.length; i++)
		{
			num = nums[i];
			highlight_map_marker_icon(num);
		}
	} else {
		close_info_window();
	}
	return false;
};

var zoom_happended = false;

var handle_zoom_end = function() {
	zoom_happended = true;
};

var clustering_in_progress = false;

/*
var handle_clustering_begin = function() {
	clustering_in_progress = true;
};
*/

var handle_clustering_end = function()
{
	zoom_happended = false;
	clustering_in_progress = false;
	if (map_popup_args) {
		var args = map_popup_args;
		map_popup_args = null;
		show_map_popup.apply(null, args);
	} else {
		if (last_num) {
			var num = last_num;
			move_info_window(num);
			return;
		}
		if (open_cluster && zoom_happended) {
			close_info_window();
		}
	}
};

var window_resize = function() {
	set_body_size();
};

window['maps_loaded'] = function() {
	var default_center = [59.888937,-101.601562];
	var mapOptions = {
		center: new google.maps.LatLng(default_center[0],default_center[1]),
		zoom: 2,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	map = new google.maps.Map(_map_canvas[0], mapOptions);
	// this event needs to happend early
	google.maps.event.addListener(map, 'zoom_changed', handle_zoom_end);

	var mgr_styles = [{ url: 'images/mapping/mm_0_white_circle.png', height: 30, width: 30}];
	mgr = new MarkerClusterer(map, [], {gridSize: 21, maxZoom: 99, styles: mgr_styles, zoomOnClick: false});
	google.maps.event.addListener(mgr, "click", marker_cluster_clicked);
	google.maps.event.addListener(mgr, 'clusteringend', handle_clustering_end);



	_map_position_contol = new MapPositionControl();
	map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(_map_position_contol.initialize(map));
	$(window).resize(window_resize);


	start_mapping();
	var fragment = $.param.fragment();
	if (fragment && fragment !== '/SHOWMAP') {
		$(window).trigger('hashchange');
	}


};

var get_win_size = function() {
	var win = $(window);
	return	{
		width: win.width(),
		height: win.height()
	};
};

var vertical_scrollbar_on = function() {
	var fake = _fake_body[0];
	return fake.scrollHeight > fake.offsetHeight;
};

var horizontal_scrollbar_on = function() {
	var fake = _fake_body[0];
	return fake.scrollWidth > fake.offsetWidth;
};

var set_body_size = function(skip_marker_check) {
	if (_scrollbar_width === null) {
		_scrollbar_width = $.scrollbarWidth();
	}
	var scrollbar_width = _scrollbar_width;
	var scrollbar_height = _scrollbar_width;

	var win_size = get_win_size();

	if ((_drag_v_scrollbar_on === null && !vertical_scrollbar_on()) ||
			(_drag_v_scrollbar_on !== null && !_drag_v_scrollbar_on)) {
		scrollbar_width = 0;
	}
	if ((_drag_h_scrollbar_on === null && !horizontal_scrollbar_on()) ||
		(_drag_h_scrollbar_on !== null && !_drag_h_scrollbar_on)) {
		scrollbar_height = 0;
	}
	if (map_position === 'Side') {
		var container_width = _map_container.is(':visible') ? _map_container.outerWidth() : 0;
		_fake_body.css({width:(win_size.width - container_width).toString() + 'px', height: ''});
		_fake_body_content.css('width', (win_size.width - container_width - scrollbar_width - extra_spacing.width).toString() + 'px');
		//_map_drag_cell_side.css('height',win_size.height + 'px');
		_map_canvas.css('height',win_size.height + 'px');
	} else {
		var container_height = _map_container.is(':visible') ? _map_container.height() : 0;
		_fake_body.css({height:(win_size.height - container_height ).toString() + 'px',
						width: ''});
		_fake_body_content.css({height: (win_size.height - container_height - scrollbar_height - extra_spacing.height).toString() + 'px',
						width: ''});
	}
	if(map && ! skip_marker_check) {
		google.maps.event.trigger(map, 'resize');
		//mgr.resetViewport();
	}

	if (!skip_marker_check) {
		check_visible_markers();
	}

};

var _drag_v_scrollbar_on = null;
var _drag_h_scrollbar_on = null;

var toggle_mapping_category = function(category_id) {
	var checkbox = document.getElementById('mapping_category_' + category_id);
	var category_on = checkbox.checked;
	var markers = [];
	for(var num in mapped_items) {
		var item = mapped_items[num];
		if (item.mappin === category_id) {
			markers.push(item.marker);
		}
	}
	if (category_on) {
		mgr.addMarkers(markers);
	} else {
		mgr.removeMarkers(markers);
	}
};

var markers_to_reset = {};
var last_num = null;

var reset_last_map_marker_icons = function() {
	$.each(markers_to_reset, function(num, desc) {
		if (desc.marker_icon) {
			desc.marker_icon.prop('src',map_pins[mapped_items[num].mappin].image_small);
			desc.marker_cell.removeClass('HighLight');
		}
	});
	markers_to_reset = {};
};

var highlight_map_marker_icon = function(num) {
	var map_marker_icon = $('#map_marker_icon_' + num + ',#map_marker_icon_mobile_' + num);
	var map_marker_cell = $('#map_column_' + num + ',#map_column_mobile_' + num);
	if ( map_marker_icon ) {
		map_marker_icon.prop('src', map_pins[mapped_items[num].mappin].image_small_dot);
		map_marker_cell.addClass('HighLight');
	}
	markers_to_reset[num] = {marker_icon: map_marker_icon, marker_cell: map_marker_cell};
	return map_marker_icon;
};

var fix_map_marker_icons = function() {
	$.each(markers_to_reset, function(num, desc) {
		if (!desc.marker_icon) {
			var map_marker_icon = $('#map_marker_icon_' + num + ',#map_marker_icon_mobile_' + num);
			var map_marker_cell = $('#map_column_' + num + ',#map_column_mobile_' + num);
			map_marker_icon.prop('src', map_pins[mapped_items[num].mappin].image_small_dot);
			map_marker_cell.addClass('HighLight');
			desc.marker_icon = map_marker_icon;
			desc.marker_cell = map_marker_cell;
		}
	});
};

var findCluster = function(clusterer, marker) {
	var clusters = clusterer.getClusters();
	for (var i=0; i < clusters.length; i++) {
		if (clusters[i].isMarkerInClusterBounds(marker)) {
			return clusters[i];
		}
	}
	return null;
};

var map_popup_args = null;
var show_map_popup = function(num, scroll, keep, redisplay) {
	if (typeof(keep) === 'undefined' || keep === null ) {
		keep = false;
	}
	if (clustering_in_progress) {
		map_popup_args = $.makeArray(arguments);
		return;
	}
	var mi = mapped_items[num];
	if (mi && mi.marker) {
		if (last_num === num && info_window || redisplay) {
			if (!keep || redisplay ) {
				close_info_window();
			}
			if (!redisplay) {
				return;
			}
		}


		var html = map_popup_start() + '<b>' + mi.orgname + '<\/b><br><a href="#/'+ num + '">' + translations.txt_more_info + '<\/a>' + map_popup_end();
		var marker = mi.marker;
		var cluster = findCluster(mgr, marker);
		if (cluster && cluster.getSize() > 1) {
			if ( ! map.getBounds().contains(cluster.getCenter()) ) {
				map.setCenter(cluster.getCenter());
			}
			open_info_window(html, cluster.getCenter(), info_window_cluster_offset);
		} else {
			open_info_window(html, marker.getPosition(), info_window_marker_offset);
		}
		last_num = num;

		var map_marker_icon = highlight_map_marker_icon(num);
		if ( map_marker_icon.length ) {
			if (scroll) {
				var fake = _fake_body;
				map_marker_icon.filter(":visible")[0].scrollIntoView(true);
				fake.scrollTop(fake.scrollTop() - 5);
			}
		}
	} else if (last_num && info_window) {
		mi = mapped_items[last_num];
		close_info_window();
	}
};

var make_show_map_popup_handler = function(scroll) {
	return function (num) { show_map_popup(num, scroll); };
};

var get_details_page = function(num, url) {
		$.ajax(url, {type: 'get', data: {InlineResults: 'on'}, dataType: 'text',
			success: function(result) { details_page_loaded(num, result); }});
		return false;
};

/*
var register_details_nav_event = function(elid) {
	var el = document.getElementById(elid);
	if ( ! el ) {
		return;
	}

	var href = el.href.split('?');
	href = href[0];
	var num = href.split('/');
	num = num[num.length-1];
	
	el.onclick = function() {
		$.bbq.pushState("#/" + num);
		return false;
	};
};
*/

var _search_page_content = null;
var _search_page_title = null;
//var _search_page_name = null;
var _search_page_custom_stylesheet = null;
var _search_page_basic_styles = null;
var _search_page_template_styles = null;
var search_page_loaded = function() {
	if (_search_page_content) {
		var current_page_content = $('#body_content');
		if (!current_page_content.find('#results_table').length) {
			current_page_content.replaceWith(_search_page_content);
		}

		var head_node = $('head')[0];

		var custom_style = document.getElementById('custom_style');
		if (custom_style) {
			head_node.removeChild(custom_style);
		}


		set_basic_style(_search_page_basic_styles);
		set_template_style(_search_page_template_styles);

		if ( _search_page_custom_stylesheet ) {
			head_node.appendChild(_search_page_custom_stylesheet);
		}


		document.title = _search_page_title;

		set_body_size();
		fix_map_marker_icons();
		
		setTimeout(function() {
			set_body_size();

			if (last_num) {
				show_map_popup(last_num, true, true, true);
			} else {
				_fake_body.scrollTop(0);
			}
		}, 10);
		
	}
	return false;
};

var show_search_page = function() {
	if (_map_canvas.is(':visible')) {
		search_page_loaded();
		return false;
	}
};

var set_basic_style = function(basic_style_url) {
	var basic_style_node = document.getElementById('basic_style');

	if (basic_style_url !== basic_style_node.href) {
		basic_style_node.href = basic_style_url;
	}

};

var set_template_style = function(template_style_url) {
	var template_style_node = document.getElementById('template_style');

	if (template_style_url !== template_style_node.href) {
		template_style_node.href = template_style_url;
	}

};

var details_page_loaded = function(num, responseText) {
	var current_page_content = $('#body_content');

	var content_start = responseText.indexOf('<div ');
	var paramlist = $.trim(responseText.substr(0,content_start));

	paramlist = paramlist.split('\n');
	var parameters = {};
	for (var p = 0; p < paramlist.length; p++){
		var param = paramlist[p].replace(/\s+$/, '');
		if (param) {
			var key = param.substr(0,param.indexOf('='));
			var value = param.substr(param.indexOf('=')+1);
			parameters[key] = value;
		}
	}

	var parentNode = current_page_content.parent();
	if (current_page_content.is(_search_page_content)) {
		current_page_content.detach();
	} else {
		current_page_content.remove();
	}

	var page_content = responseText.substr(content_start);
	parentNode.html(page_content);

	var head_node = $('head')[0];

	var custom_style = document.getElementById('custom_style');
	if (custom_style) {
		head_node.removeChild(custom_style);
	}

	var basic_style = parameters['basic_stylesheet'];
	set_basic_style(basic_style);

	var template_style = parameters['template_stylesheet'];
	set_template_style(template_style);

	var new_custom_stylesheet = parameters['custom_stylesheet'];
	if ( new_custom_stylesheet ) {
		var style_node = document.createElement('link');
		style_node.rel = 'STYLESHEET';
		style_node.type = 'text/css';
		style_node.id = 'custom_style';
		style_node.href = new_custom_stylesheet;
		head_node.appendChild(style_node);
	}


	document.title = parameters['title'];

	set_body_size();
	$(_fake_body).scrollTop(0);
	add_details_last_visible_class();

	setTimeout(function(num) {
		set_body_size(); 

		show_map_popup(num, false, true, true);

	}, 1, num);
		
};

var show_details_page = function(num, parameters) {
	var href = _search_page_content.find('#details_link_' + num).prop('href');
	if (href) {
		href = href.replace(/^about:/,'');
	} else {
		href = '/record/' + num;
	}

	if ( href ) {
		parameters = parameters || {};
		href = $.param.querystring(href, parameters);
		if (_map_canvas.is(':visible')) {
			get_details_page(num, href);
		} else {
			window.location.href = href;
		}
	}
};

var handleAddressChange = function(evt) {
	var url = evt.fragment;
	var parameters = url.split('?',2);
	url = parameters[0];
	parameters = parameters[1];

	if (url === '/SHOWMAP') {
		if ( !dom_modified || _map_canvas.is(':hidden')) {
			do_map_my_results();
			show_search_page();
		} else {
			show_search_page();
		}
	} else if (url) {
		var path = url.split(':');
		var nomap = path.length > 1 && path[1] === 'NOMAP';
		path = path[0];
		if ( !dom_modified ) {
			do_map_my_results();
		} else {
			show_details_page(path.substr(1), parameters);
			if (nomap) {
				hide_map();
			}
		}
	} else {
		hide_map();
	}
};

var show_details_handler = function() {
	if (_map_container.is(':visible')) {
		var self = $(this), params = self.prop('href').split('?', 2)[1] || '';
		if (params) {
			params = '?' + params;
		}

		$.bbq.pushState('#/' + $(this).data('num') + params);
		return false;
	}
};

var show_search_page_handler = function() {
	if (_map_canvas.is(':visible')) {
		$.bbq.pushState("#/SHOWMAP");
		return false;
	}
};

var change_view_temp_handler = function() {
	var params = $(this).serialize();
	if (params) {
		params = '?' + params;
	}
	var num = this.action.split('?')[0].split('/');
	num = num[num.length - 1];
	$.bbq.pushState('#/' + num + params);
	return false;
};

window['do_check_all_in_viewport'] = function() {
	var bounds = null;
	if (mapped_items && map) {
		bounds = map.getBounds();
	}

	var ml = document.RecordList;
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
		var e = ml.elements[i];
		if (e.name === "IDList") {
			var num = e.value;
			if (mapped_items && map ) {
				var item = mapped_items[num];
				if (item && item.icon && bounds.contains(item.point)) {
					e.checked = true;
					continue;
				}
			}
			e.checked = false;
		}
	}
	return false;
};

var check_visible_markers = $.throttle(200, function() {
	if (mapped_items && map) {
		var bounds = map.getBounds();
		if (!bounds) {
			return;
		}
		var table = _search_page_content.find('#results_table').hide();
		$.each(mapped_items, function(num, item) {
			if (item.icon) {
				if (markers_to_reset[num]) {
					return;
				}

				var last_in_bounds = item.last_in_bounds || false;
				
				if (bounds.contains(item.point)) {
					if (last_in_bounds === false) {
						item.icon.prop('src', map_pins[item.mappin].image_small);
						item.icon.prop('title', map_pins[item.mappin].category);
						item.last_in_bounds = true;
					}
				} else {
					if (last_in_bounds	=== true) {
						item.icon.prop('src', 'images/mapping/mm_0_white_20.png');
						item.last_in_bounds = false;
					}
				}
			}
		});
		table.show().css('display', '');
	}
});

var show_mapping_column = function() {
	_search_page_content.find('#results_table').removeClass('HideMapColumn');
	if($.browser.msie && $.browser.msie < "8.0") {
		_search_page_content.find(".MapColumn").removeClass("FixIE");
	}
};

var hide_mapping_column = function() {
	_search_page_content.find('#results_table').addClass('HideMapColumn');
	if($.browser.msie && $.browser.msie < "8.0") {
		_search_page_content.find(".MapColumn").removeClass("FixIE");
	}
};

var handle_marker_click = make_show_map_popup_handler(true);
var make_marker_click = function(num) {
	return function() {
		handle_marker_click(num);
	};
};

var handle_map_item_click_inner = make_show_map_popup_handler(false);
var handle_map_item_click = function() {
	handle_map_item_click_inner($(this).data('info').num);
};

var sortNumber = function(a,b)
{
	return a - b;
};

var start_mapping = function() {
	//_fake_body_content.hide();
	show_mapping_column();
	_search_page_content.find('#check_all_in_viewport').show();
	//_fake_body_content.show();

	var map_links = _search_page_content.find('.MapLink');
	var bounds = new google.maps.LatLngBounds();
	var legend_items = {0: {image: 'image_small_circle', add_checkbox: false}};
	var allmarkers = [];
	info_window_marker_offset = new google.maps.Size(0,-25);
	info_window_cluster_offset = new google.maps.Size(0,0);
	map_links.each(function() {
		var ml = $(this);

		var item = ml.data('info');
		var num = item.num;

		item.icon = jQuery('#map_marker_icon_' + num + ',#map_marker_icon_mobile_' + num);
		if (!item.icon.length) {
			item.icon = null;
		}
		item.latitude = Globalize.parseFloat(item.latitude);
		item.longitude = Globalize.parseFloat(item.longitude);

		mapped_items[num] = item;
		
		var point = new google.maps.LatLng(item.latitude, item.longitude);
		item.point = point;

		var options = map_pins[item.mappin].options;
		if (!options) {
			options = {
			icon: new google.maps.MarkerImage(map_pins[item.mappin].image,
								new google.maps.Size(15,25)),
			shadow: new google.maps.MarkerImage('images/mapping/mm_shadow.png',
								new google.maps.Size(28,25), null, new google.maps.Point(8,25)),
			//infoWindowAnchor = new GPoint(8,0);
			shape: {coords: [11,0,12,1,13,2,14,3,14,4,14,5,14,6,14,7,14,8,14,9,14,10,14,11,13,12,12,13,11,14,11,15,10,16,10,17,10,18,10,19,9,20,8,21,8,22,8,23,8,24,6,24,6,23,6,22,6,21,6,20,5,19,4,18,4,17,4,16,3,15,3,14,2,13,1,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,1,2,2,1,3,0], type: 'poly'}
			//transparent = 'images/mapping/mm_transparent.png';
			};

			map_pins[item.mappin].options = options;
			legend_items[item.mappin] = {image: 'image_small', add_checkbox: true};
		}

		var markerOptions = $.extend({position: point}, options);

		item.marker = new google.maps.Marker(markerOptions);
		item.marker.num = num;
		allmarkers.push(item.marker);

		bounds.extend(point);
		item.marker_evt = google.maps.event.addListener(item.marker, 'click', make_marker_click(num));

		
		
		
	});
	mgr.addMarkers(allmarkers, 0);

	var pin_ids = [];
	var pin_id;
	for (pin_id in map_pins) {
		pin_ids.push(pin_id);
	}
	pin_ids.sort(sortNumber);
	for (var i = 0; i < pin_ids.length; i++) {
		pin_id = pin_ids[i];
		var legend_item = legend_items[pin_id];
		if (legend_item) {
			_map_position_contol.addCategory(map_pins[pin_id][legend_item.image], map_pins[pin_id].category, parseInt(pin_id, 10), legend_item.add_checkbox);
		}
	}

	$(document).on('click', '.DetailsLink', show_details_handler);
	$(document).on('click', '.SearchTotalLink', show_search_page_handler);
	$(document).on('submit','#change_view_form', change_view_temp_handler);
	$(document).on('click', '.MapLink,.MapLinkMobile', handle_map_item_click);

	zoom_happended = false;
	google.maps.event.addListener(map, 'bounds_changed', check_visible_markers);

	if (map_links.length) {
		//map.setCenter(bounds.getCenter());
		//map.setZoom(map.getBoundsZoomLevel(bounds) - 1);
		map.fitBounds(bounds);
	} else {
		map.setCenter(new google.maps.LatLng(59.888937,-101.601562));
		map.setZoom(2);
	}
	//map.savePosition();

	var geo_latitude = document.getElementById('geo_latitude');
	var geo_longitude = document.getElementById('geo_longitude');
	if (geo_longitude && geo_latitude && geo_longitude.value && geo_latitude.value) {
		var markerOptions = {
			icon: new google.maps.MarkerImage('images/mapping/mm_home.png',
					new google.maps.Size(23,39), null, new google.maps.Point(11,38)),
			shadow: new google.maps.MarkerImage('images/mapping/mm_home_shadow.png',
					new google.maps.Size(43,39)),
			position : new google.maps.LatLng(Globalize.parseFloat(geo_latitude.value), Globalize.parseFloat(geo_longitude.value)),
			clickable: false,
			zIndex: -15000000000
		};
		var marker = new google.maps.Marker(markerOptions);
		marker.setMap(map);
	}
};

var map_center = null;
var resize_start = function() {
	_drag_v_scrollbar_on = vertical_scrollbar_on();
	_drag_h_scrollbar_on = horizontal_scrollbar_on();
	map_center = map.getCenter();
};

var on_resize = $.throttle(100,function() {
	//console.log('here');
	if (map_position === 'Side') {
		_map_canvas.css('width', (_map_container.innerWidth()-_map_drag_cell_side.outerWidth()) + 'px');
	} else {
		_map_canvas.css('height', (_map_container.innerHeight()-_map_drag_cell_bottom.outerHeight()) + 'px');
	}
	set_body_size();
	if (map_center) {
		map.setCenter(map_center);
	}
});

var resize_stop = function(event, ui) {
	_map_canvas.css({'position': 'absolute', 'top': '0px', 'right': '0px'});
	on_resize(event, ui);
	setTimeout(check_visible_markers, 5);
	_drag_v_scrollbar_on = null;
	_drag_h_scrollbar_on = null;

	if (map_position === 'Side') {
		map_size[0] = (_map_container.outerWidth() * 100 / $(window).width()).toFixed(0);
		_map_container.css({top: '', left: '', height: ''});
		_map_canvas.css({top: '', left: '', height: ''});
	} else {
		map_size[1] = (_map_container.outerHeight() * 100 / $(window).height()).toFixed(0);
		_map_container.css({top: '', left: '', width: ''});
		_map_canvas.css({top: '', left: ''});
	}
	save_map_parameters();
};


var dom_modified = false;
var modify_dom = function() {
	var body = $('body');

	var size_checker = $('<div>');
	var body_content = $('#body_content').before(size_checker).hide();
	body_content.find('script').remove();

	// get rid of ie7 forced side scroll bar
	$('html').css('overflow', 'hidden');

	// have to do this here or ie 6 will insert double scrollbar
	// XXX not doing ie 6, should remove!
	body.css({height: '100%'});

	// get outside page spacing
	var win_size = get_win_size();
	var size_checker_pos = size_checker.offset();
	var offsetTop = size_checker_pos.top;
	var offsetLeft = size_checker_pos.left;
	var offsetRight = win_size.width - body.width() - offsetLeft;

	extra_spacing = { height: offsetTop, width: offsetLeft + offsetRight };



	var fake_body = $('<div id="fake_body"></div>').prop('className', 'MapSearchShift MapSearchShift' + map_position).insertBefore(size_checker);

	var fake_body_content = $('<div id="fake_body_content"></div>').
		css('margin', offsetTop + 'px ' + offsetRight + 'px 0px ' + offsetLeft + 'px').appendTo(fake_body);

	size_checker.remove();
		

	var resize_options = {
		start: resize_start,
		stop: resize_stop,
		handles: {w: '#side-handle', n: '#bottom-handle'}
	};
	if (is_ie7) {
		resize_options.helper = "ui-state-default";
		//resize_options.ghost = true;
	} else {
		resize_options.resize = on_resize;
	}
	var map_container = $('<div id="map_container" style="position: absolute;"><div id="side-handle" class="ui-resizable-handle ui-resizable-w"><div id="map_drag_icon_left"></div><div id="map_drag_icon_right" style="position:absolute; top:50%; margin-top: 5px;"></div></div><div id="bottom-handle" class="ui-resizable-handle ui-resizable-n"><div id="map_drag_handle_bottom"><div id="map_drag_icon_up"></div><div id="map_drag_icon_down"></div></div></div><div id="map_canvas" style="position: absolute"></div></div>').
		insertBefore(fake_body);
	$('#map_container').resizable(resize_options);

	// have to do this here or ie 6 will insert double scrollbar
	body.css({'overflow': 'auto', 'margin': '0px'});

	// cache values
	_fake_body = fake_body;
	_fake_body_content = fake_body_content;

	_map_container = map_container;

	var map_canvas = map_container.find('#map_canvas');
	_map_canvas = map_canvas;
	_map_drag_cell_side = $('#side-handle');
	_map_drag_cell_bottom = $('#bottom-handle');

	if (map_position === 'Side') {
		_map_drag_cell_bottom.hide();
	} else {
		_map_drag_cell_side.hide();
	}

	var size = map_position === 'Side' ? parseInt(map_size[0], 10) : parseInt(map_size[1], 10);
	if (size) {
		if ( map_position === 'Side' ) {
			var width = ($(window).width() * size / 100).toFixed(0);
			map_container.css('width', width + 'px');
			map_canvas.css('width', (width - _map_drag_cell_side.outerWidth()) + 'px');
		} else {
			var height = ($(window).height() * size / 100).toFixed(0);
			map_container.css('height', (height + _map_drag_cell_bottom.outerHeight()).toString() + 'px');
			map_canvas.css('height', height + 'px');
		}
	}

	map_canvas[0].className = 'MapSearchResults MapSearchResults'+map_position;
	map_container[0].className = 'MapSearchResults MapSearchResults'+map_position;

	fake_body_content.append(body_content);
	body_content.show();

	set_body_size();

	_search_page_content = body_content;
	_search_page_title = document.title;
	_search_page_custom_stylesheet = document.getElementById('custom_style');
	_search_page_basic_styles = document.getElementById('basic_style').href;
	_search_page_template_styles = document.getElementById('template_style').href;

	dom_modified = true;
};

var do_map_my_results = function() {
	var mp = readCookie('cioc_map_position');
	if (mp) {
		var map_vals = mp.split(',');
		map_position = map_vals[0];
		if (map_vals.length > 1) {
			map_size = [map_vals[1], map_vals[2]];
		}
	}
	do_hide_subjects();
	$('#show_subjects_display').hide();

	if (! dom_modified ) {
		modify_dom();
	} else {
		$('#map_container').show();
	}

	_search_page_content.find('#map_my_results_ui').hide();

	if (map === null) {
		$.getScript('//maps.googleapis.com/maps/api/js?v=3&' + key_arg + '&sensor=false&callback=maps_loaded&language=' + culture);

		return false;

	}

	show_mapping_column();
	$('#check_all_in_viewport').show();
	set_body_size();
	return false;
};

window['initialize_mapping'] = function(options) {
	map_pins = options.map_pins;
	translations = options.translations;
	culture = options.culture;
	key_arg = options.key_arg;

	Globalize.culture(options.culture);

	if (options.auto_start && !(new String(window.location.hash).replace(/^#/, ''))) {
		history.replaceState(null, "", (new String(window.location)).replace(/#$/,'') + '#/SHOWMAP')
	}
	$('#map_my_results_ui').show();

	$(window).bind( 'hashchange', handleAddressChange);

	var form = document.RecordList;
	if ( form ) {
		form.onsubmit = function () {
			if (dom_modified && _map_container.is(':visible')) {
				if (form.action.indexOf('#/SHOWMAP') === -1) {
					form.action = form.action + '#/SHOWMAP';
				}
			} else {
				if (form.action.indexOf('#/SHOWMAP') !== -1) {
					form.action = form.action.substr(0,form.action.length-'#/SHOWMAP'.length);
				}
			}
		};
	}

	$(window).trigger('hashchange');
};
})(jQuery, this, document);
