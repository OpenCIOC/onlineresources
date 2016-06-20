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
	var add_details_last_visible_class = function() {
		$('.agency-overview').each(function() {
			$(this).find('.related-row:visible').last().addClass('last-visible');
		});
	};
	window['initialize_listing_toggle'] = function(show_listings_txt, hide_listings_txt, show_deleted_txt, hide_deleted_txt) {
		$(document).on('click', '.show-toggle', function() {
			var self = $(this);
			var related_records = self.parents('.related-records');
			var details = related_records.find('.details');
			var agency_overview = related_records.parents('.agency-overview');
			if (details.is(':visible')) {
				details.slideUp(function(){
					self.text(show_listings_txt);
					agency_overview.find('.related-row').removeClass('last-visible').filter(':visible').last().addClass('last-visible');
				});
			} else {
				var related_rows = agency_overview.find('.related-row').removeClass('last-visible');
				details.slideDown(function(){
					self.text(hide_listings_txt);
					related_rows.filter(':visible').last().addClass('last-visible');
				});
			}
			return false;
		}).on('click', '.deleted-toggle', function() {
			var self = $(this);
			var related_records = self.parents('.related-records');
			var details = related_records.find('.deleted-records');
			var agency_overview = related_records.parents('.agency-overview');
			if (details.is(':visible')) {
				details.slideUp(function(){
					self.text(show_deleted_txt);
					agency_overview.find('.related-row').removeClass('last-visible').filter(':visible').last().addClass('last-visible');
				});
			} else {
				var related_rows = agency_overview.find('.related-row').removeClass('last-visible');
				details.slideDown(function(){
					self.text(hide_deleted_txt);
					related_rows.filter(':visible').last().addClass('last-visible');
				});
			}
			return false;
		});
		add_details_last_visible_class();
	};

	window['add_details_last_visible_class'] = add_details_last_visible_class;

})();
