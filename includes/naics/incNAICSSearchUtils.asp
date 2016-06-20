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
from cioc.core.naics import link_code, get_exclusions, get_examples

def linkCode(strLinkText, strNAICSCodes, strLinkPage):
	return link_code(pyrequest, strLinkText, strNAICSCodes, strLinkPage)

def getExclusions(strNAICSCode, strLinkPage):
	return get_exclusions(pyrequest, strNAICSCode, strLinkPage)

def getExamples(strNAICSCode):
	return get_examples(pyrequest, strNAICSCode)

</script>

<%
Function getBroaderCodes(strNAICSCode, bCount, strLinkPage)

Dim strCode, _
	strCodeType, _
	strReturn, _
	intUsageCount

Dim cmdBroaderCodes, rsBroaderCodes
set cmdBroaderCodes = Server.CreateObject("ADODB.Command")
With cmdBroaderCodes
 	.ActiveConnection = getCurrentCICBasicCnn()
	If bCount Then
		.CommandText = "dbo.sp_NAICS_BroaderCodes_slc"
	Else
		.CommandText = "dbo.sp_NAICS_BroaderCodes_sl"
	End If
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@Code",adInteger,1,4,strNAICSCode)
	If bCount Then
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
	End If
End With
Set rsBroaderCodes = Server.CreateObject("ADODB.Recordset")
With rsBroaderCodes
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdBroaderCodes
End With

With rsBroaderCodes
	While Not .EOF
		strCode = .Fields("Code")
		If bCount Then
			intUsageCount = .Fields("UsageCount")
		Else
			intUsageCount = Null
		End If
		strReturn = strReturn & vbCrLf & "<tr VALIGN=""top""><td class=""FieldLabelLeft"">" & getCodeType(Len(.Fields("Code"))) & "</td>" & _
			"<td><strong>" & linkCode(strCode,strCode,strLinkPage) & "</strong></td>" & _
			"<td>" & .Fields("Classification") & IIf(bCount,"&nbsp;(" & intUsageCount & ")",vbNullString) & "</td></tr>"
		.MoveNext
	Wend
End With

getBroaderCodes = strReturn

rsBroaderCodes.Close
Set rsBroaderCodes = Nothing

End Function


Function getNarrowerCodes(strNAICSCode, bCount, strLinkPage)

Dim strCode, _
	strReturn, _
	intUsageCount

Dim cmdNarrowerCodes, rsNarrowerCodes
set cmdNarrowerCodes = Server.CreateObject("ADODB.Command")
With cmdNarrowerCodes
 	.ActiveConnection = getCurrentCICBasicCnn()
	If bCount Then
		.CommandText = "dbo.sp_NAICS_NarrowerCodes_slc"
	Else
		.CommandText = "dbo.sp_NAICS_NarrowerCodes_sl"
	End If
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@Code",adInteger,1,4,strNAICSCode)
	If bCount Then
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
	End If
End With
Set rsNarrowerCodes = Server.CreateObject("ADODB.Recordset")
With rsNarrowerCodes
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdNarrowerCodes
End With

With rsNarrowerCodes
	While Not .EOF
		strCode = .Fields("Code")
		If bCount Then
			intUsageCount = .Fields("UsageCount")
		Else
			intUsageCount = Null
		End If
		strReturn = strReturn & vbCrLf & "<tr VALIGN=""top""><td><strong>" & linkCode(strCode,strCode,strLinkPage) & "</strong></td>" & _
			"<td>" & .Fields("Classification") & IIf(bCount,"&nbsp;(" & intUsageCount & ")",vbNullString) & "</td></tr>"
		.MoveNext
	Wend
End With

getNarrowerCodes = strReturn

rsNarrowerCodes.Close
Set rsNarrowerCodes = Nothing

End Function


Function getShortNAICSInfo(strNAICSCode, strClassification, intUsageCount, bCount, strLinkPage)
	Dim strReturn
	strReturn = "<tr><td class=""FieldLabelLeftClr"">" & linkCode(strNAICSCode,strNAICSCode,strLinkPage) & "</td>" & _
		"<td>" & strClassification & IIf(bCount,"&nbsp;(" & intUsageCount & ")",vbNullString) & "</td></tr>"
	getShortNAICSInfo = strReturn
End Function

Function getBrowseNAICSInfo(strNAICSCode, strClassification, intUsageCount)
	Dim strReturn
	strReturn = "<tr><td class=""FieldLabelLeftClr"">" & strClassification & "&nbsp;(" & intUsageCount & ")</td>" & _
		"<td>[&nbsp;" & linkCode(TXT_SEARCH,strNAICSCode,"results.asp") & IIf(Len(strNAICSCode) < NAICS_NATIONAL_INDUSTRY,"&nbsp;|&nbsp;" & linkCode(TXT_SUB_CATEGORIES,strNAICSCode,"browsebyindustry.asp"),vbNullString) & "&nbsp;]</td></tr>"
	getBrowseNAICSInfo = strReturn
End Function

Sub printFullNAICSInfo(strNAICSCode, strClassification, strDescription, intUsageCount, bCount, strLinkPage)
	Dim strCodeList, _
		strRelatedCodeInfo
	'Print Info for this Code
%>
<h3><%=strNAICSCode%> - <%=strClassification%></h3>
<p><%=strDescription%></p>
<%
	'Print Broader Codes
		strRelatedCodeInfo = getBroaderCodes(strNAICSCode,bCount,strLinkPage)
		If Not Nl(strRelatedCodeInfo) Then
%>
<h4><%= TXT_BROADER_CLASSIFICATIONS %></h4>
<table class="BasicBorder cell-padding-2">
<tr>
<%=strRelatedCodeInfo%>
</tr>
</table>
<%
		End If
	'Print Narrower Codes
		strRelatedCodeInfo = getNarrowerCodes(strNAICSCode,bCount,strLinkPage)
		If Not Nl(strRelatedCodeInfo) Then
%>
<h4><%= TXT_NARROWER_CLASSIFICATIONS %> (<%=getCodeType(Len(strNAICSCode)+1)%>)</h4>
<table class="NoBorder cell-padding-2">
<%=strRelatedCodeInfo%>
</table>
<%
		End If
	'Print Examples
		strRelatedCodeInfo = getExamples(strNAICSCode)
		If Not Nl(strRelatedCodeInfo) Then
%>
<h4><%= TXT_EXAMPLES %></h4>
<%=strRelatedCodeInfo%>
<%
		End If
	'Print Exclusions
		strRelatedCodeInfo = getExclusions(strNAICSCode,strLinkPage)
		If Not Nl(strRelatedCodeInfo) Then
%>
<h4><%= TXT_EXCLUSIONS %></h4>
<%=strRelatedCodeInfo%>
<%
		End If
End Sub

%>
