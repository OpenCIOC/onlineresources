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

var searchMode = 1;

function windowOnLoad() {
	searchFrameObj = document.getElementById("searchFrame");
	searchFrameObj.height = frameHeight;

	buildList.span = document.getElementById("BuildTermList")
	linkList['All'].span = document.getElementById("MustMatchTermList")
	linkList['Any'].span = document.getElementById("MatchAnyTermList")
	
	suggestDiv = document.getElementById("SuggestDiv");
	selectDiv = document.getElementById("SelectDiv");
	
	linkList['All'].copyLinkList(linkListOrig['All']);
	linkList['Any'].copyLinkList(linkListOrig['Any']);
	
	fillBuildList();
	fillLinkList('All');
	fillLinkList('Any');
}

window.onload = windowOnLoad;

linkList['All'] = new LinkListObj();
linkList['Any'] = new LinkListObj();

linkListOrig['All'] = new LinkListObj();
linkListOrig['Any'] = new LinkListObj();

function clearLists() {
	clearBuildList();
	clearLinkList('All');
	clearLinkList('Any');
}

function submitForm(actionType) {
	if (actionType == "AdvancedSearch") {
		document.Search.action = "advsrch.asp";
	} else {
		document.Search.action = "results.asp";
	}
	
	var mustMatchInput = document.getElementById("MustMatchInput");
	var matchAnyInput = document.getElementById("MatchAnyInput");
	
	var mustMatchLinks = linkList['All'].links;
	var matchAnyLinks = linkList['Any'].links;
	
	var linkSet;
	var linkTerm ;
	var mustMatchInputValue = '';
	var matchAnyInputValue = '';
	var linkSetCon = '';
	var linkTermCon = '';
	
	for (linkSet in mustMatchLinks) {
		mustMatchInputValue = mustMatchInputValue + linkSetCon;
		for (linkTerm in mustMatchLinks[linkSet]) {
			mustMatchInputValue = mustMatchInputValue + linkTermCon + mustMatchLinks[linkSet][linkTerm].code;
			linkTermCon = '~';
		}
		linkTermCon = '';
		linkSetCon = ',';
	}
	mustMatchInput.value = mustMatchInputValue;
	
	linkSetCon = '';
	linkTermCon = '';
	
	for (linkSet in matchAnyLinks) {
		matchAnyInputValue = matchAnyInputValue + linkSetCon;
		for (linkTerm in matchAnyLinks[linkSet]) {
			matchAnyInputValue = matchAnyInputValue + linkTermCon + matchAnyLinks[linkSet][linkTerm].code;
			linkTermCon = '~';
		}
		linkTermCon = '';
		linkSetCon = ',';
	}
	matchAnyInput.value = matchAnyInputValue;
	
	if (hasSelectedTerms()) {
		$(document.Search).submit();
		return true;
	} else {
		alert(noneChosen);
		return false;
	}
}

function resetForm() {
	clearBuildList();
	resetLinkList('All');
	resetLinkList('Any');
}
