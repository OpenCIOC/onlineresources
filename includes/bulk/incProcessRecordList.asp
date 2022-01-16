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
' Purpose:		Process list of records from select checkbox
'
%>
<!--#include file="../search/incSearchQString.asp" -->
<% 
Call finalQStringTidy()

Dim	strIDList, _
	strActionType, _
	intPBID, _
	intIGID, _
	strDropDownContents, _
	bError

bError = False
strActionType = Request("ActionType")
strIDList = Replace(Request("IDList")," ",vbNullString)

If user_bLimitedViewCIC Then
	intPBID = user_intPBID
Else
	intPBID = Request("PBID")
	If Not IsIDType(intPBID) Then
		intPBID = Null
	End If
End If

intIGID = Request("IGID")
If Not IsIDList(intIGID) Then
	intIGID = Null
End If

If strActionType = "U" And g_bNoEmail Then
	Call securityFailure()
End If

If strActionType = "G" Then
	Call addScript(ps_strPathToStart & makeAssetVer("scripts/formPrintMode.js"), "text/javascript")
End If

If strActionType = "N" Then
	If ps_intDbArea = DM_CIC Then
		Call getDisplayOptionsCIC(g_intViewTypeCIC, Not user_bCIC)
	Else
		Call getDisplayOptionsVOL(g_intViewTypeVOL, Not user_bVOL)
	End If

End If

Call makePageHeader(TXT_SEARCH_RESULTS, TXT_SEARCH_RESULTS, True, True, True, True)

If Nl(strIDList) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf ps_intDbArea = DM_VOL And Not IsVNUMList(strIDList) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf ps_intDbArea = DM_CIC And Not IsNUMList(strIDList) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
Else
	If strActionType <> "N" Then
%>
<p>[ <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a> ]</p>
<%
	End If

	Select Case strActionType

'################################
' EXPORT
'################################
		Case "E"
%>
<h2><%=TXT_SELECTED_EXPORT%></h2>
<p><%=TXT_PREPARE_EXPORT%></p>
<form action="<%=ps_strPathToStart%>export.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=ps_intDbArea%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%
'################################
' EMAIL RECORD LIST
'################################
		Case "EL"
%>
<h2><%=TXT_EMAIL_RECORD_LIST%></h2>
<p><%=TXT_PREPARE_EMAIL_RECORD_LIST%></p>
<form action="recordlist" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="_method" value="get">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' STATISTICAL REPORT
'################################
		Case "G"
%>
<!--#include file="../../text/txtStats.asp" -->
<!--#include file="../stats/incStatsForm.asp" -->
			<%If user_intCanViewStatsDOM > STATS_NONE Then%>
<p><%=TXT_PREPARE_STATS_REPORT%></p>
<%
			

				
				Call printStatsForm(strIDList)
				%>
	<form class="NotVisible" name="stateForm" id="stateForm">
	<textarea id="cache_form_values"></textarea>
	</form>
	<%= makeJQueryScriptTags() %>
	<%= JSVerScriptTag("scripts/datepicker.js") %>
	<script type="text/javascript">
	jQuery(function() {
			init_cached_state();
			restore_cached_state();
			});
	</script>

				<%
				g_bListScriptLoaded = True 
			Else
				Call handleError(TXT_NO_PERMISSIONS, vbNullString, vbNullString)
			End If

'################################
' BULK GEOCODING
'################################
		Case "GE"
%>
<!--#include file="../list/incGeoCodeTypeList.asp" -->
<%
			Call openMappingCategoryListRst()
%>
<h2><%=TXT_SELECTED_GEOCODING%></h2>
<form action="geocode.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<p><span class="FieldLabelLeftClr"><%=TXT_GEOCODE_USING%></span>
<br><%=makeGeoCodeTypeList(GC_CURRENT, "GEOCODE_TYPE", True)%></p>
<p><input type="checkbox" name="RetryWOPostal" id="retry_without_postal_code" value="on"> <label for="retry_wo_postal"><%=TXT_RETRY_WITHOUT_POSTAL%></label></p>
<p><span class="FieldLabelLeftClr"><%=TXT_MAP_MARKER%></span>
<br><%=makeMappingCategoryList(vbNullString, "MAP_PIN", True)%></p>
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%
			Call closeMappingCategoryListRst()

'################################
' PRINT RECORD LIST
'################################
		Case "P"
