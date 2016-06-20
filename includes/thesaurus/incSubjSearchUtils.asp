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
Const BROADER_TERMS = 0
Const NARROWER_TERMS = 1
Const RELATED_TERMS = 2
Const USED_FOR_TERMS = 3
Const USE_WITH_TERMS = 4

Call addToHeader("<style type=""text/css"">" & vbCrLf & _
	"<!--" & vbCrLf & _
	".SubjectHeading1 {" & vbCrLf & _
	"	font-size: larger;" & vbCrLf & _
	"	font-weight: bold;" & vbCrLf & _
	"	border-top: thin solid;" & vbCrLf & _
	"	padding: 5px 0px 0px;" & vbCrLf & _
	"}" & vbCrLf & _
	".SubjectHeading2 {" & vbCrLf & _
	"	font-size: larger;" & vbCrLf & _
	"	font-weight: bold;" & vbCrLf & _
	"}" & vbCrLf & _
	"-->" & vbCrLf & _
	"</style>")

Function getUsageSQL(bNoDel)
	getUsageSQL = "(SELECT COUNT(btd.NUM)" & _
		" FROM CIC_BT_SBJ pr" & _
		" INNER JOIN GBL_BaseTable bt ON pr.NUM=bt.NUM" & _
		" INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & _
		" WHERE pr.Subj_ID=sj.Subj_ID" & _
		StringIf(Not Nl(g_strWhereClauseCIC) Or bNoDel,AND_CON & IIf(bNoDel,g_strWhereClauseCICNoDel,g_strWhereClauseCIC)) & _
		")"
End Function

Function getAdminUsageLocalSQL()
	getAdminUsageLocalSQL = "(SELECT COUNT(bt.NUM)" & _
		" FROM CIC_BT_SBJ pr" & _
		" INNER JOIN GBL_BaseTable bt ON pr.NUM=bt.NUM" & _
		" WHERE pr.Subj_ID=sj.Subj_ID AND bt.MemberID=" & g_intMemberID & _
		")"
End Function

Function getAdminUsageOtherSQL()
	getAdminUsageOtherSQL = "(SELECT COUNT(bt.NUM)" & _
		" FROM CIC_BT_SBJ pr" & _
		" INNER JOIN GBL_BaseTable bt ON pr.NUM=bt.NUM" & _
		" WHERE pr.Subj_ID=sj.Subj_ID AND bt.MemberID<>" & g_intMemberID & _
		")"
End Function

Function getUseInsteads(intSubjID, bAdmin, bUseAll, strLinkPage, bLinkFriendly, strExtraParams)

	Dim strSubjectTerm, aSubjIDs, intSubjIndex, strReturn, strCon, intUsageCount
	strCon = vbNullString
	intSubjIndex = 0

	Call openUseInsteadRst(intSubjID,bAdmin)

	ReDim aSubjIDs(rsUseInstead.RecordCount -1)

	With rsUseInstead
		While Not .EOF
			strSubjectTerm = "<em>" & rsUseInstead("SubjectTerm") & "</em>"
			If bAdmin Then
				If rsUseInstead("Inactive") Then
					strSubjectTerm = "<span class=""Alert"">" & strSubjectTerm & "</span>"
				End If
			End If
			If Not bUseAll Or bAdmin Then
				strSubjectTerm = linkSubject(strSubjectTerm, rsUseInstead("Subj_ID"), strLinkPage, bLinkFriendly, strExtraParams)
			Else
				aSubjIDs(intSubjIndex) = rsUseInstead("Subj_ID")
			End If
			strReturn = strReturn & strCon & strSubjectTerm
			strCon = IIf(bUseAll," " & TXT_AND & " "," " & TXT_OR & " ")
			intSubjIndex = intSubjIndex + 1
			.MoveNext
		Wend
	End With
	
	If bUseAll And Not bAdmin Then
		strReturn = linkSubject(strReturn, Join(aSubjIDs,","), strLinkPage, bLinkFriendly, strExtraParams)
	End If

	getUseInsteads = strReturn

	Call closeUseInsteadRst()

End Function

Function getConnectedTerms(intSubjID, intTermType, bAdmin, bCount, bLocal, bZero, bDDList, strLinkPage, bLinkFriendly, strExtraParams)

Dim strSubjectTerm, strReturn, intUsageCount, strCon

