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
/*global string_ci_ai:true create_caching_source_fn:true */
var $ = jQuery;
function keyword_cache_search_fn(cache) {
	return function (request, response) {
		if (cache.term && (new RegExp($.ui.autocomplete.escapeRegex(cache.term), "i")).test(request.term) && cache.content && cache.content.length < 13 && cache.content.length > 1) {
			var matchers = [];
			var terms = request.term.split(/\s+/);
			for (var i = 0; i < terms.length; i++) {
				if (terms[i]) {
					matchers.push(new RegExp($.ui.autocomplete.escapeRegex(terms[i]), "i"));
				}
			}
			
			response($.grep(cache.content, function(value) {
				var retval = true;
				value = string_ci_ai(value.value);
				for (var i = 0; i < matchers.length; i++) {
					retval = retval && matchers[i].test(value);
					if (! retval) {
						return false;
					}
				}
				return retval;
			}));
			return true;
		}

		return false;
	};
}
var init_find_box = function(urls, search_form) {
	var cache = {},
		rquery = /\?/,
		cache_search_fn = keyword_cache_search_fn(cache),
		source = create_caching_source_fn($, null, cache, null, cache_search_fn),
		input_box = $('#STerms').autocomplete({
		focus: function() {
			return false;
		},
		source: function (request, response) {
			var typeval = $('input[name=SType]:checked').prop('value');
			var url = urls[typeval];
			if (!url) {
				// not a completable type
				return;
			}
			if (cache.type && cache.type !== typeval) {
				delete cache.type;
				delete cache.term;
				delete cache.content;
			}
			source(request, function(data) {
				cache.type = typeval;
				response(data);
			}, url);
			
		},
		minLength: 4
		});

	search_form = search_form || $('#SearchForm');
	search_form.on('submit', function() {
		var orig_value = null, query_string = null, action = null,
			testvalue, values ;
		if (!cache.content) {
			return;
		}
		testvalue = string_ci_ai(input_box[0].value);
		values = $.grep(cache.content, function(value) {
			return string_ci_ai(value['value']) === testvalue;
		});
		if (values.length !== 1 || !values[0].quote) {
			return;
		}

		orig_value = input_box[0].value;
		input_box[0].value = '"' + orig_value + '"';
		query_string = search_form.serialize();
		input_box[0].value = orig_value;

		action = search_form.prop('action');
		action += (rquery.test(action) ? "&" : "?") + query_string;

		window.location.href = action;
		return false;
	});
};
window["init_find_box"] = init_find_box;
})();
