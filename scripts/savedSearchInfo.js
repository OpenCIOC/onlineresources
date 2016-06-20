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

function savedSearchObj(sName,sMod,sOwner,sNotes) {
	this.name = sName;
	this.mod = sMod;
	this.owner = sOwner;
	this.notes = sNotes;
}

var searchList = new Array();
searchList['P'] = new Array();
searchList['S'] = new Array();

function newSavedSearchList(sType) {
	searchList[sType] = new Array();
}

function newSavedSearch(sType,sID,sName,sMod,sOwner,sNotes) {
	searchList[sType][sID] = new savedSearchObj(sName,sMod,sOwner,sNotes);
}

function changeList(sType,listObj,inclOwner) {
	var sID = listObj.options[listObj.selectedIndex].value;
	
	var notesObj = document.getElementById(sType + 'Notes');
	var modObj = document.getElementById(sType + 'Mod');

	if (inclOwner) { 
		var ownerObj = document.getElementById(sType + 'Owner');
	}

	if (sID != null && sID != '') {
		if (inclOwner) { 
			ownerObj.value = searchList[sType][sID].owner;
		}
		notesObj.value = searchList[sType][sID].notes;
		modObj.value = searchList[sType][sID].mod;
	} else {
		if (inclOwner) { 
			ownerObj.value = '';
		}
		notesObj.value = '';
		modObj.value = '';
	}
}