Dim cmdConnectedTerms, rsConnectedTerms
set cmdConnectedTerms = Server.CreateObject("ADODB.Command")
With cmdConnectedTerms
	If bAdmin Then
		.ActiveConnection = getCurrentAdminCnn()
	Else
		.ActiveConnection = getCurrentCICBasicCnn()
	End If
	Select Case intTermType
		Case BROADER_TERMS
			If bAdmin Then
				.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_sl_Admin"				
			ElseIf bCount Then
				.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_sl_Count"
			Else
				.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_sl"
			End If
		Case NARROWER_TERMS
			If bAdmin Then
				.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_Narrow_sl_Admin"				
			ElseIf bCount Then
				.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_Narrow_sl_Count"
			Else
				.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_Narrow_sl"
			End If
		Case RELATED_TERMS
			If bAdmin Then
				.CommandText = "dbo.sp_THS_SBJ_RelatedTerm_sl_Admin"
			ElseIf bCount Then
				.CommandText = "dbo.sp_THS_SBJ_RelatedTerm_sl_Count"
			Else
				.CommandText = "dbo.sp_THS_SBJ_RelatedTerm_sl"
			End If
		Case USED_FOR_TERMS
			If bAdmin Then
				.CommandText = "sp_THS_SBJ_UseInstead_For_sl_Admin"
			Else
				.CommandText = "sp_THS_SBJ_UseInstead_For_sl"
			End If
		Case USE_WITH_TERMS
			If bAdmin Then
				getConnectedTerms = vbNullString
				Exit Function
			ElseIf bCount Then
				.CommandText = "sp_THS_SBJ_UseInstead_With_sl_Count"
			Else
				.CommandText = "sp_THS_SBJ_UseInstead_With_sl"
			End If
		Case Else
			getConnectedTerms = vbNullString
			Exit Function
	End Select
	.Parameters.Append .CreateParameter("@SubjID",adInteger,1,4,intSubjID)
	If bAdmin Then
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	Else
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
	End If
	If bCount And Not bAdmin Then
		.Parameters.Append .CreateParameter("@NoDeleted", adBoolean, adParamInput, 1, SQL_TRUE)
	End If
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With

Set rsConnectedTerms = Server.CreateObject("ADODB.Recordset")
With rsConnectedTerms
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdConnectedTerms
End With

With rsConnectedTerms
	strCon = vbNullString
	While Not .EOF
		If intTermType = USED_FOR_TERMS Then
			intUsageCount = "(--)"
		ElseIf bAdmin Then
			intUsageCount = "(" & .Fields("UsageCountLocal") & ")" & StringIf(user_bSuperUserGlobalCIC And .Fields("UsageCountOther") > 0," [<em>+" & .Fields("UsageCountOther") & "</em>]")
		ElseIf bCount Then
			intUsageCount = "(" & .Fields("UsageCount") & ")"
		Else
			intUsageCount = "(0)"
		End If
		strSubjectTerm = .Fields("SubjectTerm") 
		If bAdmin Then
			If .Fields("Inactive") Then
				strSubjectTerm = "<span class=""Alert"">" & strSubjectTerm & "</span>"
			End If
		End If
		If Not Nl(strLinkPage) Then
			strSubjectTerm = linkSubject(strSubjectTerm,.Fields("Subj_ID") & IIf(intTermType = USE_WITH_TERMS,"," & intSubjID, vbNullString), strLinkPage, bLinkFriendly, strExtraParams)
		End If
		If bCount Then
			strSubjectTerm = strSubjectTerm & "&nbsp;" & intUsageCount
		End If
		If intTermType=USED_FOR_TERMS And bAdmin Then
			If Not Nl(.Fields("UsedWith")) Then
				strSubjectTerm = strSubjectTerm & " (" & TXT_WITH & " <em>" & .Fields("UsedWith") & "</em>)"
			End If
		End If
		If bDDList Then
			strReturn = strReturn & vbCrLf & "<dd>" & strSubjectTerm & "</dd>"
		Else
			strReturn = strReturn & strCon & strSubjectTerm
			strCon = " ; "
		End If
		.MoveNext
	Wend
End With

getConnectedTerms = strReturn

rsConnectedTerms.Close
Set rsConnectedTerms = Nothing

End Function

