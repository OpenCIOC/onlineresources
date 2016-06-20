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
<!--#include file="../text/txtSetup.asp" -->
<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Call makePageHeader(TXT_VOL_OP_CS_MANAGMENT, TXT_VOL_OP_CS_MANAGMENT, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("comms_vol.asp")%>"><%= TXT_RETURN_TO_VC %></a>]</p>
<h1><%= TXT_VOL_OP_CS_MANAGMENT %></h1>
<%
	Dim cmdOPCommunitySetListCount, rsOPCommunitySetListCount
	Set cmdOPCommunitySetListCount = Server.CreateObject("ADODB.Command")
	With cmdOPCommunitySetListCount
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_OP_CommunitySet_lc"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandTimeout = 0
		Set rsOPCommunitySetListCount = .Execute
	End With

	Dim intTotalLocalActive, _
		intTotalLocalExpired, _
		intTotalLocalDeleted, _
		intTotalLocal, _
		intTotalSharedActive, _
		intTotalSharedExpired, _
		intTotalSharedDeleted, _
		intTotalShared, _
		intCommunitySetID

	intCommunitySetID = -1

	Dim fldCommunitySetID, _
		fldCommunitySetName, _
		fldActiveCount, _
		fldExpiredCount, _
		fldDeletedCount, _
		fldSharedActiveCount, _
		fldSharedExpiredCount, _
		fldSharedDeletedCount

	With rsOPCommunitySetListCount
		If Not .EOF Then
			intTotalLocalActive = .Fields("TOTAL_IN_ACTIVE")
			intTotalLocalExpired = .Fields("TOTAL_IN_EXPIRED")
			intTotalLocalDeleted = .Fields("TOTAL_IN_DELETED")
			intTotalLocal = intTotalLocalActive + intTotalLocalExpired + intTotalLocalDeleted
			If g_bOtherMembersActive Then
				intTotalSharedActive = .Fields("TOTAL_SHARED_ACTIVE")
				intTotalSharedExpired = .Fields("TOTAL_SHARED_EXPIRED")
				intTotalSharedDeleted = .Fields("TOTAL_SHARED_DELETED")
				intTotalShared = intTotalSharedActive + intTotalSharedExpired + intTotalSharedDeleted
			Else
				intTotalShared = 0
			End If
		End If
	End With

	If intTotalLocal + intTotalShared = 0 Then
%>
<p><%=TXT_NO_VALUES_AVAILABLE%></p>
<%	
	Else
%>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th class="RevTitleBox"><%=TXT_COMMUNITY_SETS%></th>
	<th class="RevTitleBox"><%=TXT_COMMUNITIES_IN%><%If intTotalShared > 0 Then%> (<%=TXT_LOCAL%>)<%End If%></th>
	<th class="RevTitleBox"><%=TXT_COMMUNITIES_OUT%><%If intTotalShared > 0 Then%> (<%=TXT_LOCAL%>)<%End If%></th>
<%
		If intTotalShared > 0 Then
%>
	<th class="RevTitleBox"><%=TXT_COMMUNITIES_IN%> (<%=TXT_SHARED%>)</th>
	<th class="RevTitleBox"><%=TXT_COMMUNITIES_OUT%> (<%=TXT_SHARED%>)</th>
<%
		End If
%>
	<th class="RevTitleBox"><%=TXT_ACTION %></th>
</tr>
<%
		Set rsOPCommunitySetListCount = rsOPCommunitySetListCount.NextRecordset
	
		With rsOPCommunitySetListCount
			Set fldCommunitySetID = .Fields("CommunitySetID")
			Set fldCommunitySetName = .Fields("SetName")
			Set fldActiveCount = .Fields("OPPS_IN_ACTIVE")
			Set fldExpiredCount = .Fields("OPPS_IN_EXPIRED")
			Set fldDeletedCount = .Fields("OPPS_IN_DELETED")
			Set fldSharedActiveCount = .Fields("OPPS_SHARED_ACTIVE")
			Set fldSharedExpiredCount = .Fields("OPPS_SHARED_EXPIRED")
			Set fldSharedDeletedCount = .Fields("OPPS_SHARED_DELETED")

			While Not .EOF And Not Nl(intCommunitySetID)
				intCommunitySetID = fldCommunitySetID
				If Not Nl(intCommunitySetID) Then
%>
<tr>
	<td><%=Server.HTMLEncode(.Fields("SetName"))%></td>
	<td><span class="Info"><%=fldActiveCount.Value%></span>
		<%If fldExpiredCount.Value + fldDeletedCount.Value > 0 Then%> (<span class="Alert"><%=StringIf(fldExpiredCount.Value>0,"+ " & fldExpiredCount.Value & "&nbsp;" & TXT_EXPIRED)%><%=StringIf(fldDeletedCount.Value>0,StringIf(fldExpiredCount.Value+fldDeletedCount.Value>0,", ") & "+ " & fldDeletedCount.Value & "&nbsp;" & TXT_DELETED)%></span>)<%End If%></td>
	<td><span class="Info"><%=intTotalLocalActive - fldActiveCount.Value%></span>
		<%If (intTotalLocalDeleted + intTotalLocalExpired) > (fldExpiredCount.Value + fldDeletedCount.Value) Then%> (<span class="Alert"><%=StringIf(intTotalLocalExpired>fldExpiredCount.Value,"+ " & intTotalLocalExpired-fldExpiredCount.Value & "&nbsp;" & TXT_EXPIRED)%><%=StringIf(intTotalLocalDeleted>fldDeletedCount.Value,StringIf((intTotalLocalDeleted>fldDeletedCount.Value) And (intTotalLocalExpired>fldExpiredCount.Value),", ") & "+ " & intTotalLocalDeleted-fldDeletedCount.Value & "&nbsp;" & TXT_DELETED)%></span>)<%End If%></td>

<%
					If intTotalShared > 0 Then
%>
	<td><span class="Info"><%=fldSharedActiveCount.Value%></span>
		<%If fldSharedExpiredCount.Value + fldSharedDeletedCount.Value > 0 Then%> (<span class="Alert"><%=StringIf(fldSharedExpiredCount.Value>0,"+ " & fldSharedExpiredCount.Value & "&nbsp;" & TXT_EXPIRED)%><%=StringIf(fldSharedDeletedCount.Value>0,StringIf(fldSharedExpiredCount.Value+fldSharedDeletedCount.Value>0,", ") & "+ " & fldSharedDeletedCount.Value & "&nbsp;" & TXT_DELETED)%></span>)<%End If%></td>
	<td><span class="Info"><%=intTotalSharedActive - fldSharedActiveCount.Value%></span>
		<%If (intTotalSharedDeleted + intTotalSharedExpired) > (fldSharedExpiredCount.Value + fldSharedDeletedCount.Value) Then%> (<span class="Alert"><%=StringIf(intTotalSharedExpired>fldSharedExpiredCount.Value,"+ " & intTotalSharedExpired-fldSharedExpiredCount.Value & "&nbsp;" & TXT_EXPIRED)%><%=StringIf(intTotalSharedDeleted>fldSharedDeletedCount.Value,StringIf((intTotalSharedDeleted>fldSharedDeletedCount.Value) And (intTotalSharedExpired>fldSharedExpiredCount.Value),", ") & "+ " & intTotalSharedDeleted-fldSharedDeletedCount.Value & "&nbsp;" & TXT_DELETED)%></span>)<%End If%></td>
<%
					End If
%>
	<td>
		<form action="comms_vol_opcm2.asp" method="post">
		<div style="display:none">
		<%=g_strCacheFormVals%>
		<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
		<input type="hidden" name="SetName" value=<%=AttrQs(fldCommunitySetName)%>>
		</div>
		<input type="submit" value="<%= TXT_EDIT %>" class="btn btn-default">
		</form>
	</td>
</tr>

<%
					.MoveNext
				End If
			Wend
		End With
%>
</table>
<%
		With rsOPCommunitySetListCount
			If Not .EOF And Nl(intCommunitySetID) Then
%>
<p class="Alert"><%=Replace(TXT_WARN_ORPHANED_RECORDS, "[COUNT]", fldActiveCount.Value+fldSharedActiveCount.Value+fldExpiredCount.Value+fldSharedExpiredCount.Value+fldDeletedCount.Value+fldSharedDeletedCount.Value)%>
<%If (fldExpiredCount.Value+fldSharedExpiredCount.Value+fldDeletedCount.Value+fldSharedDeletedCount.Value)>0 Then%><%=" " & (fldExpiredCount.Value+fldSharedExpiredCount.Value+fldDeletedCount.Value+fldSharedDeletedCount.Value) & " " & TXT_WARN_ORPHANED_DELETED %><%End If%></p>
<%
			End IF
		End With
	End If

	Set cmdOPCommunitySetListCount = Nothing
	Set rsOPCommunitySetListCount = Nothing
%>

<%
Call makePageFooter(True)
%>

<!--#include file="../includes/core/incClose.asp" -->

