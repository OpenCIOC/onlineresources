<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<%
Dim aLetters(27), indLetter

Public Function makeAlphaList(strChosenLetter, bIncludeNums, strlinkURL, bShowAll)
	Dim intLetterCount
	Dim strLetters
	Dim strCon
	
	strCon = vbNullString

	If bIncludeNums Then
		aLetters(0) = "0-9"
		For intLetterCount = 0 to 25
			aLetters(intLetterCount+1) = Chr(Asc("A") + intLetterCount)
		Next
	Else
		For intLetterCount = 0 to 25
			aLetters(intLetterCount) = Chr(Asc("A") + intLetterCount)
		Next
		aLetters(26) = vbNullString
	End If

	For Each indLetter in aLetters
		If indLetter <> strChosenLetter And Not Nl(indLetter) Then
			strLetters = strLetters & strCon & "<a href=""" & _
				makeLink(strlinkURL,"Let=" & indLetter,vbNullString) & _
				"""><div class=""browse-by-item"">" & indLetter & "</div></a>"
			strCon = " "
		ElseIf Not Nl(indLetter) Then
			strLetters = strLetters & strCon & "<div class=""browse-by-item-highlight"">" & indLetter & "</div>"
			strCon = " "
		End If
	Next

	If bShowAll Then
		If Nl(strChosenLetter) Then
			strLetters = strLetters & strCon & "<div class=""browse-by-item-highlight"">" & TXT_SHOW_ALL & "</div>"
		Else
			strLetters = strLetters & strCon & "<a href=""" & makeLinkB(strlinkURL) & """><div class=""browse-by-item"">" & TXT_SHOW_ALL & "</div></a>"
		End If
	End If
	makeAlphaList = "<div class=""clearfix""><div class=""browse-by-list"">" & TXT_SELECT_LETTER & "<br>" & strLetters & "</div></div>"
End Function
%>
