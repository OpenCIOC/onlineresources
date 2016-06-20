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

CIOC['initFindAndReplaceCheckList'] = (function () {
	CIOC['frChk'] = {};
	var $ = jQuery;
	var checkListAddInst = '';
	var checkListNoteInst = '';
	var noteHTML = '';

	var clearCheckListChoice = function () {
		document.getElementById('CheckListType').selectedIndex = 0;
		document.getElementById('CheckListItem1Block').innerHTML = '&nbsp;';
		document.getElementById('CheckListItem2Block').innerHTML = '&nbsp;';
		document.getElementById('CheckListNoteBlock').innerHTML = checkListNoteInst;
		validateFindReplace();
	}

	var fillNoteBlock = function () {
		var clType = document.getElementById('CheckListType').value;
		var has_note_types = ['ac', 'cm', 'fd', 'ft', 'ln', 'scha', 'sche', 'sm', 'toc'];
		var has_note = false;
		for (var i = 0; i < has_note_types.length; i++) {
			if (has_note_types[i] == clType) {
				has_note = true;
				break;
			}
		}
		var chk1 = document.getElementById('CheckListItem1');
		var chk2 = document.getElementById('CheckListItem2');
		if (has_note && ((chk1 && chk1.selectedIndex == 0 && chk2 && chk2.selectedIndex != 0) || clType == 'sm')) {
			if (!document.getElementById('CheckListNote')) {
				document.getElementById('CheckListNoteBlock').innerHTML = noteHTML
			}
		} else {
			document.getElementById('CheckListNoteBlock').innerHTML = checkListNoteInst
		}
	}

	var validateFindReplace = function () {
		var chk1 = document.getElementById('CheckListItem1');
		var chk2 = document.getElementById('CheckListItem2');
		var clType = document.getElementById('CheckListType').value;
		fillNoteBlock();
		enableReplaceButton();
		if (clType == 'sm') {
			if (chk1.selectedIndex != 0) {
				chk2.selectedIndex = 0
				$('#CheckListItem2Row').hide();
				$('#CheckListNoteRow').hide();
			} else if (chk2.selectedIndex != 0) {
				$('#CheckListItem1Row').hide();
			} else {
				$('#CheckListItem1Row').show();
				$('#CheckListItem2Row').show();
				$('#CheckListNoteRow').show();
			}
		}
	}

	var enableReplaceButton = function () {
		//console.log('enableReplaceButton');
		var chk1 = document.getElementById('CheckListItem1');
		var chk2 = document.getElementById('CheckListItem2');
		var clType = document.getElementById('CheckListType').value;
		if (document.getElementById('CheckListType').selectedIndex == 0) {
			document.getElementById('ReplaceButton').disabled = true;
		} else if (chk1 && chk2 && chk1.selectedIndex == chk2.selectedIndex) {
			document.getElementById('ReplaceButton').disabled = true;
		} else if (!((chk1 && chk1.selectedIndex != 0) || (chk2 && chk2.selectedIndex != 0))) {
			document.getElementById('ReplaceButton').disabled = true;
		} else if (clType == 'sm' && chk2 && chk2.selectedIndex != 0 && ((chk1 && chk1.selectedIndex != 0) || !document.getElementById('CheckListNote').value)) {
			document.getElementById('ReplaceButton').disabled = true;
		} else {
			document.getElementById('ReplaceButton').disabled = false;
		}
	}

	return function (add_inst, note_inst, note_html) {
		checkListAddInst = add_inst;
		checkListNoteInst = note_inst;
		noteHTML = note_html;

		var chk_type = $("#CheckListType").change(function (e) {
			var innerHTML = chk_type.find('option:selected').data('optui');
			if (innerHTML) {
				if (document.getElementById('CheckListType').value != 'sm') {
					$('#CheckListItem1Row').show();
					$('#CheckListItem2Row').show();
					$('#CheckListNoteRow').show();
					$('#LookForTextBlock').show();
					$('#ReplaceWithTextBlock').show();
					$('#NoteTextBlock').show();
					$('#URLTextBlock').hide();
				} else {
					$('#LookForTextBlock').hide();
					$('#ReplaceWithTextBlock').hide();
					$('#NoteTextBlock').hide();
					$('#URLTextBlock').show();
				}
				$("#CheckListItem1Block").html(innerHTML);
				$("#CheckListItem2Block").html(checkListAddInst + innerHTML.replace(/CheckListItem1/g, "CheckListItem2"));
				fillNoteBlock();
			} else {
				clearCheckListChoice();
			}
		});
		$(document).on('paste keyup', '#CheckListNote', enableReplaceButton);
		$(document).on('select change', '#CheckListItem1Block, #CheckListItem2Block', validateFindReplace);
		clearCheckListChoice();
	}
})();


CIOC['initFindAndReplaceName'] = (function() {
	var nameSelectInst = '';
	var nameChangeInst = '';

	function clearNameFieldChoice() {
		document.getElementById('NameField').selectedIndex = 0;
		document.getElementById('ReplaceWith').innerHTML = '&nbsp;';
	}

	function validateFindReplace() {
		if (document.getElementById('NameField').selectedIndex == 0) {
			alert(nameSelectInst);
			return false;
		} else if (document.getElementById('FindText').value == document.getElementById('ReplaceText').value) {
			alert(nameChangeInst);
			return false;
		} else {
			return true;
		}
	}

	return function(select_inst, change_inst) {
		nameSelectInst = select_inst;
		nameChangeInst = change_inst;

		clearNameFieldChoice();
		$("#NameForm").submit(validateFindReplace);
		var name_field = $("#NameField").change(function() {
			var innerHTML = name_field.find('option:selected').data('replacewithui') || '&nbsp;';
			$('#ReplaceWith').html(innerHTML);
		});
	}
})();
