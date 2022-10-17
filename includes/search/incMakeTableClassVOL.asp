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

<script language="python" runat="server">
import lxml.html
from cioc.core import gtranslate

def results_page_link():
	from urllib.parse import parse_qsl, urlencode
	qs = pyrequest.query_string

	parsed_qs = parse_qsl(qs, True)
	qs = urlencode([(x,y) for x, y in parsed_qs if x.lower() != 'page'])

	if qs:
		qs = '?' + qs + '&Page='
	else:
		qs = '?Page='

	return pyrequest.path + qs


def clean_html_for_label(data):
	tree = lxml.html.document_fromstring(six.text_type(data))
	return tree.text_content()
</script>
<%

Dim cmdOpList

Dim strSearchInfoRefineNotes

Set cmdOpList = Server.CreateObject("ADODB.Command")
With cmdOpList
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

Class OpRecordTable

Private rsOpList, _
		cmdCustField, _
		rsCustField, _
		strCustOrderSelect

Private aCustFields, _
		indOrgFldData, _
		intCurFld

Private strFromSQL, _
		strWhereSQL, _
		strSaveSQL, _
		strSaveNotes, _
		bInclDeleted, _
		strTopSpecial, _
		strOBSpecial
		
Private bCustResultsFields, _
		bEnableListViewMode

Private Sub Class_Initialize()
	Set rsOpList = Server.CreateObject("ADODB.Recordset")
	With rsOpList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
	
	bCustResultsFields = False
	If reEquals(ps_strThisPage,"results.asp",True,False,True,False) Then
		If bCFldInc1 Or bCFldInc2 Then
			bCustResultsFields = True
		End If
	End If

	bEnableListViewMode = False
End Sub

Public Function setOptions(strFrom,strWhere,strSSNotes,bIncludeDeleted,strTop,strOB)
	Dim strViewWhereClause
	strViewWhereClause = IIf(bIncludeDeleted And g_bCanSeeDeletedVOL,g_strWhereClauseVOL,g_strWhereClauseVOLNoDel)

	strFromSQL = strFrom
	strSaveSQL = strWhere
	strSaveNotes = strSSNotes
	strWhereSQL = strWhere & IIf(Not (Nl(strViewWhereClause) Or Nl(strWhere)),AND_CON,vbNullString) & strViewWhereClause
	bInclDeleted = bIncludeDeleted
	strTopSpecial = strTop
	strOBSpecial = strOB
End Function

Public Sub enableListViewMode()
	bEnableListViewMode = True
End Sub

Private Function getFields()
	Dim strFieldList
	strFieldList = "vo.OP_ID, vo.VNUM,vo.RECORD_OWNER,vod.POSITION_TITLE"
	If Not opt_bDispTableVOL Then
		strFieldList = strFieldList & ",vo.REQUEST_DATE"
	End If
	If opt_fld_bAlertVOL or user_bLoggedIn Then
		strFieldList = strFieldList & _
			",vod.NON_PUBLIC" & _
			",CAST(CASE WHEN EXISTS(SELECT * FROM GBL_RecordNote rn WHERE rn.VolVNUM=vo.VNUM) " & _
				"THEN 1 ELSE 0 END AS bit) AS HAS_COMMENTS" & _
			",CAST(CASE WHEN vod.DELETION_DATE > GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS TO_BE_DELETED" & _
			",CAST(CASE WHEN vod.DELETION_DATE <= GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS IS_DELETED" & _
			",CAST(CASE WHEN vo.DISPLAY_UNTIL <= GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS IS_EXPIRED" & _
			",CAST(CASE WHEN EXISTS(SELECT FB_ID FROM VOL_Feedback fb WHERE fb.VNUM=vo.VNUM) " & _
				"THEN 1 ELSE 0 END AS bit) AS HAS_FEEDBACK" & _
			",CAST(CASE WHEN vo.MemberID=" & g_intMemberID & " THEN 0 ELSE 1 END AS bit) AS IS_SHARED" & vbCrLf
	End If
	If opt_fld_bOrgVOL Then
		strFieldList = strFieldList & ",dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL"
	End If
	If opt_fld_bComm Or Not opt_bDispTableVOL Then
		strFieldList = strFieldList & _
			",dbo.fn_VOL_VNUMToCommBalls(vo.MemberID,vo.VNUM," & g_intCommunitySetID & ") AS COMM_BALLS"
	End If
	If opt_fld_bDuties Or Not opt_bDispTableVOL Then
		strFieldList = strFieldList & ",vod.DUTIES"
	End If
	If Not opt_bDispTableVOL Then
		strFieldList = strFieldList & ",vod.LOCATION"
	End If
	If opt_fld_bUpdateScheduleVOL Or opt_bUpdateVOL Then
		strFieldList = strFieldList & ",cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE"
		If opt_bUpdateVOL Then
			strFieldList = strFieldList & ",dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) AS CAN_UPDATE"
		End If
	End If
	If opt_bEmailVOL Then
		strFieldList = strFieldList & _
			",CASE WHEN (((SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL) IS NOT NULL OR vo.UPDATE_EMAIL IS NOT NULL) AND vo.NO_UPDATE_EMAIL=0) " & _
		"THEN 1 ELSE 0 END AS CAN_EMAIL"
	End If
	Call getCustomFields()
	
	If IsArray(aCustFields) Then
		For Each indOrgFldData In aCustFields
			If Not Nl(indOrgFldData.fSelect) And indOrgFldData.fName <> "OP_ID" Then
				strFieldList = strFieldList & "," & vbCrLf & indOrgFldData.fSelect & " AS '" & indOrgFldData.fName & "'"
			End If
		Next
	End If
	getFields = strFieldList
End Function