Function linkSubject(strLinkText, strSubjIDs, strLinkPage, bLinkFriendly, strExtraParams)
	If Not g_bPrintMode And Not Nl(strLinkPage) Then
		If bLinkFriendly Then
			linkSubject = "<a href=""" & makeLink(ps_strPathToStart & strLinkPage & "/" & strSubjIDs, strExtraParams, vbNullString) & """>" & strLinkText & "</a>"
		Else
			linkSubject = "<a href=""" & makeLink(ps_strPathToStart & strLinkPage,"SubjID=" & strSubjIDs & StringIf(Not Nl(strExtraParams),"&" & strExtraParams), vbNullString) & """>" & strLinkText & "</a>"		
		End If
	Else
		linkSubject = strLinkText
	End If
End Function

Function getShortSubjectInfo(intSubjID, strSubjectTerm, bUsed, bUseAll, intUsageCount, bCount, strLinkPage, bLinkFriendly)
	Dim strReturn, strUseInstead
	strSubjectTerm = "<strong>" & strSubjectTerm & "</strong>"
	If bUsed Then
		strReturn = linkSubject(strSubjectTerm,intSubjID,strLinkPage,bLinkFriendly,vbNullString) & StringIf(bCount,"&nbsp;(" & intUsageCount & ")")
	Else
		strUseInstead = getUseInsteads(intSubjID,False,bUseAll,strLinkPage,bLinkFriendly,vbNullString)
		If Nl(strUseInstead) Then
			strReturn = strSubjectTerm
		Else
			strReturn = strSubjectTerm & " " & TXT_USE & " " & strUseInstead
		End If
	End If
	getShortSubjectInfo = strReturn
End Function

Function getShortSubjectInfoAdmin(intSubjID, strSubjectTerm, bInactive, bUsed, bUseAll, intUsageCountLocal, intUsageCountOther, bCount, strLinkPage, bLinkFriendly, strExtraParams)
	Dim strReturn, strUseInstead
	strSubjectTerm = "<strong" & StringIf(bInactive," class=""Alert""") & ">" & strSubjectTerm & "</strong>"
	If bUsed Then
		strReturn = linkSubject(strSubjectTerm,intSubjID,strLinkPage,bLinkFriendly,strExtraParams) & StringIf(bCount And Not bInactive,"&nbsp;(" & intUsageCountLocal & ")" & StringIf(user_bSuperUserGlobalCIC And intUsageCountOther > 0," [<em>+" & intUsageCountOther & "</em>]"))
	Else
		strUseInstead = getUseInsteads(intSubjID,True,bUseAll,strLinkPage,bLinkFriendly,strExtraParams)
		If Nl(strUseInstead) Then
			strReturn = linkSubject(strSubjectTerm,intSubjID,strLinkPage,bLinkFriendly,strExtraParams)
		Else
			strReturn = linkSubject(strSubjectTerm,intSubjID,strLinkPage,bLinkFriendly,strExtraParams) & " " & TXT_USE & " " & strUseInstead
		End If
	End If
	
	getShortSubjectInfoAdmin = strReturn
End Function

Sub printFullSubjectInfo(intSubjID, strCreatedDate, strCreatedBy, strModifiedDate, strModifiedBy, strManagedBy, strSubjectTerm, bAdmin, bInactive, bAuthorized, bUsed, bUseAll, strNotes, strCategory, strSource, intUsageCountLocal, intUsageCountOther, bCount, strLinkPage, bLinkFriendly, strExtraParams)
	Dim strTermList
	'Print Info for this subject
	If bAdmin Then
%>

<p class="SubjectHeading1"><%=getShortSubjectInfoAdmin(intSubjID, strSubjectTerm, bInactive, bUsed, bUseAll, intUsageCountLocal, intUsageCountOther, bCount, strLinkPage, bLinkFriendly, strExtraParams)%></p>
<%
	Else
%>
<p class="SubjectHeading2"><%=getShortSubjectInfo(intSubjID, strSubjectTerm, bUsed, bUseAll, intUsageCountLocal, bCount, strLinkPage, bLinkFriendly)%></p>
<%
	End If
	'If this isn't a used term, we're done here
	If Not bUsed And Not bAdmin Then
		Exit Sub
	End If
	Response.Write("<dl>")
	
	If bUsed Then
	'Print Broader Terms
		strTermList = getConnectedTerms(intSubjID, BROADER_TERMS, bAdmin, bCount, g_bUseLocalSubjects, g_bUseZeroSubjects, True, strLinkPage, bLinkFriendly, strExtraParams)
		If strTermList <> vbNullString Then
