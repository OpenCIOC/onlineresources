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

(function(undefined) {
	var $ = jQuery;
	var attr_or_scrape_extraction = function(node) {
		var n = $(node), val = n.data('tblKey');
		//console.log(n.text())
		return val !== undefined ? val : n.text();
	};
	$(function() {
		
		$('.sortable_table').each(function() {
			var opts = {textExtraction: attr_or_scrape_extraction}

			var item = $(this);
			var disabled = item.data('sortdisabled');
			if (disabled) {
				//disabled = eval(disabled);
				var hdrs = {}; 
				opts.headers = hdrs;

				jQuery.each(disabled, function(i, val) { hdrs[val] = {sorter: false}; });

			}
			var defaultSort = item.data('defaultSort');
			if (defaultSort) {
				//defaultSort = eval(defaultSort);
				//opts.sortForce = [defaultSort];
				opts.sortList = [defaultSort];
			}

			item.tablesorter(opts);
		});
	});
})();
