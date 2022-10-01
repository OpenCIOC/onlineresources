# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

SCRIPTS :=  \
	admin.js \
	advsrch.js \
	bsearch.js \
	checklists.js \
	community.js \
	copy.js \
	ciocbasic.js \
	datepicker.js \
	details.js \
	diff_match_patch.js \
	entryform.js \
	feedback.js \
	findreplace.js \
	generalheading.js \
	publication.js \
	geocode.js \
	history.js \
	mapiconmaker.js \
	markerclusterer.js \
	printmap.js \
	referralsearch.js \
	reminders.js \
	results.js \
	tablesort.js \
	tax.js \
	taxrecords.js \
	taxsrch.js \
	ventryform.js \
	vfeedback.js \
	vprofiles.js \
	search_params.js

	# displayField.js \
	findReplaceChecklist.js \
	findReplaceName.js \
	formNewWindow.js \
	formPrintMode.js \
	savedSearchInfo.js \
	taxAdvSearch.js \
	taxBuildList.js \
	taxIndex.js

.PHONY: default clean cleancomposit
	#debug release

default: ../python/cioc/core/assetversions.json

%.min.js: %.js
	java -jar c:/bin/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js $< --create_source_map ./$<.map --source_map_format=V3 --js_output_file $@
	unix2dos $@

admin.js: ciocbasic.js jquery.bgiframe.js autocomplete.js autocomplete_extra.js entryform_common.js admin_base.js
	type $^ > $@

advsrch.js: ciocbasic.js jquery.bgiframe.js formNewWindow.js autocomplete.js keyword_autocomplete.js advsrch_base.js globalize.js mapcommon.js mapsearch.js search_params.js
	type $^ > $@

bsearch.js: ciocbasic.js jquery.bgiframe.js jquery.blockUI.js formNewWindow.js globalize.js autocomplete.js keyword_autocomplete.js bsearch_base.js mapcommon.js mapsearch.js search_params.js vacancy_base.js
	type $^ > $@

checklists.js: ciocbasic.js json2.js autocomplete.js checklists_base.js
	type $^ > $@

ciocbasic.js: core.js checkAll.js mylist.js json2.js cached_state.js autodatepicker.js
	type $^ > $@

community.js: ciocbasic.js jquery.bgiframe.js autocomplete.js autocomplete_extra.js entryform_common.js checklists_base.js community_base.js
	type $^ > $@

copy.js: ciocbasic.js jquery.validate.js copy_base.js
	type $^ > $@

datepicker.js: ciocbasic.js
	type $^ > $@

details.js: ciocbasic.js jquery.bgiframe.js jquery.validate.js jquery.ba-throttle-debounce.js jquery.blockUI.js autocomplete.js autocomplete_extra.js reminders_common.js details_base.js vacancy_base.js related_record_sidebar_base.js
	type $^ > $@

entryform.js: ciocbasic.js jquery.bgiframe.js jquery-ui-combobox.js jquery.validate.js globalize.js mapcommon.js mapentryform.js history.js autocomplete.js autocomplete_extra.js entryform_common.js copy_base.js feedback_base.js record_note.js entryform_base.js province-combo.js
	type $^ > $@

feedback.js: ciocbasic.js globalize.js mapcommon.js mapentryform.js jquery-ui-combobox.js province-combo.js autocomplete.js autocomplete_extra.js entryform_common.js feedback_base.js
	type $^ > $@

findreplace.js: ciocbasic.js findandreplace_base.js
	type $^ > $@

generalheading.js: ciocbasic.js jquery.bgiframe.js autocomplete.js iconautocomplete.js generalheading_base.js
	type $^ > $@

publication.js: ciocbasic.js jquery.bgiframe.js autocomplete.js iconautocomplete.js
	type $^ > $@

geocode.js: ciocbasic.js  globalize.js geocode_base.js
	type $^ > $@

printmap.js: ciocbasic.js markerclusterer.js globalize.js printmap_base.js
	type $^ > $@

referralsearch.js: tablesort.js referralsearch_base.js
	type $^ > $@

reminders.js: ciocbasic.js jquery.bgiframe.js jquery.validate.js jquery.ba-throttle-debounce.js autocomplete.js autocomplete_extra.js reminders_common.js
	type $^ > $@

results.js: ciocbasic.js markerclusterer.js globalize.js jquery.ba-scrollbarwidth.js jquery.ba-bbq.js jquery.ba-throttle-debounce.js jquery.blockUI.js results_base.js vacancy_base.js related_record_sidebar_base.js
	type $^ > $@

tablesort.js: ciocbasic.js jquery.tablesorter.js tablesort_base.js
	type $^ > $@

tax.js: ciocbasic.js autocomplete.js tax_base.js
	type $^ > $@

taxrecords.js: bsearch.js tax_base.js
	type $^ > $@

taxsrch.js: ciocbasic.js jquery.bgiframe.js autocomplete.js search_params.js
	type $^ > $@

ventryform.js: ciocbasic.js jquery-ui-combobox.js jquery.bgiframe.js autocomplete.js autocomplete_extra.js feedback_base.js entryform_common.js ventryform_base.js record_note.js history.js copy_base.js
	type $^ > $@

vfeedback.js: ciocbasic.js jquery-ui-combobox.js jquery.bgiframe.js autocomplete.js autocomplete_extra.js feedback_base.js entryform_common.js ventryform_base.js 
	type $^ > $@

vprofiles.js: tablesort.js cached_state.js vprofiles_base.js
	type $^ > $@

../python/cioc/core/assetversions.json: $(patsubst %.js,%.min.js, $(SCRIPTS)) ../styles/*.css
	python build_versions.py $(patsubst %.min.js,%.js, $^) > $@


cleancomposit:
	rm -rf entryform.js bsearch.js ventryform.js

clean: cleancomposit
	rm -rf $(patsubst %.js,%.min.js, $(SCRIPTS))