Private Sub getCustomFields()
	Dim cmdCustField, rsCustField
	
	If IsArray(opt_fld_aCustVOL) Or bCustResultsFields Then
		Dim strFldList, strFldListCon
		If IsArray(opt_fld_aCustVOL) Then
			strFldList = Join(opt_fld_aCustVOL,",")
		End If
		If bCustResultsFields Then
			If Not Nl(strFldList) Then
				strFldListCon = ","
			End If
			If bCFldInc1 Then
				strFldList = strFldList & strFldListCon & strCFldIDList1
				strFldListCon = ","
			End If
			If bCFldInc2 Then
				strFldList = strFldList & strFldListCon & strCFldIDList2
				strFldListCon = ","
			End If
		End If

		Set cmdCustField = Server.CreateObject("ADODB.Command")
		With cmdCustField
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "sp_VOL_View_CustomField_sr"
			.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strFldList)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
			.Parameters.Append .CreateParameter("@WebEnable", adBoolean, adParamInput, 1, IIf(opt_bWebVOL,SQL_TRUE,SQL_FALSE))
			.Parameters.Append .CreateParameter("@HTTPVals", adVarChar, adParamInput, 500, g_strCacheHTTPVals)
			.Parameters.Append .CreateParameter("@PathToStart", adVarChar, adParamInput, 50, ps_strPathToStart)
			.CommandTimeout = 0
		End With
		Set rsCustField = Server.CreateObject("ADODB.Recordset")
		With rsCustField
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdCustField
			ReDim aCustFields(.RecordCount-1)
			intCurFld = 0
			While Not .EOF
				Set aCustFields(intCurFld) = New FieldData
				Call aCustFields(intCurFld).setData(.Fields("FieldName"),.Fields("FieldSelect"),.Fields("FieldDisplay"))
				intCurFld = intCurFld + 1
				.MoveNext
			Wend
			.Close
		End With
		Set rsCustField = Nothing
		Set cmdCustField = Nothing
	End If
	If Not Nl(opt_fld_intCustOrderVOL) Then
		Set cmdCustField = Server.CreateObject("ADODB.Command")
		With cmdCustField
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "sp_VOL_View_CustomField_s"
			.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, opt_fld_intCustOrderVOL)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
			.CommandTimeout = 0
		End With
		Set rsCustField = Server.CreateObject("ADODB.Recordset")
		With rsCustField
			.CursorType = adOpenForwardOnly
			.Open cmdCustField
			If .Fields("FormFieldType") = "d" Then
				strCustOrderSelect = "CAST(" & .Fields("FieldSelect") & " AS smalldatetime)"
			Else
				strCustOrderSelect = .Fields("FieldSelect")
			End If
			.Close
		End With
		Set rsCustField = Nothing
		Set cmdCustField = Nothing
	End If
End Sub

Private Function getOrderBy()
	Dim strOrderByDefault, strDesc
	
	strOrderByDefault = "vod.POSITION_TITLE"
	strDesc = StringIf(opt_bOrderByDescVOL, " DESC")

	If Not Nl(strOBSpecial) Then
		getOrderBy = strOBSpecial & "," & strOrderByDefault
	Else
		Select Case opt_intOrderByVOL
			Case OB_POS
				getOrderBy = strOrderByDefault & strDesc
			Case OB_UPDATE
				getOrderBy = "CAST(vod.UPDATE_SCHEDULE AS smalldatetime)" & strDesc & "," & strOrderByDefault
			Case OB_NAME
				getOrderBy = "ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1)" & strDesc & _
					",btd.ORG_LEVEL_2" & strDesc & _
					",btd.ORG_LEVEL_3" & strDesc & _
					",btd.ORG_LEVEL_4" & strDesc & _
					",btd.ORG_LEVEL_5" & strDesc & "," & vbCrLf & _
					"	STUFF(" & vbCrLf & _
					"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
					"			THEN NULL" & vbCrLf & _
					"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
					"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
					"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
					"			 END," & vbCrLf & _
					"		1, 2, ''" & vbCrLf & _
					"	) " & strDesc & _
					"," & strOrderByDefault
			Case OB_CUSTOM
				If Not Nl(strCustOrderSelect) Then
					getOrderBy = strCustOrderSelect & strDesc & "," & strOrderByDefault
				Else
					getOrderBy = strOrderByDefault & strDesc
				End If
			Case Else
				getOrderBy = "vo.REQUEST_DATE" & StringIf(Not opt_bOrderByDescVOL, " DESC") & "," & strOrderByDefault
		End Select
	End If
End Function

Public Sub makeTable()

Dim	strSQL, _
	strOrgName, _
	dUpdateSchedule, _
	strDetailLink, _
	strUpdateText, _
	strUpdateLink, _
	strEmailLink, _
	strAlertColumn, _
	i

If Nl(strFromSQL) Then
	Exit Sub
End If

strSQL = "SELECT " & _
		IIf(Nl(strTopSpecial),vbNullString,"TOP " & strTopSpecial & " ") & _
		getFields() & vbCrLf & "FROM "

If Nl(strWhereSQL) Then
	strSQL = strSQL & strFromSQL
Else
	strSQL = strSQL & strFromSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If

strSQL = strSQL & vbCrLf & "ORDER BY " & getOrderBy()

'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
'Response.Flush()

If reEquals(ps_strThisPage,"(volunteer/)?sresults.asp",True,False,True,False) Then
	On Error Resume Next
End If

cmdOpList.CommandText = strSQL
rsOpList.Open cmdOpList

If Err.Number <> 0 Then
	Call handleError(TXT_SRCH_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), _
		vbNullString, _
		vbNullString)
	Call makePageFooter(True)
	%>
	<!--#include file="../../includes/core/incClose.asp" -->
	<%
	Response.End
End If

With rsOpList

Dim intTotalResultCount

intTotalResultCount = .RecordCount

%>
<script type="text/javascript">
	window.cioc_results_count =<%=intTotalResultCount %>;
</script>
<%

If intTotalResultCount = 0 Then
	Dim strSearchNoResultMessage
	strSearchNoResultMessage = get_view_data_vol("NoResultsMsg")
	If Nl(strSearchNoResultMessage) Then
		strSearchNoResultMessage = TXT_NO_MATCH
	End If
	Call handleMessage(strSearchNoResultMessage,vbNullString,vbNullString,False)
	If user_bVOL _
		And user_intSavedSearchQuota > 0 _
		And Not g_bPrintMode _
		And reEquals(ps_strThisPage,".?results.asp",True,False,True,False) _
		And (Len(strWhereSQL) < 10000) _
		And Not Nl(strSaveSQL) _
		And Nl(Request("SRCHID")) Then
