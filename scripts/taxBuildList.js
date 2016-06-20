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

var frameHeight = screen.height * 0.75 - 100 - (parseFloat(navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1]) >= 0.1? 70 : 0);

var linkList = [];
var linkListOrig = [];
var buildList = new BuildListObj();
var searchFrameObj = null;
var selectDiv = null;
var suggestDiv = null;

function sortLinkList(a, b) {
	left = a[0].term.toLowerCase();
	right = b[0].term.toLowerCase();
	if (left < right) { return (-1); }
	if (left > right) { return (1); }
	return 0;
}

function sortTermList(a, b) {
	left = a.code;
	right = b.code;
	if (left < right) { return (-1); }
	if (left > right) { return (1); }
	return 0;
}

function contains(code) {
	for (j in this.terms) if (this.terms[j].code == code) return true;
	return false;
}

function copyTerm() {
	return new TermObj(this.code, this.term);
}

function copyLinkList(toList) {
	var linkSet;
	var linkTerm;

	toList.links = new Array();
	for (linkSet in this.links) {
		toList.links[linkSet] = new Array();
		for (linkTerm in this.links[linkSet]) {
			toList.links[linkSet][linkTerm] = this.links[linkSet][linkTerm];
		}
	}
}

function copyFromList(fromList) {
	var linkSet;
	var linkTerm;

	this.terms = new Array();
	for (linkTerm in fromList) {
		this.terms[linkTerm] = fromList[linkTerm].copy();
	}
}

function clearTermCode(code) {
	var linkTerm, term, oldTerms;
	oldTerms = this.terms;
	this.terms = [];
	for (linkTerm in oldTerms) {
		if (oldTerms[linkTerm].code !== code) {
			this.terms.push(oldTerms[linkTerm]);
		}
	}
}

function clearTerms() {
	this.terms = new Array();
	if (this.span != null) {
		this.span.innerHTML = noTerms
	}
	return true;
}

function clearLinks() {
	this.links = new Array();
	if (this.span != null) {
		this.span.innerHTML = noTerms
	}
	return true;
}

function LinkListObj() {
	this.links = null;
	this.span = null;
	this.copyLinkList = copyLinkList;
	this.clearLinks = clearLinks;
	this.clearLinks();
}

function BuildListObj() {
	this.span = null;
	this.copyFromList = copyFromList;
	this.contains = contains;
	this.clearTerms = clearTerms;
	this.clearTermCode = clearTermCode;
	this.clearTerms();
}

function TermObj(code, term) {
	this.code = code;
	this.term = term;
	this.copy = copyTerm;
}

function hasSelectedTerms() {
	for (var i in linkList) {
		if (linkList[i].links.length > 0) {
			return true;
		}
	}
	return false;
}

function addBuildTerm(code, term) {
	if (!buildList.contains(code)) {
		buildList.terms[buildList.terms.length] = new TermObj(code,term);	
		fillBuildList();
	}
}

function removeLinkListItem(listType, i) {
	linkList[listType].links.splice(i, 1);
	fillLinkList(listType);
}

function sendBuildToLinkList(listType) {
	if (buildList.terms.length > 0) {
		linkList[listType].links[linkList[listType].links.length] = buildList.terms;
		fillLinkList(listType);
		clearBuildList();
	}
}

function sendLinkToBuildList(listType, i) {
	buildList.copyFromList(linkList[listType].links[i]);
	fillBuildList();
}

function clearBuildListTerm(code) {
	buildList.clearTermCode(code);
	if (!buildList.terms) {
		buildList.clearTerms();
		selectDiv.style.display = 'none';
		suggestDiv.style.display = 'none';
	} else {
		fillBuildList();
	}

	return false;
}

function clearBuildList() {
	buildList.clearTerms();
	selectDiv.style.display = 'none';
	suggestDiv.style.display = 'none';
}

function clearLinkList(listType) {
	linkList[listType].clearLinks();
}

function resetLinkList(listType) {
	linkListOrig[listType].copyLinkList(linkList[listType]);
	fillLinkList(listType);
}

function fillBuildList() {
	var linkTerm;
	var listValue = '';
	var linkTermCon = '';
	var term;
	
	buildList.terms.sort(sortTermList);
	
	for (linkTerm in buildList.terms) {
		term = buildList.terms[linkTerm];
		listValue = listValue + linkTermCon + '<span id="build-list-' + term.code + '">' + term.term + '&nbsp;<a href="#javascript" onClick="clearBuildListTerm(\'' + buildList.terms[linkTerm].code + '\');">' + xImage + '</a></span>';
		linkTermCon = ' ~ ';
	}

	if (buildList.terms.length > 0) {
		buildList.span.innerHTML = listValue;
		selectDiv.style.display = 'inline';
		suggestDiv.style.display = 'inline';
	} else {
		buildList.span.innerHTML = noTerms;
		selectDiv.style.display = 'none';
		suggestDiv.style.display = 'none';
	}
}

function fillLinkList(listType) {
	var linkTermList = linkList[listType].links;
	var listSpan = linkList[listType].span;

	var linkSet;
	var linkTerm;
	var listValue = '';
	var linkSetCon = '';
	var linkTermCon = '';

	linkTermList.sort(sortLinkList);

	for (linkSet in linkTermList) {
		listValue = listValue + linkSetCon + '<li>'
		for (linkTerm in linkTermList[linkSet]) {
			listValue = listValue + linkTermCon + linkTermList[linkSet][linkTerm].term;
			linkTermCon = ' ~ ';
		}
		listValue = listValue + '&nbsp;<a href="#javascript" onClick="sendLinkToBuildList(\'' + listType + '\',' + linkSet + ')">' + eImage + '</a>' +
			'&nbsp;<a href="#javascript" onClick="removeLinkListItem(\'' + listType + '\',' + linkSet + ')">' + xImage + '</a></li>'
		linkTermCon = '';
		linkSetCon = '\r';
	}
	if (listValue != '') {
		listSpan.innerHTML = '<ul>' + listValue + '</ul>';
	} else {
		listSpan.innerHTML = noTerms;
	}
}

function suggestTerm() {
	var displayValue = '';
	var displayCon = '';
	var listValue = '';
	var linkTermCon = '';
	
	for (linkTerm in buildList.terms) {
		listValue = listValue + linkTermCon + buildList.terms[linkTerm].code;
		linkTermCon = ',';

		displayValue = displayValue + displayCon + buildList.terms[linkTerm].term;
		displayCon = ' ~ ';
	}

	searchFrame.location.href = suggestURL + 'MD=' + searchMode + '&ST=5&TC=' + listValue + '&TCD=' + escape(displayValue);
}

function suggestLink() {
	var displayValue = '';
	var displayCon = '';
	var listValue = '';
	var linkTermCon = '';
	
	for (linkTerm in buildList.terms) {
		listValue = listValue + linkTermCon + buildList.terms[linkTerm].code;
		linkTermCon = ',';

		displayValue = displayValue + displayCon + buildList.terms[linkTerm].term;
		displayCon = ' ~ ';
	}

	searchFrame.location.href = suggestURL + 'MD=' + searchMode + '&ST=4&TC=' + listValue + '&TCD=' + escape(displayValue);
}
