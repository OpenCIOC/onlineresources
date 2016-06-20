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

(function($) {
	$.widget("ui.combobox", {
		options: {
			source:null
		},
		_create: function() {
			var self = this;
			var input = this.element;
			// only do something special if we have options
			if (this.options.source) {
				$(input).autocomplete({
						focus:function(e,ui) {
							return false;
						},
						source: self.options.source,
						delay: 0,
						minLength: 0
					})
				$("<span>")
				.insertAfter(input)
				.addClass("SmallButton DownButton")
				.css('margin-left', '1px')
				.click(function(e) {
					// close if already visible
					if (input.autocomplete("widget").is(":visible")) {
						input.autocomplete("close");
						return;
					}
					// pass empty string as value to search for, displaying all results
					input.autocomplete("search", "");
					input.focus();
				});
			}
		}
	});

})(jQuery);
		