%>
<p>
	<a class="btn btn-info" role="button" href="<%=makeLink(ps_strPathToStart & "volunteer/savedsearch_edit.asp","WhereClause=" & Server.URLEncode(strSaveSQL) & "&InclDel=" & IIf(bInclDeleted,"on",vbNullString) & "&Notes=" & strSaveNotes,vbNullString)%>">
		<span class="fa fa-save" aria-hidden="true"></span>
		<%=TXT_SAVE_THIS_SEARCH%>
	</a>
</p>
<%
	End If 'Saved Search link
Else
	If bCanRefineSearch And Not Nl(strSaveSQL) Then
		strRecentSearchKey = recentSearchStore(ps_intDomain, strSaveSQL, strSearchInfoRefineNotes, DateTimeString(Now(),True), g_strViewNameVOL, g_intViewTypeVOL, g_objCurrentLang.LanguageAlias, .RecordCount)
	End If

	If bEnableListViewMode Then
%>
<div id="records_ui">
<%
	End If

	If opt_fld_bComm Then
		Dim cmdCommBalls, rsCommBalls, strCommBalls
		Set cmdCommBalls = Server.CreateObject("ADODB.Command")
		With cmdCommBalls
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandText = "dbo.fn_VOL_CommBallsLegend"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adVarChar, adParamReturnValue, 8000)
			.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, g_intCommunitySetID)
			Set rsCommBalls = .Execute
		End With
		Set rsCommBalls = rsCommBalls.NextRecordset
		strCommBalls = cmdCommBalls.Parameters("@RETURN_VALUE").Value
		Set cmdCommBalls = Nothing
		Set rsCommBalls = Nothing
	End If

	If Not g_bPrintMode Then
%>
	<div class="row">
		<div class="col-md-8">
			<div id="results-info" class="content-bubble padding-md clear-line-below">
<%
		Call printSearchInfo()
		If Not Request("NoCount")="on" Then
%>
				<p class="content-border-top"><%=TXT_THERE_ARE%> <strong><%= intTotalResultCount %></strong> <%=TXT_RECORDS_MATCH%></p>
<%
		End If
%>
				<p <%If Not user_bLoggedIn Then%>class="AlertBubble"<%End If%>><%=TXT_CLICK_ON%> <strong><%If opt_fld_bPosition Then%><%=TXT_POSITION_TITLE%><%Else%>Opportunity ID<%End If%></strong> <%=TXT_VIEW_FULL%></p>
			</div>
			<div id="results-menu">
<%
		If bEnableListViewMode And Not g_bEnableListModeCT Then
		%>
				<a class="btn btn-info btn-alert-border" id="remove_all_from_list">
					<span class="glyphicon glyphicon-remove-circle" aria-hidden="true"></span>
					<%=TXT_LIST_REMOVE_ALL%>
				</a>
		<%
		End IF
		
		If user_bVol Then
%>
				<a class="btn btn-info" href="javascript:openWin('<%=makeLink(ps_strPathToStart & "volunteer/display_options.asp",vbNullString,vbNullString)%>');">
					<span class="fa fa-gear" aria-hidden="true"></span>
					<%=TXT_CHANGE_DISPLAY%>
				</a>
<%
			If reEquals(ps_strThisPage,".?results.asp",True,False,True,False) _
				And ps_strThisPage <> "presults.asp" _
				And user_intSavedSearchQuota > 0 _
				And (Len(strWhereSQL) < 10000) _
				And Not Nl(strSaveSQL) _
				And Nl(Request("SRCHID")) Then
%>
				<a class="btn btn-info" href="<%=makeLink(ps_strPathToStart & "volunteer/savedsearch_edit.asp","WhereClause=" & Server.URLEncode(strSaveSQL) & "&InclDel=" & IIf(bInclDeleted,"on",vbNullString) & "&Notes=" & strSaveNotes,vbNullString)%>">
					<span class="fa fa-save" aria-hidden="true"></span>
					<%=TXT_SAVE_THIS_SEARCH%>
				</a>
<%
			End If
			If Not Nl(strRecentSearchKey) And user_bVOL Then
%>
				<a class="btn btn-info" href="<%=makeLink(ps_strPathToStart & "volunteer/advsrch.asp","RS=" & Server.URLEncode(strRecentSearchKey),vbNullString)%>">
					<span class="fa fa-edit" aria-hidden="true"></span>
					<%=TXT_REFINE_SEARCH%>
				</a>
<%
			End If
		End If 'User is VOL

		If g_bPrintVersionResultsVOL And (user_bLoggedIn Or g_bPrintModePublic) And Not Nl(g_intPrintDesignVOL) Then
			If reEquals(ps_strThisPage,".?results.asp",True,False,True,False) Then
%>
				<a class="btn btn-info" href="<%=ps_strThisPage & "?" & IIf(Nl(strQueryString),vbNullString,strQueryString & "&")%>PrintMd=on" target="_BLANK">
					<span class="fa fa-print" aria-hidden="true"></span>
					<%=IIf(user_bLoggedIn,TXT_PRINT_VERSION,TXT_PRINT_VERSION_NW)%>
				</a>
<%
			ElseIf reEquals(ps_strThisPage,"whatsnew.asp",True,False,True,False) Then
%>
				<a class="btn btn-info" href="<%=makeLink(ps_strThisPage,"PrintMd=on&numDays=" & intNumDays & "&numRecords=" & intMinRecords & "&dateType=" & strDateType,vbNullString)%>" target="_BLANK">
					<span class="fa fa-print" aria-hidden="true"></span>
					<%=IIf(user_bLoggedIn,TXT_PRINT_VERSION,TXT_PRINT_VERSION_NW)%>
				</a>
<%
			ElseIf reEquals(ps_strThisPage,"processRecordList.asp",True,False,True,False) Then
%>
				<a class="btn btn-info" href="<%=makeLink(ps_strThisPage,"PrintMd=on&ActionType=N&IDList=" & strIDList,vbNullString)%>" target="_BLANK">
					<span class="fa fa-print" aria-hidden="true"></span>
					<%=IIf(user_bLoggedIn,TXT_PRINT_VERSION,TXT_PRINT_VERSION_NW)%>
				</a>
<%
			End If
		End If 'Print Version link