%>
<!--#include file="../../text/txtPrintList.asp" -->
<!--#include file="../../text/txtSearchBasicCIC.asp" -->
<!--#include file="../../text/txtSearchAdvanced.asp" -->
<!--#include file="../../text/txtSearchAdvancedCIC.asp" -->
<!--#include file="../search/incAdvSearchPub.asp" -->
<!--#include file="../print/incPrintOptions.asp" -->
<%

'################################
' RESTORE RECORDS
'################################
		Case "R"
%>
<h2><%=TXT_SELECTED_DELETE%></h2>
<form action="delete_mark.asp" method="post">
<%=g_strCacheFormVals%>
<select name="Unmark">
	<option value=""><%=TXT_SET_DELETION_DATE%></option>
	<option value="on"><%=TXT_RESTORE_RECORDS%></option>
</select>
<input type="hidden" name="UseVNUM" value="on">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' EMAIL UPDATE REQEUST
'################################
		Case "U"
%>
<h2><%=TXT_BULK_EMAIL_REQUEST%></h2>
<p><%=TXT_PREPARE_EMAIL%></p>
<form action="<%=makeLinkAdmin("email_prep.asp",vbNullString)%>" method="post">
<input type="hidden" name="DM" value="<%=ps_intDbArea%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' NEW RECORDSET
'################################
		Case "N"
			If Not g_bPrintMode Then
				Response.Write(render_gtranslate_ui())
			End If
			Dim strFrom, _
				strWhere

			If ps_intDbArea = DM_VOL Then
				Call getDisplayOptionsVOL(g_intViewTypeVOL, Not user_bVOL)
	
				Dim objOpTable	
				Set objOpTable = New OpRecordTable
	
				strFrom = "VOL_Opportunity vo" & vbCrLf & _
					"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
					"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
					"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"
				strWhere = "vo.VNUM IN (" & QsStrList(strIDList) & ")"
%>
<br>
<%
				Call objOpTable.setOptions(strFrom, strWhere, vbNullString, True, vbNullString, vbNullString)
				Call objOpTable.makeTable()
				Set objOpTable = Nothing
			Else
				Dim bNearSort

				bNearSort = Request("GeoLocatedNearSort") = "on"
				decNearLatitude = Trim(Request("GeoLocatedNearLatitude"))
				decNearLongitude = Trim(Request("GeoLocatedNearLongitude"))
				If Nl(decNearLatitude) Or Nl(decNearLongitude) Then
					decNearLatitude = vbNullString
					decNearLongitude = vbNullString
				ElseIf Not IsNumeric(decNearLatitude) Or Not IsNumeric(decNearLongitude) Then
					decNearLatitude = vbNullString
					decNearLongitude = vbNullString
				Else
					decNearLatitude = CDbl(decNearLatitude)
					decNearLongitude = CDbl(decNearLongitude)
					If Not (decNearLatitude >= -180 And decNearLatitude <= 180 And decNearLongitude >= -180 and decNearLongitude <= 180) Then
						decNearLatitude = vbNullString
						decNearLongitude = vbNullString
					End If
				End If
				
				If Not Nl(decNearLatitude) and Not Nl(decNearLongitude) And bNearSort Then
					strParamSQL = "DECLARE @NearLatitude [decimal](11,7)," & vbCrLf & _
								"@NearLongitude [decimal](11,7)" & vbCrLf & _
								"SET @NearLatitude = ?" & vbCrLf & _
								"SET @NearLongitude = ?" & vbCrLf 
					With cmdOrgList
						.Parameters.Append .CreateParameter("@NearLatitude", adDecimal, adParamInput)	
						.Parameters("@NearLatitude").Precision = 11
						.Parameters("@NearLatitude").NumericScale = 7
						.Parameters("@NearLatitude").Value = decNearLatitude
						.Parameters.Append .CreateParameter("@NearLongitude", adDecimal, adParamInput)	
						.Parameters("@NearLongitude").Precision = 11
						.Parameters("@NearLongitude").NumericScale = 7
						.Parameters("@NearLongitude").Value = decNearLongitude
					End With

				End If

				Dim objOrgTable
				Set objOrgTable = New OrgRecordTable
	
				strFrom = "GBL_BaseTable bt " & vbCrLf & _
					"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
					"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
					"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
					"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
					"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=" & g_objCurrentLang.LangID

				strWhere = "bt.NUM IN (" & QsStrList(strIDList) & ")"
