<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

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

<% 'Base includes %>
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_VOL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCommunitySets.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtVolunteer.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->

<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Const ACTION_ADD = 1
Const ACTION_REMOVE = 2

Dim intActionType, _
	intCommunitySetID, _
	strActionType, _
	strSetName, _
	strToFrom

strSetName = Request("SetName")

Select Case Request("AddRemove")
	Case "A"
		intActionType = ACTION_ADD
		strActionType = TXT_ADD
		strToFrom = TXT_TO
	Case "R"
		intActionType = ACTION_REMOVE
		strActionType = TXT_REMOVE
		strToFrom = TXT_FROM
	Case Else
		Call handleError(TXT_NO_ACTION, "comms_vol_opcm.asp", vbNullString)
End Select

intCommunitySetID=Trim(Request("CommunitySetID"))
If IsIDType(intCommunitySetID) Then
	intCommunitySetID=CInt(intCommunitySetID)
Else
	Call handleError(TXT_INVALID_CS, _
		"comms_vol_opcm.asp", vbNullString)
End If

Call makePageHeader(strActionType & " " & TXT_OPPORTUNITIES & " " & strToFrom & " " & TXT_COMMUNITY_SET, strActionType & " " & TXT_OPPORTUNITIES & " " & strToFrom & " " & TXT_COMMUNITY_SET, True, False, True, True)

Dim strSearchSQL, _
	strCrit, _
	strCritCon
	
strSearchSQL = "SELECT	vo.VNUM, vod.POSITION_TITLE, vod.DELETION_DATE, vo.DISPLAY_UNTIL, " & _
			"vod.NON_PUBLIC, " & vbCrLf & _
			"dbo.fn_VOL_VNUMToCommunitySet(vo.VNUM) AS COMMUNITY_SETS," & vbCrLf & _ 
			"dbo.fn_VOL_RecordInView(vo.VNUM," & g_intViewTypeVOL & ",vod.LangID,0,GETDATE()) AS IN_VIEW," & vbCrLf & _
			"CAST(CASE WHEN EXISTS(SELECT * FROM GBL_RecordNote rn WHERE rn.VolVNUM=vo.VNUM AND rn.LangID=vod.LangID) " & _
				"THEN 1 ELSE 0 END AS bit) AS HAS_COMMENTS," & vbCrLf & _
			"CAST(CASE WHEN vod.DELETION_DATE > GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS TO_BE_DELETED," & vbCrLf & _
			"CAST(CASE WHEN vod.DELETION_DATE <= GETDATE() " & _
				"THEN 1 ELSE 0 END AS bit) AS IS_DELETED," & vbCrLf & _
			"CAST(CASE WHEN vo.DISPLAY_UNTIL <= GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS IS_EXPIRED," & vbCrLf & _
			"CAST(CASE WHEN EXISTS(SELECT FB_ID FROM VOL_Feedback fb WHERE fb.VNUM=vo.VNUM) " & _
				"THEN 1 ELSE 0 END AS bit) AS HAS_FEEDBACK," & vbCrLf & _
			"CAST(CASE WHEN vo.MemberID<>" & g_intMemberID & " THEN 1 ELSE 0 END AS bit) AS IS_SHARED," & vbCrLf & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & vbCrLf & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1),btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_SORT_KEY" & vbCrLf & _
	"FROM VOL_Opportunity vo" & vbCrLf & _
	"INNER JOIN VOL_Opportunity_Description vod" & vbCrLf & _
	"	ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
	"WHERE " & _
		StringIf(g_bOtherMembers,"(vo.MemberID=" & g_intMemberID & _
			StringIf(g_bOtherMembersActive," OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos INNER JOIN GBL_SharingProfile shp ON vos.ProfileID=shp.ProfileID AND shp.Active=1 WHERE vos.VNUM=vo.VNUM AND vos.ShareMemberID_Cache=" & g_intMemberID & ")") & _
			")" & vbCrLf & "AND ") & _
		"(" & IIf(intActionType=ACTION_ADD, "NOT", vbNullString) & " EXISTS(SELECT * FROM VOL_OP_CommunitySet vocs " & _
			"WHERE vocs.CommunitySetID=" & intCommunitySetID & " AND vocs.VNUM=vo.VNUM))"

Dim intInSet, _
	strInCommunity, _
	bInclDel, _
	bInclExp
	
intInSet = Request("InSet")
If Not IsIDType(intInSet) Then
	intInSet = Null
End If

strInCommunity = Request("InCommunity")
If Not IsIDList(strInCommunity) Then
	strInCommunity = vbNullString
End If

bInclDel = Request("InclDel") = "on"

bInclExp = Request("InclExp") = "on"

If Not Nl(intInSet) Then
	strSearchSQL = strSearchSQL & AND_CON & "(EXISTS(SELECT * FROM VOL_OP_CommunitySet vocs " & _
			"WHERE vocs.CommunitySetID=" & intInSet & " AND vocs.VNUM=vo.VNUM))"
End If

If Not Nl(strInCommunity) Then
	strSearchSQL = strSearchSQL & AND_CON & _
		"EXISTS(SELECT * FROM VOL_OP_CM AS pr WHERE pr.CM_ID IN (" & strInCommunity & ") AND pr.VNUM=vo.VNUM)"
End If

If Not bInclDel Then
	strSearchSQL = strSearchSQL & AND_CON & "(vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE())"