%>
			</div>
		</div>
		<div class="col-md-4">
			<div class="content-bubble padding-md clear-line-below">
				<h4><%=TXT_COMMUNITIES%></h4>
				<div class="row clear-line-below">
					<%=strCommBalls%>
				</div>
			</div>
		</div>
	</div>

<%
		If user_bVOL And opt_bDispTableVOL And opt_bSelectVOL Then
%>
	<form name="RecordList" class="form" action="<%=ps_strPathToStart%>volunteer/processRecordList.asp" method="post">
	<%=g_strCacheFormVals%>

	<div class="row">
		<div class="col-md-6 col-lg-7">
			<div class="form-group">
				<label for="SearchResultActionList" class="control-label">
					<%=TXT_ACTION_ON_SELECTED%>
				</label>
				<div class="input-group">
					<select name="ActionType" class="form-control" id="SearchResultActionList">
						<option value="N"><%=TXT_SLCT_NEW_RESULTS%></option>
						<option value="AR"><%=TXT_SLCT_NEW_REMINDER%></option>
						<option value="EL"><%=TXT_SLCT_EMAIL_RECORD_LIST%></option>
						<optgroup label="<%=TXT_SLCT_STATS_AND_REPORTING%>">
							<option value="P"><%=TXT_SLCT_PRINT%></option>
<%	
			If user_intCanViewStatsVOL > STATS_NONE Then
%>
							<option value="G"><%=TXT_SLCT_STATS%></option>
<%
			End If
%>
						</optgroup>
<%
			If user_bCanDoBulkOpsVOL Then
%>
						<optgroup label="<%=TXT_SLCT_DATA_MANAGEMENT%>">
<%
				If user_bCanRequestUpdateVOL And Not g_bNoEmail Then%>
							<option value="U"><%=TXT_SLCT_EMAIL_UPDATE%></option>
<%
				End If%>
							<option value="NP"><%=TXT_SLCT_PUBLIC_NONPUBLIC%></option>
<%	
				If user_bCanDeleteRecordVOL Then%>
							<option value="R"><%=TXT_SLCT_DELETE_RESTORE%></option><%
				End If
%>
							<option value="RO"><%=TXT_SLCT_CHANGE_OWNER%></option>
							<option value="AI"><%=TXT_SLCT_AREAS_OF_INTEREST%></option>
						</optgroup>
<%
			End If
			If user_bSuperUserVOL And g_bOtherMembers Then
%>
						<optgroup label="<%=TXT_SLCT_DATA_SHARING%>">
							<option value="SP"><%= TXT_SLCT_SHARING_PROFILE %></option>
						</optgroup>
<%
			End If
%>
					</select>
					<div class="input-group-btn">
						<input type="submit" class="btn btn-default" value="<%=TXT_SUBMIT%>">
					</div>
				</div>
			</div>
		</div>
		<div class="col-md-6 col-lg-5">
			<div class="form-group">
				<label class="control-label hidden-sm">
					<%=TXT_SELECT%>
				</label>
				<div>
					<input type="button" class="btn btn-default" onClick="CheckAll();" value="<%=TXT_CHECK_ALL%>">
					<input type="button" class="btn btn-default" onClick="ClearAll();" value="<%=TXT_UNCHECK_ALL%>">
				</div>
			</div>
		</div>
	</div>
<%
		End If 'Select Checkbox
	End If 'Print Mode
	
	If opt_bDispTableVOL Then
		If Not g_bPrintMode Then
%>
<style type="text/css">
	@media screen and (max-width: 1023px)  {
<%
		i = 2
			If opt_bSelectVOL Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_SELECT%>"; }
<%
				i= i + 1
			End If
			If opt_fld_bAlertVOL Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: ""; }
<%	
				i= i + 1
			End If
			If opt_fld_bVNUM Or Not (opt_fld_bPosition Or opt_fld_bOrgVOL) Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_ID%>"; }
<%
				i= i + 1
			End If
			If opt_fld_bPosition Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_POSITION_TITLE%>"; }
<%
				i= i + 1
			End If
			If opt_fld_bOrgVOL Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_ORGANIZATION%>"; }
<%
				i= i + 1
			End If
			If opt_fld_bComm Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_COMMUNITIES%>"; }
<%
				i= i + 1
			End If
			If opt_fld_bDuties Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_DUTIES%>"; }
<%
				i= i + 1
			End If
			If opt_fld_bRecordOwnerVOL Then
%>
		.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_OWNER%>"; }
<%
				i= i + 1
			End If
			If IsArray(aCustFields) Then
				For Each indOrgFldData In aCustFields
%>
			.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=clean_html_for_label(indOrgFldData.fLabel)%>"; }
<%
					i= i + 1
				Next
			End If
			If opt_fld_bUpdateScheduleVOL Then
%>
			.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_UPDATE_SCHEDULE%>"; }
<%
				i= i + 1
			End If
			If opt_bUpdateVOL Then
%>
			.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_UPDATE_FEEDBACK%>"; }
<%
				i= i + 1
			End If
			If opt_bEmailVOL And user_bCanRequestUpdateDOM Then
%>
			.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_REQUEST_UPDATE%>"; }
<%
				i= i + 1
			End If
			If Not g_bPrintMode And (opt_bListAddRecordVOL Or bEnableListViewMode) Then
%>
			.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=IIf(g_bEnableListModeCT, TXT_CT_CLIENT_TRACKER,TXT_MY_LIST)%>"; }
<%
				i= i + 1
			End If
%>
	}
</style>
<%
		End If 'PrintMode
%>
<table class="BasicBorder cell-padding-3 HideListUI <%If Not g_bPrintMode Then%>ResponsiveResults<% End If %>" id="results_table">
	<thead>
		<tr class="RevTitleBox">
<%
	If not g_bPrintMode Then
%>
			<th class="MobileShowField"></th>
<%
	End If
	If opt_bSelectVOL Then
%>
			<th>&nbsp;</th>
<%
	End If
	If opt_fld_bAlertVOL Then
%>
			<th width="5" class="MobileHideField">&nbsp;</th>
<%
	End If
	If opt_fld_bVNUM Or Not (opt_fld_bPosition Or opt_fld_bOrgVOL) Then
%>
			<th><%=TXT_ID%></th>
<%
	End If
	If opt_fld_bPosition Then
%>
			<th><%=TXT_POSITION_TITLE%></th>
