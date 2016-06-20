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
'
' Purpose:		Add or remove a code or classification from the given set of Organization/Program records.
'				This file is part of the processing performed in the Process Record List utility file.
'
%>
<%
Select Case strActionType

	'###################
	' DISTRIBUTION
	'###################
	Case "DST"
%><h2><%=TXT_ADD_REMOVE_DISTRIBUTION%></h2><%
		Call openDistListRst(False)
		strDropDownContents = makeDistTableList("ActionID")
		Call closeDistListRst()

	'###################
	' PUBLICATION
	'###################
	Case "PB"
%><h2><%=TXT_ADD_REMOVE_PUBLICATION%></h2>
<p><span class="AlertBubble"><%=TXT_INST_ADD_PUB%></span></p><%
		Call openPubListRst(False, False)
		strDropDownContents = makePubTableList("ActionID", True, IIf(rsListPub.RecordCount > 14, IIf(rsListPub.RecordCount > 50,3,2), 1), vbNullString)
		Call closePubListRst()

	'###################
	' GENERAL HEADING
	'###################
	Case "GH"
%><h2><%=TXT_ADD_REMOVE_HEADING%></h2><%
		If Nl(intPBID) Then
%><p class="Info"><%=TXT_INST_ADD_HEADING_1%></p>
<%			If g_bUseTaxonomy Then%>
<p><span class="AlertBubble"><%=TXT_INST_ADD_HEADING_2%></span></p>
<%			End If%>
<%
			Call openPubListRst(True, True)
			strDropDownContents = makePubList(vbNullString,vbNullString,"PBID",vbNullString,True,False,False)
			Call closePubListRst()
		Else
			Call openGenHeadingListRst(intPBID, True, True, True)
			If Nl(strListGenHeadingPub) Then
				intPBID = Null
				Call openPubListRst(True, True)
				strDropDownContents = makePubList(vbNullString,vbNullString,"PBID",vbNullString,True,False,False)
				Call closePubListRst()
			Else
				strDropDownContents = makeGenHeadingTableList("ActionID", IIf(rsListGenHeading.RecordCount > 14, 2, 1), vbNullString)
			End If

			Call closeGenHeadingListRst()
			
			If Not Nl(intPBID) And Not user_bLimitedViewCIC Then
				Call openPubListRst(True, True)
				strDropDownContents = strDropDownContents & "</p><p><em>" & TXT_OR & "</em></p>" & _
					"<p><strong>" & TXT_SYNCHRONIZE_WITH_PUB & "</strong><br>" & _
					makePubList(vbNullString,intPBID,"SynchID",vbNullString,True,True,False) & _
					"</p><p>"
				Call closePubListRst()
			End If
		End If
	
	'###################
	' NAICS CODE
	'###################
	Case "NC"
%><h2><%=TXT_ADD_REMOVE_NAICS%></h2>
<p class="Info"><%=TXT_INST_ADD_NAICS%><%
		strDropDownContents = "<input type=""Text"" size=""6"" maxlength=""6"" name=""ActionID""> [ <a href=""javascript:openWin('" & makeLinkB("naicsfind.asp") & "','sFind')"">" & TXT_NAICS_FINDER & "</a> ]"

	'###################
	' SUBJECT
	'###################
	Case "SBJ"
%><h2><%=TXT_ADD_REMOVE_SUBJECT%></h2>
<p class="Info"><%=TXT_INST_ADD_SUBJECT%></p><%
		Call openUsedSubjectTermListRst			
		strDropDownContents = makeSubjectTermList(vbNullString,"ActionID",False)
		Call closeUsedSubjectTermListRst()		

	'###################
	' TAXONOMY
	'###################
	Case "TX"
%><h2><%=TXT_ADD_REMOVE_TAX_TERM%></h2>
<p class="Info"><%=TXT_INST_ADD_TAX_TERM%></p><%
	strDropDownContents = "<br><table class=""BasicBorder cell-padding-2"">" & _
	"<tr><th class=""RevTitleBox"">" & TXT_CODE & "</th></tr>" & _
	"<tr><td>" & TXT_EG & " AA-1111.1111-111-11 [ <a href=""javascript:openWinL('" & makeLink("tax.asp","MD=2",vbNullString) & "','tFind')"">" & TXT_TAXONOMY_FINDER & "</a> ]" & _
	"<br><strong>" & TXT_SEPARATE_TILDE & "</strong>" & _
	"<br><input type=""text"" size=""" & TEXT_SIZE & """ maxlength=""255"" name=""ActionID""> " & _
	"</td></tr>" & _
	"<tr><th class=""RevTitleBox"">" & TXT_REMOVE_TERM_OPTIONS & "</th></tr>" & _
	"<tr><td><strong>" & TXT_REMOVE_TERM_OPTIONS_INST & "</strong>" & _
		"<br><input type=""RADIO"" name=""LinkOption"" value=""I"" checked>&nbsp;" & TXT_REMOVE_TERM_OPTIONS_IGNORE & _
		"<br><input type=""RADIO"" name=""LinkOption"" value=""T"">&nbsp;" & TXT_REMOVE_TERM_OPTIONS_REMOVE_TERM & _
		"<br><input type=""RADIO"" name=""LinkOption"" value=""L"">&nbsp;" & TXT_REMOVE_TERM_OPTIONS_REMOVE_LINK & _
	"</td></tr>" & _
	"</table><br>"

	'###################
	' UNKNOWN TYPE
	'###################
	Case Else
			bError = True
			Call handleError(TXT_ERROR & TXT_NO_ACTION, _
					vbNullString, _
					vbNullString)

End Select
%>
