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

var searchMode = 3;

function windowOnLoad() {
	searchFrameObj = document.getElementById("searchFrame");
	searchFrameObj.height = frameHeight;

	buildList.span = document.getElementById("BuildTermList")
	linkList['Index'].span = document.getElementById("IndexTermList")
	
	suggestDiv = document.getElementById("SuggestDiv");
	selectDiv = document.getElementById("SelectDiv");
	
	linkList['Index'].copyLinkList(linkListOrig['Index']);
	
	fillBuildList();
	fillLinkList('Index');
}

window.onload = windowOnLoad;

linkList['Index'] = new LinkListObj();
linkListOrig['Index'] = new LinkListObj();

function clearLists() {
	clearBuildList();
	clearLinkList('Index');
}

function submitForm(actionType) {
	var indexInput = document.getElementById("IndexInput");
	
	var indexLinks = linkList['Index'].links
	
	var linkSet = 0;
	var linkTerm = 0;
	var indexInputValue = '';
	var linkSetCon = '';
	var linkTermCon = '';
	
	for (linkSet = 0; linkSet < indexLinks.length; linkSet++) {
		indexInputValue = indexInputValue + linkSetCon
		for (linkTerm = 0; linkTerm < indexLinks[linkSet].length; linkTerm++) {
			indexInputValue = indexInputValue + linkTermCon + indexLinks[linkSet][linkTerm].code;
			linkTermCon = '~';
		}
		linkTermCon = '';
		linkSetCon = ',';
	}
	if (indexInput) {
		indexInput.value = indexInputValue;
	}
	
	if (hasSelectedTerms()) {
		document.Search.submit();
		return true;
	} else {
		var okBlank = confirm(noneChosen);
		if (okBlank) {
			document.Search.submit();
			return true;
		} else {
			return false;
		}
	}
}

function resetForm() {
	clearBuildList();
	resetLinkList('Index');
}
