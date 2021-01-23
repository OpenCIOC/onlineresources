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
' Purpose: 		Support Client Tracker integration functionality.
'
'
%>
<script language="python" runat="server">
import ipaddress

from cioc.core import clienttracker

def myListDetailsAddRecord(strID):
	return Response.Write(six.text_type(clienttracker.my_list_details_add_record(pyrequest, six.text_type(strID))))

def myListAddRecordBasicUI(strID):
	return six.text_type(clienttracker.my_list_add_record_basic_ui(pyrequest, six.text_type(strID)))
def ip_in_networks(networks, remote_addr):
	network_list = []
	for addr in [y.strip() for y in six.text_type(networks).split(u',')]:
		if not addr:
			continue
		try:
			network_list.append(ipaddress.ip_network(addr))
		except ValueError:
			pass

	ipaddr = ipaddress.ip_address(six.text_type(remote_addr))

	return any(ipaddr in x for x in network_list)

def get_ct_session_vars():
	vals = pyrequest.cioc_get_cookie('ctlaunched').split(':')
	if len(vals) != 3:
		return None, None, None

	return vals
</script>

<%
Function ctClientCanMakeRequest()
	ctClientCanMakeRequest = False
	If Nl(g_strClientTrackerIP) Then
		Exit Function
	End If

	Dim strRemoteAddr
	strRemoteAddr = getRemoteIP()

	If strRemoteAddr = "127.0.0.1" Or ip_in_networks(g_strClientTrackerIP, strRemoteAddr) Then
		ctClientCanMakeRequest = True
	End If
End Function

Sub myListResultsAddRecordHeader()
	Dim bLaunched
	bLaunched = ctHasBeenLaunched()
	If ( g_bMyListCIC And ps_intDbArea = DM_CIC ) Or ( g_bMyListVOL And ps_intDbArea = DM_VOL ) Or bLaunched Then
	%><th class="ListUI"><span id="list_header_text" style="white-space: nowrap;"><%=IIf(g_bEnableListModeCT, TXT_CT_CLIENT_TRACKER,TXT_MY_LIST)%></span><% If bLaunched Then %><span id="ct_header_text" style="display: none;"><%=TXT_CT_CLIENT_TRACKER%></span><%End If%></th><%
	End If
End Sub

Function myListResultsAddRecord(strID, bEnableListViewMode, strPrefix, strSuffix)
	myListResultsAddRecord = vbNullString

	Dim bLaunched
	bLaunched = ctHasBeenLaunched()
	If ( g_bMyListCIC And ps_intDbArea = DM_CIC ) Or ( g_bMyListVOL And ps_intDbArea = DM_VOL ) Or bLaunched Then
		myListResultsAddRecord = strPrefix
		If bEnableListViewMode Then
			myListResultsAddRecord = myListResultsAddRecord & _
					"<span id=""remove_from_list_" & strID & """ class=""SimulateLink remove_from_list"" data-id=""" & strID & """><img src=""" & ps_strPathToStart & "images/" & IIf(g_bEnableListModeCT, "referral", "list") & "remove.gif"" width=""17"" height=""17"" border=""0"">" & TXT_LIST_REMOVE & "</span>"
		Else 
			myListResultsAddRecord = myListResultsAddRecord & _
					myListAddRecordBasicUI(strID)
		End If
		myListResultsAddRecord = myListResultsAddRecord & strSuffix
	End If
End Function

Function myListGenerateCriteria()
	Dim strRecordListIDs, _
		aRecordListIDs, _
		bInRequest 

	bInRequest = False
	strRecordListIDs = vbNullString

	If ctHasBeenLaunched() Then
		Dim strXML, objCtHttp, aSessionVars

		aSessionVars = get_ct_session_vars()

		strXML = "<?xml version=""1.0"" encoding=""iso-8859-1""?>" & vbCrLf & _
		"<isInRequest xmlns=""http://clienttracker.cioc.ca/schema/"">" & vbCrLf & _
		"	<login>" & XMLEncode(aSessionVars(0)) & "</login>" & vbCrLf & _
		"	<key>" & XMLEncode(aSessionVars(1)) & "</key>" & vbCrLf & _
		"	<ctid>" & XMLEncode(aSessionVars(2)) & "</ctid>" & vbCrLf & _
		"</isInRequest>"

		Set objCtHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
		objCtHttp.setTimeouts 5000, 15000, 10000, 10000 
		objCtHttp.Open "POST", g_strClientTrackerRpcURL & "is_in_request", False
		objCtHttp.SetRequestHeader "Content-Type", "application/xml"
		objCtHttp.Send strXML

		If Err.Number = 0 And objCtHttp.Status = 200 Then
			Dim objXML, objError, objYes, objNo, objPrevious

			Set objXML = Server.CreateObject("MSXML2.DOMDocument.6.0")
			objXML.async = false
			objXML.setProperty "SelectionNamespaces", "xmlns:ct='http://clienttracker.cioc.ca/schema/'"
			objXML.setProperty "SelectionLanguage", "XPath"

			If objXML.loadXML(objCtHttp.responseText) Then
				Set objError = objXML.selectNodes("/ct:response/ct:error")
				Set objYes = objXML.selectNodes("/ct:response/ct:yes")
				Set objNo = objXML.selectNodes("/ct:response/ct:no")
				If objError.length = 0 Then
					If objYes.length > 0 And objNo.length = 0 Then
						bInRequest = True
						Dim strRequestCon, strID
						Dim bAdd
						strRequestCon = vbNullString
						For Each strID in objXML.selectNodes("/ct:response/ct:yes/ct:id")
							strID = strID.text
							bAdd = False
							If ps_intDbArea = DM_CIC And IsNUMType(strID) Then
									bAdd = True
							ElseIf ps_intDbArea = DM_VOL And IsVNUMType(strID) Then
									bAdd = True
							End If
							If bAdd Then
								strRecordListIDs = strRecordListIDs & strRequestCon & "'" & strID & "'"
								strRequestCon=", "
								g_bEnableListModeCT = True
							End If
						Next
					End If
				End If
			End If
		End If
	End If
	If Not bInRequest Then
		aRecordListIDs = getSessionValue(ps_strDbArea & "RecordList")
		If Not Nl(aRecordListIDs) Then
			aRecordListIDs = Split(aRecordListIDs, ",")
		End If
		If IsArray(aRecordListIDs) Then
			strRecordListIDs = Join(aRecordListIDs,"','")
			If Not Nl(strRecordListIDs) Then
				strRecordListIDs = "'" & strRecordListIDs & "'"
			End If
		End If
	End If

	myListGenerateCriteria = strRecordListIDs
End Function
%>