%>
<dt style="font-weight:bold"><%=TXT_BROADER_TERMS%></dt>
<%=strTermList%>
<%
		End If
	'Print Narrower Terms
		strTermList = getConnectedTerms(intSubjID, NARROWER_TERMS, bAdmin, bCount, g_bUseLocalSubjects, g_bUseZeroSubjects, True, strLinkPage, bLinkFriendly, strExtraParams)
		If strTermList <> vbNullString Then
%>
<dt style="font-weight:bold"><%=TXT_NARROWER_TERMS%></dt>
<%=strTermList%>
<%
		End If
	'Print Related Terms
		strTermList = getConnectedTerms(intSubjID, RELATED_TERMS, bAdmin, bCount, g_bUseLocalSubjects, g_bUseZeroSubjects, True, strLinkPage, bLinkFriendly, strExtraParams)
		If strTermList <> vbNullString Then
%>
<dt style="font-weight:bold"><%=TXT_RELATED_TERMS%></dt>
<%=strTermList%>
<%
		End If
	'Print Used Fors
		strTermList = getConnectedTerms(intSubjID, USED_FOR_TERMS, bAdmin, False, g_bUseLocalSubjects, False, True, StringIf(bAdmin,strLinkPage), bLinkFriendly, strExtraParams)
		If strTermList <> vbNullString Then
%>
<dt style="font-weight:bold"><%=TXT_USED_FOR%></dt>
<%=strTermList%>
<%
		End If
	End If
	If Not bAdmin Then
	'Print Use Withs
		strTermList = getConnectedTerms(intSubjID, USE_WITH_TERMS, False, bCount, g_bUseLocalSubjects, g_bUseZeroSubjects, True, strLinkPage, bLinkFriendly, strExtraParams)
		If strTermList <> vbNullString Then
%>
<dt style="font-weight:bold"><%=TXT_SEARCH%> <em><%=strSubjectTerm%></em> <%=TXT_WITH & TXT_COLON%></dt>
<%=strTermList%>
<%
		End If
	Else
	'Print Notes
		If Not Nl(strNotes) Then
%>
<dt style="font-weight:bold"><%=TXT_SUBJECT_NOTES%></dt>
<dd><%=strNotes%></dd>
<%
		End If
	'Print Data Management Fields
%>
<dt style="font-weight:bold"><%=TXT_DATA_MANAGEMENT%></dt>
<%If bInactive Then%>
<dd><span class="Alert"><%=TXT_INACTIVE%></span></dd>
<%End If%>
<%If Not Nl(strManagedBy) Then%>
<dd><span style="font-style:italic"><%=TXT_MANAGED_BY & TXT_COLON%></span> <%=strManagedBy%></dd>
<%End If%>
<%If Not Nl(strCategory) Then%>
<dd><span style="font-style:italic"><%=TXT_SUBJECT_CATEGORY & TXT_COLON%></span> <%=strCategory%></dd>
<%End If%>
<dd><span style="font-style:italic"><%=TXT_SUBJECT_SOURCE & TXT_COLON%></span> <%=Nz(strSource,TXT_UNKNOWN)%></dd>
<dd><span style="font-style:italic"><%=TXT_AUTHORIZED & TXT_COLON%></span> <%=IIf(bAuthorized,TXT_YES,TXT_NO)%></dd>
<dd><span style="font-style:italic"><%=TXT_LAST_MODIFIED & TXT_COLON%></span> <%=Nz(strModifiedDate,TXT_UNKNOWN)%></dd>
<dd><span style="font-style:italic"><%=TXT_MODIFIED_BY & TXT_COLON%></span> <%=Nz(strModifiedBy,TXT_UNKNOWN)%></dd>
<dd><span style="font-style:italic"><%=TXT_DATE_CREATED & TXT_COLON%></span> <%=Nz(strCreatedDate,TXT_UNKNOWN)%></dd>
<dd><span style="font-style:italic"><%=TXT_CREATED_BY & TXT_COLON%></span> <%=Nz(strCreatedBy,TXT_UNKNOWN)%></dd>
<%
		
	End If
	'End List
	Response.Write("</dl>")
	Response.Flush()
End Sub

%>