<%
	End If
	If opt_fld_bOrgVOL Then
%>
			<th><%=TXT_ORG_NAMES%></th>
<%
	End If
	If opt_fld_bComm Then
%>
			<th><%=TXT_COMMUNITIES%></th>
<%
	End If
	If opt_fld_bDuties Then
%>
			<th><%=TXT_DUTIES%></th>
<%
	End If
	If opt_fld_bRecordOwnerVOL Then
%>
			<th><%=TXT_OWNER%></th>
<%
	End If
	If IsArray(aCustFields) Then
		For Each indOrgFldData In aCustFields
%>
			<th><%=indOrgFldData.fLabel%></th>
<%
		Next
	End If
	If opt_fld_bUpdateScheduleVOL Then
%>
			<th><%=TXT_UPDATE_SCHEDULE%></th>
<%
	End If
	If opt_bUpdateVOL Then
%>
			<th><%=TXT_UPDATE_FEEDBACK%></th>
<%
	End If
	If opt_bEmailVOL And user_bCanRequestUpdateDOM Then
%>
			<th><%=TXT_REQUEST_UPDATE%></th>
<%
	End If
	If Not g_bPrintMode And (opt_bListAddRecordVOL Or bEnableListViewMode) Then Call myListResultsAddRecordHeader() End If
%>
		</tr>
	</thead>
<%	
	Else 'Display Table
%>
<div class="HideListUI" id="results_container">
	<div class="dlist-results">
<%
	End If 'Display Table

	Dim bBot

	If reEquals(Request.ServerVariables("HTTP_USER_AGENT"),"(googlebot)|(crawler)|(spider)|(robot)",True,False,False,False) Then
		bBot = True
	End If

	Dim aIDList
	ReDim aIDList(.RecordCount-1)
	i = 0

	Dim fldVNUM, fldPositionTitle
	Set fldVNUM = .Fields("VNUM")
	Set fldPositionTitle = .Fields("POSITION_TITLE")

	Dim strRecordListUI
	strRecordListUI = vbNullString
	If Not g_bPrintMode And (opt_bListAddRecordVOL Or bEnableListViewMode) Then 
		If opt_bDispTableVOL Then
			strRecordListUI = myListResultsAddRecord("[IDID]", bEnableListViewMode, "<td class=""ListUI"">", "</td>") 
		Else
			strRecordListUI = myListResultsAddRecord("[IDID]", bEnableListViewMode, "<span class=""ListUI"">", "</span>")
		End If
	End If

	Dim bCanEmail, bShowAlert
	bCanEmail = opt_bEmailVOL And user_bCanRequestUpdateDOM And Not g_bNoEmail 
	bShowAlert = opt_fld_bAlertVOL Or (Not opt_bDispTableVOL And g_bAlertColumnVOL)

	Dim strDetailLinkTemplate
	strDetailLinkTemplate = "<a href=""" & _
			makeVOLDetailsLink("[VNUMVNUM]", StringIf(Not bBot , "Number=[NUMBERNUMBER]"), vbNullString) & """>"

	While Not .EOF
		aIDList(i) = fldVNUM.Value
		If opt_fld_bOrgVOL Then
			strOrgName = rsOpList.Fields("ORG_NAME_FULL")
		End If
		strDetailLink = Replace(Replace(strDetailLinkTemplate, "[VNUMVNUM]", fldVNUM.Value), _
							"[NUMBERNUMBER]", CStr(i))

		If bCanEmail Then
			If .Fields("CAN_EMAIL") Then
				strEmailLink = "<a href=""" & _
					makeLinkAdmin("email_prep.asp","IDList=" & fldVNUM.Value & "&Number=" & i & "&DM=" & ps_intDbArea) & _
					""">" & TXT_EMAIL & "</a>"
			Else
				strEmailLink = "&nbsp;"
			End If
		End If
	
		dUpdateSchedule = Null
		If opt_fld_bUpdateScheduleVOL Or opt_bUpdateVOL Then
			If Not Nl(.Fields("UPDATE_SCHEDULE")) Then
				dUpdateSchedule = DateValue(.Fields("UPDATE_SCHEDULE"))
			End If
		End If

		If opt_bUpdateVOL Then
			If .Fields("CAN_UPDATE") Then
				strUpdateText = "Update"
				strUpdateLink = "<a href=""" & makeLink(ps_strPathToStart & "volunteer/entryform.asp", _
					"VNUM=" & fldVNUM.Value & "&Number=" & i,vbNullString) & """ class=""vol-results-update"
				If Not opt_fld_bUpdateScheduleVOL And (Now() > dUpdateSchedule Or Nl(dUpdateSchedule)) Then
					strUpdateLink = strUpdateLink & " Alert"
				End If
				strUpdateLink = strUpdateLink & """>"
			Else
				strUpdateText = "Feedback"
				strUpdateLink = "<a href=""" & makeLink(ps_strPathToStart & "volunteer/feedback.asp", _
					"VNUM=" & .Fields("VNUM") & "&Number=" & i,vbNullString) & """ class=""vol-results-update"
				If Not opt_fld_bUpdateScheduleVOL And (Now() > dUpdateSchedule Or Nl(dUpdateSchedule)) Then
					strUpdateLink = strUpdateLink & " Alert"
				End If
				strUpdateLink = strUpdateLink & """>"
			End If
		End If
		i = i + 1
		strAlertColumn = vbNullString
		If bShowAlert Then
			If .Fields("IS_SHARED") Then
				strAlertColumn = "S"
			End If
			If .Fields("IS_DELETED") Then
				strAlertColumn = strAlertColumn & "X"
			ElseIf .Fields("TO_BE_DELETED") Then
				strAlertColumn = strAlertColumn & "P"
			End If
			If Not opt_bDispTableVOL And .Fields("NON_PUBLIC") Then
				strAlertColumn = "N"
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
			If opt_bDispTableVOL Then
				If Nl(strAlertColumn) Then
					strAlertColumn = "&nbsp;"
				Else
					strAlertColumn = "<span style=""font-weight:bold"">" & strAlertColumn & "</span>"
				End If
			ElseIf Not Nl(strAlertColumn) Then
				strAlertColumn = "<span class=""Alert"">" & strAlertColumn & "</span>"
			End If
		End If ' Show Alert

		If opt_bDispTableVOL Then