%>
<br>
<%
				Call objOrgTable.setOptions(strFrom, strWhere, vbNullString, True, False, strQueryString, CAN_RANK_NONE, decNearLatitude, decNearLongitude, bNearSort)
				Response.Write(render_gtranslate_ui())
				Call objOrgTable.makeTable()
				Set objOrgTable = Nothing

				Call makeMappingSearchFooter()
			End If

'################################
' MARK PUBLIC / NON-PUBLIC
'################################
		Case "NP"
%>
<h2><%=TXT_SELECTED_PUBLIC_NONPUBLIC%></h2>
<form action="pnp.asp" method="post">
<%=g_strCacheFormVals%>
<select name="SetTo">
	<option value="P"><%=TXT_SET_PUBLIC%></option>
	<option value="N"><%=TXT_SET_NONPUBLIC%></option>
</select>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
'CHANGE RECORD OWNER
'################################
		Case "RO"
%>
<h2><%=TXT_SELECTED_CHANGE_OWNER%></h2>
<form action="ro.asp" method="post">
<%=g_strCacheFormVals%>
<%
Call openAgencyListRst(ps_intDbArea,False,True)
%>
<%=makeAgencyList(vbNullString, "SetTo", True, False)%>
<%
Call closeAgencyListRst()
%>

<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' FIND AND REPLACE
'################################
		Case "F"
			Const RT_FINDREPLACE = 0
			Const RT_INSERT = 1
			Const RT_CLEARFIELD = 2
			Const RT_CHECKLIST = 3
			Const RT_NAME = 4
			Const RT_CONTACT = 5
			Const RT_RECORDNOTE = 6
%>
<!--#include file="../../text/txtFindReplace.asp" -->
<h2><%=TXT_FIND_REPLACE_ON_SELECTED%></h2>
<p><span class="AlertBubble"><%=TXT_INST_RESTRICTIONS%></span></p>
<p class="Info"><%=TXT_THERE_ARE_SIX_TOOLS%></p>
<ul>
	<li><%=TXT_TOOL_1%></li>
	<li><%=TXT_TOOL_2%></li>
	<li><%=TXT_TOOL_3%></li>
	<li><%=TXT_TOOL_4%></li>
	<li><%=TXT_TOOL_5%></li>
	<li><%=TXT_TOOL_6%></li>
	<li><%=TXT_TOOL_7%></li>
</ul>
<form action="findreplace.asp" method="post">
<%=g_strCacheFormVals%>
<select name="ReplaceType">
	<option value="<%=RT_FINDREPLACE%>"><%=TXT_FIND_AND_REPLACE_TOOL%></option>
	<option value="<%=RT_INSERT%>"><%=TXT_PREPEND_APPEND%></option>
	<option value="<%=RT_CLEARFIELD%>"><%=TXT_CLEAR_FIELD_TOOL%></option>
	<option value="<%=RT_CHECKLIST%>"><%=TXT_CHECKLIST_TOOL%></option>
	<option value="<%=RT_NAME%>"><%=TXT_NAME_TOOL%></option>
	<option value="<%=RT_CONTACT%>"><%=TXT_CONTACT_TOOL%></option>
	<option value="<%=RT_RECORDNOTE%>"><%=TXT_RECORD_NOTE_TOOL%></option>
</select>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' PRINT MAP
'################################
		Case "PM"		
			Const OT_LETTER_PORTRAIT = 0
			Const OT_LETTER_LANDSCAPE = 1
			Const OT_LEGAL_PORTRAIT = 2
			Const OT_LEGAL_LANDSCAPE = 3
			Const OT_CUSTOM = 4

			If UBound(Split(strIDList, ",")) > 99 Then
				Call handleError(TXT_ERROR & TXT_PRINT_MAP_TOO_MANY_RECORDS, _
						vbNullString, vbNullString)
			Else
			%>
<h2><%=TXT_PRINT_MAP%></h2>
<form action="printmap.asp" method="post" target="_blank">
<div class="NotVisible">
<%=g_strCacheFormVals%>
<input type="hidden" name="IDList" value="<%=strIDList%>">
</div>
<%=TXT_INST_PRINT_MAP%>
<p><span class="FieldLabelClr"><%=TXT_PAPER_TYPE%></span>&nbsp;<select name="Orientation">
	<option value="<%=OT_LETTER_PORTRAIT%>" selected><%=TXT_LETTER_PORTRAIT%></option>
	<option value="<%=OT_LETTER_LANDSCAPE%>"><%=TXT_LETTER_LANDSCAPE%></option>
	<option value="<%=OT_LEGAL_PORTRAIT%>"><%=TXT_LEGAL_PORTRAIT%></option>
	<option value="<%=OT_LEGAL_LANDSCAPE%>"><%=TXT_LEGAL_LANDSCAPE%></option>
