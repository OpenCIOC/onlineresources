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

/*global cache_register_onbeforeunload:true cache_register_onbeforerestorevalues:true init_cached_state:true restore_cached_state:true */
(function($) {

	window['init_general_heading_icons'] = function(url, input_el) {
		input_el = input_el || $('#generalheading_IconNameFull');
		//console.log(input_el);
		input_el.autocomplete({
			focus:function(event,ui) {
				return false;
			},
			source: create_caching_source_fn($,url),
			minLength: 3}).
		keypress(function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				input_el.autocomplete('close');
			}
		});
		input_el.data('autocomplete')._renderItem = function( ul, item ) {
			return $( "<li></li>" )
				.data( "item.autocomplete", item )
				.append( $( "<a></a>" ).text(item.label + ' ')
						.append($(' <span></span>').addClass(item.label + ' ' + item.class_extra)) )
				.appendTo( ul );
		};
	};

})(jQuery);