%>
<tr valign="top">
<% If Not g_bPrintMode Then %>
<td class="MobileShowField">
<h3>
<%If opt_fld_bAlertVOL Then%><%If .Fields("NON_PUBLIC") Or strAlertColumn<>"&nbsp;" Then%><span class="MobileMiniColumnSpan MobileAlertColumnBubble"><%If .Fields("NON_PUBLIC") Then%><span class="Alert">N</span><%End If%><%=Replace(strAlertColumn, "&nbsp;", "")%></span><%End If%><%End If%>
<%If opt_fld_bPosition Then%>
	<%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=fldPositionTitle%><%If Not g_bPrintMode Then%></a><%End If%>	
<%ElseIf opt_fld_bOrgVOL And Not opt_fld_bVNUM Then%>
	<%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=strOrgName%><%If Not g_bPrintMode Then%></a><%End If%>	
<%Else%>
	<%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=fldVNUM.Value%><%If Not g_bPrintMode Then%></a><%End If%>
<%End If%>
</h3>
</td>
<% End If %>
<%If opt_bSelectVOL Then%><td><input type="checkbox" name="IDList" title=<%=AttrQs(TXT_SELECT & TXT_COLON & fldPositionTitle)%> value="<%=fldVNUM.Value%>" id="IDList_<%=fldVNUM.Value%>"></td><%End If%>
<%If opt_fld_bAlertVOL Then%><td class="MobileHideField<%If .Fields("NON_PUBLIC") Then%> AlertBox<%End If%>"><%=strAlertColumn%></td><%End If%>
<%If opt_fld_bVNUM Or Not (opt_fld_bPosition Or opt_fld_bOrgVOL) Then%><td class="NoWrap<%If Not opt_fld_bPosition And Not g_bPrintMode Then%> MobileHideField<%End If%>"><%If Not opt_fld_bPosition And Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=fldVNUM.Value%><%If Not opt_fld_bPosition And Not g_bPrintMode Then%></a><%End If%></td><%End If%>
<%If opt_fld_bPosition Then%><td class="MobileHideField"><%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=fldPositionTitle%><%If Not g_bPrintMode Then%></a><%End If%></td><%End If%>
<%If opt_fld_bOrgVOL Then%><td <%If Not opt_fld_bPosition And Not opt_fld_bVNUM Then %>class="MobileHideField"<%End If%>><%If Not opt_fld_bPosition And Not opt_fld_bVNUM And Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=strOrgName%><%If Not opt_fld_bPosition And Not opt_fld_bVNUM And Not g_bPrintMode Then%></a><%End If%></td><%End If%>
<%If opt_fld_bComm Then%><td <%If Nl(.Fields("COMM_BALLS"))Then %>class="MobileHideField"<%End If%>><%=IIf(Nl(.Fields("COMM_BALLS")),"&nbsp;",.Fields("COMM_BALLS"))%></td><%End If%>
<%If opt_fld_bDuties Then%><td <%If Nl(.Fields("DUTIES")) Then%>class="MobileHideField"<%End If%>><%=IIf(Nl(.Fields("DUTIES")),"&nbsp;",textToHTML(.Fields("DUTIES")))%></td><%End If%>
<%If opt_fld_bRecordOwnerVOL Then%><td><%=.Fields("RECORD_OWNER")%></td><%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<td <%If Nl(.Fields(indOrgFldData.fName)) Then%>class="MobileHideField"<%End If%>><%If Not Nl(.Fields(indOrgFldData.fName)) Then%><%=textToHTML(.Fields(indOrgFldData.fName))%><%Else%>&nbsp;<%End If%></td>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleVOL Then%><td><%If Now() > dUpdateSchedule Or Nl(dUpdateSchedule) Then%><span class="Alert"><%End If%><%If Nl(dUpdateSchedule) Then%><%=TXT_UNKNOWN%><%Else%><%=.Fields("UPDATE_SCHEDULE")%><%End If%><%If Now() > dUpdateSchedule Or Nl(dUpdateSchedule) Then%></span><%End If%></td><%End If%>
<%If opt_bUpdateVOL Then%><td><%=strUpdateLink%><%=strUpdateText%></a></td><%End If%>
<%If opt_bEmailVOL And user_bCanRequestUpdateDOM Then%><td <%If strEmailLink = "&nbsp;" Then %>class="MobileHideField"<%End If%>><%=strEMailLink%></td><%End If%>
<% Response.Write(Replace(strRecordListUI, "[IDID]", fldVNUM.Value)) %>
</tr>
<%
		Else 'Display Table
%>
	<div class="dlist-result">
	<div class="vol-results-position-title">
		<%If Not g_bPrintMode Then%><%=strDetailLink%><%=fldPositionTitle%></a><%Else%><%=fldPositionTitle%><%End If%>
		<%
			If user_bLoggedIn Then
				If Not Nl(.Fields("REQUEST_DATE")) Then
		%>
		<span class="NoWrap">(<%=DateString(.Fields("REQUEST_DATE"),True)%>)</span>
		<%
				End If
			End If
		%>
		<span class="NoWrap"><%=strAlertColumn%>&nbsp;&nbsp;<%=.Fields("COMM_BALLS")%></span>
	</div>
	<%If Not g_bPrintMode And (opt_bUpdateVOL or opt_bListAddRecordVOL Or bEnableListViewMode) Then%>
	<div class="vol-results-action vol-results-dd NoWrap">
		<%If opt_bUpdateVOL Then%><img border="0" aria-hidden="true" src="<%=ps_strPathToStart%>/images/edit.gif"> <%=strUpdateLink%><%=strUpdateText%></a><%End If%>
		<%= Replace(strRecordListUI, "[IDID]", fldVNUM.Value) %>
	</div>
	<%End If%> 
	<% If opt_fld_bOrgVOL Then %><div class="vol-results-org-name vol-results-dd"><i aria-hidden="true" class="fa fa-institution fa-cioc"></i> <%=strOrgName%></div><%End If%>
	<%If Not Nl(.Fields("LOCATION")) Then%><div class="vol-results-location vol-results-dd"><i aria-hidden="true" class="fa fa-map-marker fa-cioc"></i> <%=textToHTML(.Fields("LOCATION"))%></div><%End If%>
	<%If Not Nl(.Fields("DUTIES")) Then%><div class="vol-results-duties vol-results-dd"><%=textToHTML(.Fields("DUTIES"))%></div><%End If%>
	</div>