End If

If Not bInclExp Then
	strSearchSQL = strSearchSQL & AND_CON & "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL > GETDATE())"
End If

'Response.Write("<pre>" & strSearchSQL & "</pre>")
'Response.Flush()

Dim cmdSearchResults, rsSearchResults

Set cmdSearchResults = Server.CreateObject("ADODB.Command")
With cmdSearchResults
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strSearchSQL
	.CommandType = adCmdText
	.CommandTimeout = 0
End With
Set rsSearchResults = Server.CreateObject("ADODB.Recordset")
With rsSearchResults
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdSearchResults
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("comms_vol.asp")%>"><%= TXT_RETURN_TO_VC %></a> | <a href="<%= makeLinkB("comms_vol_opcm.asp")%>"><%= TXT_RETURN_TO_OPP_CS_MGMT %></a> ]</p>
<h1><%=strActionType & " " & TXT_OPPORTUNITIES & " " & strToFrom & " " & TXT_COMMUNITY_SET & " " %><em><%=Server.HTMLEncode(strSetName)%></em></h1>
<p><%=TXT_FOUND%><strong><%=.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<%
	If Not .EOF Then
%>
<p class="Info">If a record is available in your current View, the Position Title link will open the Record Details in a new window.</p>
<form method="post" action="comms_vol_opcm4.asp" name="RecordList" id="RecordList">
<%=g_strCacheFormVals%>
<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
<input type="hidden" name="SetName" value=<%=AttrQs(strSetName)%>>
<p><input type="button" onClick="CheckAll('VNUM');" value="<%=TXT_CHECK_ALL%>"> <input type="button" onClick="ClearAll('VNUM');" value="<%=TXT_UNCHECK_ALL%>"> 
</p>
<table class="BasicBorder cell-padding-3 sortable_table" data-sortdisabled="[0,1,4]" data-default-sort="[2,0]">
<thead>
<tr>
	<th class="RevTitleBox">&nbsp;</th>
	<th class="RevTitleBox">&nbsp;</th>
	<th class="RevTitleBox"><%=TXT_POSITION_TITLE%></th>
	<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>
	<th class="RevTitleBox"><%= TXT_COMMUNITY_SETS %></th>
</tr>
</thead>
<tbody>
<%
		Dim strAlertColumn
		
		Dim fldVNUM, _
			fldPositionTitle, _
			fldCommunitySets, _
			fldInView

		While Not .EOF
			Set fldVNUM = .Fields("VNUM")
			Set fldPositionTitle = .Fields("POSITION_TITLE")
			Set fldCommunitySets = .Fields("COMMUNITY_SETS")
			Set fldInView = .Fields("IN_VIEW")
	
			strAlertColumn = vbNullString
			If .Fields("IS_DELETED") Then
				strAlertColumn = "X"
			ElseIf .Fields("TO_BE_DELETED") Then
				strAlertColumn = "P"
			End If
			If .Fields("IS_EXPIRED") Then
				strAlertColumn = strAlertColumn & "E"
			End If
			If .Fields("HAS_COMMENTS") And user_bCommentAlertVOL Then
				strAlertColumn = strAlertColumn & "C"
			End If
			If .Fields("HAS_FEEDBACK") And user_bFeedbackAlertVOL Then
				strAlertColumn = strAlertColumn & "F"
			End If
			If .Fields("IS_SHARED") Then
				strAlertColumn = strAlertColumn & "S"
			End If
	
			If Nl(strAlertColumn) Then
				strAlertColumn = "&nbsp;"
			Else
				strAlertColumn = "<span style=""font-weight:bold"">" & strAlertColumn & "</span>"
			End If

%>
<tr>
	<td<%If .Fields("NON_PUBLIC") Then%> class="AlertBox"<%End If%>><%=strAlertColumn%></td>
	<td><input class="PositionCheckbox" type="checkbox" name="VNUM" title=<%=AttrQs(Nz(fldPositionTitle.Value,TXT_UNKNOWN) & TXT_COLON & strActionType & " " & strToFrom & " " & Qs(strSetName,DQUOTE))%> value="<%=fldVNUM.Value%>"></td>

	<td><%If fldInView.Value Then%><a href="<%=makeVOLDetailsLink(fldVNUM.Value,vbNullString,vbNullString)%>" target="_blank"><%End If%><%=Nz(fldPositionTitle.Value,TXT_UNKNOWN)%><%If fldInView.Value Then%></a><%End If%></td>

	<td data-tbl-key="<%=Server.HTMLEncode(.Fields("ORG_SORT_KEY"))%>"><%=.Fields("ORG_NAME_FULL")%></td>
	<td><%=Nz(fldCommunitySets.Value,"&nbsp;")%></td>
</tr>
<%
			.MoveNext
		Wend
%>
</tbody>
</table>
<input type="hidden" name="AddRemove" value="<%=Request("AddRemove")%>">
<p><input type="submit" name="Submit" value=<%=AttrQs(strActionType & " " & strToFrom & " " & Qs(strSetName,DQUOTE))%>> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></p>
</form>

<%
End If

End With

Call rsSearchResults.Close()
Set rsSearchResults = Nothing
Set cmdSearchResults = Nothing

%>


<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/tablesort.js") %>

<% 
g_bListScriptLoaded = True

Call makePageFooter(True)
%>

<!--#include file="../includes/core/incClose.asp" -->