</select></p>

<input type="submit" value="<%=TXT_NEXT_STEP & " " & TXT_NEW_WINDOW%>">
</form>
			<%
			End If

'################################
' Sharing Profile
'################################
		Case "SP"
%>
<!--#include file="../list/incSharingProfileList.asp" -->
<h2><%=TXT_SELECTED_SHARING_PROFILE%></h2>
<form action="<%= ps_strPathToStart %>admin/sharingprofile/records" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=ps_intDomain%>">
<select name="Remove">
	<option value=""><%= TXT_ADD %></option>
	<option value="on"><%= TXT_REMOVE %></option>
</select>
<% ' LIST OF Sharing Profiles
Call openSharingProfileListRst(ps_intDomain)
Response.Write(makeSharingProfileList(vbNullString, "ProfileID", False, True))
Call closeSharingProfileListRst()
%>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>

<%
'################################
' Agency
'################################
	Case "AO"
%>
<!--#include file="../../text/txtSetAgency.asp" -->
<h2><%=TXT_CHANGE_RECORD_AGENCY%></h2>
<form action="<%= ps_strPathToStart %>set_agency.asp" method="post">
<div class="NotVisible">
<%= g_strCacheFormVals %>
<input type="hidden" name="IDList" value="<%=strIDList%>">
</div>
<%
	Dim intOrgLevelCount, strSuggestion, strName, strSuggestNum, bIsAgency
	Dim cmdPotentialOrg, rsPotentialOrg
	Set cmdPotentialOrg = Server.CreateObject("ADODB.Command")
		
	With cmdPotentialOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_NUMsToPotentialOrg_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@IDList", adLongVarChar, adParamInput, -1, strIDList)
		.Execute
	End With

	Set rsPotentialOrg = Server.CreateObject("ADODB.Recordset")
	With rsPotentialOrg
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdPotentialOrg
	End With

	intOrgLevelCount = rsPotentialOrg("ORG_LEVEL_1_COUNT")

	If intOrgLevelCount > 1 Then
	%>
	<p><span class="AlertBubble"><%= Replace(TXT_MULTIPLE_ORG_LEVEL_1_WARNING, "[COUNT]", intOrgLevelCount) %></span></p>
	<%
	End If

	Set rsPotentialOrg = rsPotentialOrg.NextRecordset
	%>
	<strong><%=TXT_AGENCY_NUM & TXT_COLON%></strong> <input type="text" id="ORG_NUM" name="ORG_NUM" size="9" maxlength="8" class="record-num" value="">
	<%
	strSuggestion = vbNullString
	With rsPotentialOrg
		While Not .EOF
			strSuggestNum = .Fields("NUM")
			strName = .Fields("ORG_NAME")
			bIsAgency = .Fields("IS_AGENCY")
			strSuggestion = strSuggestion & _
				"<li><input type=""button"" value=" & AttrQs(strSuggestNum) & " class=""suggested-num"" onclick=""$('#ORG_NUM')[0].value='" & strSuggestNum & "'; return false;""> <a target=""_blank"" href=" & _
					AttrQs(makeDetailsLink(strSuggestNum, vbNullString, vbNullString)) & ">" & Ns(strName) & "</a> " & StringIf(Not bIsAgency,  "<span class=""Alert"">[ " & TXT_NOT_AGENCY_WARNING & " ]</span>") & "</li>"

			.MoveNext
		Wend
	End With

	If Not Nl(strSuggestion) Then
	%><ul style="list-style: none; padding: 0"><%= strSuggestion %></ul> <%
	End If

	If rsPotentialOrg.State <> adStateClosed Then
		rsPotentialOrg.Close
	End If
	Set cmdPotentialOrg = Nothing
	Set rsPotentialOrg = Nothing
%>
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' Reminder
'################################
	Case "AR"
		Dim strIDName, strID
		strIDName = IIf(ps_intDomain = DM_VOL, "VNUM", "NUM")
		
%>