<%
		End If 'Display Table
	
		.MoveNext
		If i Mod 500 = 0 Then
			Response.Flush
		End If
	Wend

	If Not bBot Then
		If IsArray(aIDList) Then
			Call setSessionValue("aVNUMSearchList", Join(aIDList,","))
		Else
			Call setSessionValue("aVNUMSearchList", vbNullString)
		End If
	End If

	If opt_bDispTableVOL Then
%>
</table>
<%
	Else
%>
	</div>
</div>
<%
	End If

	If user_bVOL And opt_bSelectVOL Then
%></form><%
	End If

	If bEnableListViewMode Then
	%></div><%
	End If
End If

	.Close
End With

End Sub

Public Sub makeJSON()

'On Error Resume Next

Dim	strSQL, _
	strOrgName, _
	dUpdateSchedule, _
	strDetailLink, _
	strRPCDetailLink, _
	strUpdateText, _
	strUpdateLink, _
	strEmailLink, _
	strAlertColumn, _
	i

If Nl(strFromSQL) Then
	Exit Sub
End If
strSQL = "SELECT " & _
		IIf(Nl(strTopSpecial),vbNullString,"TOP " & strTopSpecial & " ") & _
		getFields() & vbCrLf & "FROM "

If Nl(strWhereSQL) Then
	strSQL = strSQL & strFromSQL
Else
	strSQL = strSQL & strFromSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If

strSQL = strSQL & vbCrLf & "ORDER BY " & getOrderBy()

'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
'Response.Flush()

cmdOpList.CommandText = strSQL
rsOpList.Open cmdOpList

If Err.Number <> 0 Then
%>
{"error": <%= JSONQs(Err.Message, True) %>, "recordset": null}
<%
	Exit Sub
End If

With rsOpList

If .EOF Then
%> 
{ "error": null, "recordset": [] }
<%
Else
Dim bGotField
bGotField = False
%>
{ "error": null,
  "fields": {
<%If opt_fld_bVNUM Or Not (opt_fld_bPosition Or opt_fld_bOrgVOL) Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"VNUM": <%=JSONQs(TXT_ID, True)%><%End If%>
<%If opt_fld_bPosition Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"POSITION_TITLE": <%=JSONQs(TXT_POSITION_TITLE, True)%><%End If%>
<%If opt_fld_bOrgVOL Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"ORG_NAME": <%=JSONQs(TXT_ORG_NAMES, True)%><%End If%>
<%If opt_fld_bComm Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"COMM_BALLS": <%=JSONQs(TXT_COMMUNITIES, True)%><%End If%>
<%If opt_fld_bDuties Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"DUTIES": <%=JSONQs(TXT_DUTIES, True)%><%End If%>
<%If opt_fld_bRecordOwnerVOL Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"RECORD_OWNER": <%=JSONQs(TXT_OWNER, True)%><%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<%If bGotField Then%>,<%Else
bGotField=True
End If%><%=JSONQs(indOrgFldData.fName, True)%>: <%=JSONQs(indOrgFldData.fLabel, True)%>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleVOL Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"UPDATE_SCHEDULE": <%=JSONQs(TXT_UPDATE_SCHEDULE, True)%><%End If%>
},
"recordset": [
<%
i = 0

Dim fldVNUM, fldOPID, fldPositionTitle
Set fldVNUM = .Fields("VNUM")
Set fldOPID = .Fields("OP_ID")
Set fldPositionTitle = .Fields("POSITION_TITLE")


Dim strAccessURL
strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPageFull,"$1",True,False,False,False)
strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

Dim strDetailLinkTemplate, strRPCDetailLinkTemplate
strDetailLinkTemplate =  "https://" & strAccessURL & _
		makeVOLDetailsLink("[VNUMVNUM]", vbNullString, vbNullString) 
strRPCDetailLinkTemplate = "https://" & strAccessURL & "/" & _
		makeLinkB("rpc/opportunity/[VNUMVNUM]") 

While Not .EOF
	If opt_fld_bOrgVOL Then
		strOrgName = rsOpList.Fields("ORG_NAME_FULL")
	End If
	strDetailLink = Replace(strDetailLinkTemplate, "[VNUMVNUM]", fldVNUM.Value)
	strRPCDetailLink = Replace(strRPCDetailLinkTemplate, "[VNUMVNUM]", fldVNUM.Value)

	dUpdateSchedule = Null
	If opt_fld_bUpdateScheduleVOL Or opt_bUpdateVOL Then
		If Not Nl(.Fields("UPDATE_SCHEDULE")) Then
			dUpdateSchedule = DateValue(.Fields("UPDATE_SCHEDULE"))
		End If
	End If
	i = i + 1
	strAlertColumn = vbNullString
	If opt_fld_bAlertVOL Then
		If .Fields("IS_SHARED") Then
			strAlertColumn = "S"
		End If
		If .Fields("IS_DELETED") Then
			strAlertColumn = strAlertColumn & "X"
		ElseIf .Fields("TO_BE_DELETED") Then
			strAlertColumn = strAlertColumn & "P"
		End If
		If Not opt_bDispTableVOL And .Fields("NON_PUBLIC") Then
			strAlertColumn = "N"
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
	End If
%>
{
"OPID": <%= fldOPID.Value %>
,"VNUM": <%= JSONQs(fldVNUM.Value, True) %>
,"RECORD_DETAILS" : <%=JSONQs(strDetailLink,True)%>
,"API_RECORD_DETAILS" : <%=JSONQs(strRPCDetailLink,True)%>
<%If opt_fld_bAlertVOL Then%>
,"ALERT": <%= JSONQs(strAlertColumn, True) %>
<%End If%>
<%If opt_fld_bPosition Then%>
,"POSITION_TITLE": <%= JSONQs(fldPositionTitle, True) %>
<%End If%>
<%If opt_fld_bOrgVOL Then%>
,"ORG_NAME": <%= JSONQs(strOrgName, True) %>
<%End If%>
<%If opt_fld_bComm Then%>
,"COMM_BALLS": <%= JSONQs(.Fields("COMM_BALLS"), True)%>
<%End If%>
<%If opt_fld_bDuties Then%>
,"DUTIES": <%=JSONQs(textToHTML(.Fields("DUTIES")), True)%>
<%End If%>
<%If opt_fld_bRecordOwnerVOL Then%>
,"RECORD_OWNER": <%= JSONQs(.Fields("RECORD_OWNER"), True) %>
<%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
,<%=AttrQs(indOrgFldData.fName)%>: <%=JSONQs(textToHTML(.Fields(indOrgFldData.fName)), True)%>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleVOL Then%>
,"UPDATE_SCHEDULE": <%=JSONQs(.Fields("UPDATE_SCHEDULE"), True)%>
<%End If%>
}
<%
	
	.MoveNext
	If Not .EOF Then
%>,<%
	End If
	If i Mod 500 = 0 Then
		Response.Flush
	End If
Wend
%>
] }
<%
End If

	.Close
End With

End Sub

Public Sub makeXML()

'On Error Resume Next

Dim	strSQL, _
	strOrgName, _
	dUpdateSchedule, _
	strDetailLink, _
	strRPCDetailLink, _
	strUpdateText, _
	strUpdateLink, _
	strEmailLink, _
	strAlertColumn, _
	i

If Nl(strFromSQL) Then
	Exit Sub
End If
strSQL = "SELECT " & _
		IIf(Nl(strTopSpecial),vbNullString,"TOP " & strTopSpecial & " ") & _
		getFields() & vbCrLf & "FROM "

If Nl(strWhereSQL) Then
	strSQL = strSQL & strFromSQL
Else
	strSQL = strSQL & strFromSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If

strSQL = strSQL & vbCrLf & "ORDER BY " & getOrderBy()

'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
'Response.Flush()

cmdOpList.CommandText = strSQL
rsOpList.Open cmdOpList

If Err.Number <> 0 Then
%>
<root><error><%= JSONQs(Err.Message, True) %></error><recordset/></root>
<%
	Exit Sub
End If

With rsOpList

If .EOF Then
%> 
<root><error/><recordset/></root>
<%
Else
%>
<root><error/>
<recordset>
<%
i = 0

Dim fldVNUM, fldOPID, fldPositionTitle
Set fldVNUM = .Fields("VNUM")
Set fldOPID = .Fields("OP_ID")
Set fldPositionTitle = .Fields("POSITION_TITLE")


Dim strAccessURL
strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPageFull,"$1",True,False,False,False)
strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

Dim strDetailLinkTemplate, strRPCDetailLinkTemplate
strDetailLinkTemplate =  "https://" & strAccessURL & _
		makeVOLDetailsLink("[VNUMVNUM]", vbNullString, vbNullString) 
strRPCDetailLinkTemplate = "https://" & strAccessURL & "/" & _
		makeLink("rpc/opportunity/[VNUMVNUM]", "format=xml", vbNullString) 

While Not .EOF
	If opt_fld_bOrgVOL Then
		strOrgName = rsOpList.Fields("ORG_NAME_FULL")
	End If
	strDetailLink = Replace(strDetailLinkTemplate, "[VNUMVNUM]", fldVNUM.Value)
	strRPCDetailLink = Replace(strRPCDetailLinkTemplate, "[VNUMVNUM]", fldVNUM.Value)

	dUpdateSchedule = Null
	If opt_fld_bUpdateScheduleVOL Or opt_bUpdateVOL Then
		If Not Nl(.Fields("UPDATE_SCHEDULE")) Then
			dUpdateSchedule = DateValue(.Fields("UPDATE_SCHEDULE"))
		End If
	End If
	i = i + 1
	strAlertColumn = vbNullString
	If opt_fld_bAlertVOL Then
		If .Fields("IS_SHARED") Then
			strAlertColumn = "S"
		End If
		If .Fields("IS_DELETED") Then
			strAlertColumn = strAlertColumn & "X"
		ElseIf .Fields("TO_BE_DELETED") Then
			strAlertColumn = strAlertColumn & "P"
		End If
		If Not opt_bDispTableVOL And .Fields("NON_PUBLIC") Then
			strAlertColumn = "N"
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
	End If
%>
<record VNUM=<%= AttrQs(fldVNUM.Value) %> OPID=<%= AttrQs(fldOPID.Value) %>>
<field name="RECORD_DETAILS"><%=XMLEncode(strDetailLink)%></field>
<field name="API_RECORD_DETAILS"><%=XMLEncode(strRPCDetailLink)%></field>
<%If opt_fld_bAlertVOL Then%>
<field name="ALERT"><%= XMLEncode(strAlertColumn) %></field>
<%End If%>
<%If opt_fld_bPosition Then%>
<field name="POSITION_TITLE"><%= XMLEncode(fldPositionTitle) %></field>
<%End If%>
<%If opt_fld_bOrgVOL Then%>
<field name="ORG_NAME"><%= XMLEncode(strOrgName) %></field>
<%End If%>
<%If opt_fld_bComm Then%>
<field name="COMM_BALLS"><%= XMLEncode(.Fields("COMM_BALLS"))%></field>
<%End If%>
<%If opt_fld_bDuties Then%>
<field name="DUTIES"><%=XMLEncode(textToHTML(.Fields("DUTIES")))%></field>
<%End If%>
<%If opt_fld_bRecordOwnerVOL Then%>
<field name="RECORD_OWNER"><%=XMLEncode(.Fields("RECORD_OWNER")) %></field>
<%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<field name=<%=AttrQs(indOrgFldData.fName)%>><%=XMLEncode(textToHTML(.Fields(indOrgFldData.fName)))%></field>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleVOL Then%>
<field name="UPDATE_SCHEDULE"><%=XMLEncode(.Fields("UPDATE_SCHEDULE"))%></field>
<%End If%>
</record>
<%
	
	.MoveNext
	If i Mod 500 = 0 Then
		Response.Flush
	End If
Wend
%>
</recordset></root>
<%
End If

	.Close
End With

End Sub

Private Sub Class_Terminate()
	Set cmdOpList = Nothing
	Set rsOpList = Nothing
End Sub

End Class
%>