<h2><%=TXT_CREATE_NEW_REMINDER%></h2>
<form action="<%= ps_strPathToStart %>reminders/add" method="post">
<div class="NotVisible">
<%= g_strCacheFormVals %>
<input type="hidden" name="_force_method" value="GET">
<% For Each strID in Split(CStr(strIDList), ",") %>
<input type="hidden" name="<%=strIDName%>" value="<%=strID%>">
<% Next %>
</div>
<input type="submit" value="<%=TXT_NEXT_STEP%>">
</form>
<%

'################################
' ADD OR REMOVE CODES
'################################
		Case Else
			Select Case ps_intDbArea	
				Case DM_CIC
%>
<!--#include file="incCICAddRemove.asp" -->
<%
				Case DM_VOL
%>
<!--#include file="incVOLAddRemove.asp" -->
<%

				Case Else
					bError = True
					Call handleError(TXT_ERROR & TXT_UNABLE_DETERMINE_TYPE, _
							vbNullString, _
							vbNullString)
			End Select
			If Not bError Then
				If (ps_intDbArea <> DM_CIC Or (strActionType <> "GH" Or Not Nl(intPBID))) And _
					(ps_intDbArea <> DM_VOL Or (strActionType <> "AI" Or Not Nl(intIGID) Or g_bOnlySpecificInterests)) Then
%>
<form action="addremovecode.asp" method="post">
<input type="hidden" name="CType" value="<%=strActionType%>">
<%					If ps_intDbArea = DM_CIC And Not Nl(intPBID) Then%>
<input type="hidden" name="PBID" value="<%=intPBID%>">
<%					End If%>
<%					If ps_intDbArea = DM_VOL And Not Nl(intIGID) Then%>
<input type="hidden" name="IGID" value="<%=intIGID%>">
<%					End If%>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<%If g_bUseTaxonomy And strActionType = "GH" Then%>
<p><span class="AlertBubble"><%=TXT_INST_ADD_HEADING_2%></span></p>
<%End If%>
<table class="BasicBorder cell-padding-2">
<%
					If strActionType = "GH" And Not Nl(intPBID) Then
						If Not Nl(strListGenHeadingPub) Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUBLICATION%></td>
	<td><%=strListGenHeadingPub%></td>
</tr>
<%
						End If
					End If
					If strActionType = "AI" And Not Nl(intIGID) Then
						If Not Nl(strListGroupNames) Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_GENERAL_AREAS_OF_INTEREST%></td>
	<td><%=strListGroupNames%></td>
</tr>
<%
						End If
					End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ACTION%></td>
	<td><select name="ActionType" id="action_type_select">
		<option value="A"><%=TXT_ADD%></option>
		<option value="D"><%=TXT_DELETE%></option>
		<option value="DXXX"><%=TXT_DELETE_ALL%></option>
		</select>
		<span id="confirm_delete_all" style="display:none">
		<br /><input type="checkbox" name="Confirmed" />&nbsp;<%=TXT_CONFIRM_DELETE_ALL%></span></td>
</tr>
<%
					Dim strItemType
					Select Case strActionType
						Case "NC"
							strItemType = TXT_CODE
						Case "SBJ"
							strItemType = TXT_VALUE
						Case "TX"
							strItemType = TXT_CODE
						Case Else
							strItemType = TXT_ITEMS
					End Select
%>
<tr id="action_item_selection_row">
	<td class="FieldLabelLeft"><%=strItemType%></td>
	<td><%=strDropDownContents%></td>
</tr>
</table>
<%
				Else
%>
<form action="<%=ps_strThisPage%>" method="post">
<input type="hidden" name="ActionType" value="<%=strActionType%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<p><%=strDropDownContents%></p>
<%
				End If
%>
<p><input type="submit" value="<%=TXT_SUBMIT%>"></p>
</form>
<%
			End If
%>
<%= makeJQueryScriptTags() %>
<script type="text/javascript">
	jQuery(function($) {
		var actionTypeSelect = function(actionType) {
			if ($(this).val() == 'DXXX') {
				$('#action_item_selection_row').hide();
				$('#confirm_delete_all').show();
			} else {
				$('#action_item_selection_row').show();
				$('#confirm_delete_all').hide();
			}
		};
		$('#action_type_select').on('change', actionTypeSelect).change()
	});
</script>
<%
	End Select
End If
%>
<%
Call makePageFooter(True)
%>


