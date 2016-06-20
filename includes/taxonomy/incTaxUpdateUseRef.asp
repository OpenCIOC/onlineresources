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
' Purpose:		Update or add an Unused Term (Use Reference)
'
'
%>

<%

' Create the template for a command to update an Unused Term (Use Reference)
Dim cmdUpdateUnusedTerm, rsUpdateUnusedTerm
Set cmdUpdateUnusedTerm = Server.CreateObject("ADODB.Command")
With cmdUpdateUnusedTerm 
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_TAX_Unused_u"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append .CreateParameter("@UT_ID", adInteger, adParamInput, 4)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21)
	.Parameters.Append .CreateParameter("@Term", adVarWChar, adParamInput, 255)
	.Parameters.Append .CreateParameter("@Authorized", adBoolean, adParamInput, 1)
	.Parameters.Append .CreateParameter("@Active", adBoolean, adParamInput, 1)
	.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 4)
	.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
End With

'***************************************
' Begin Function updateUnusedTerm
'	Update the parameters for the above Command Template, and execute
'	to add, update or delete the Unused Term.
'		intUTID - Unused Term ID, if an existing Use Reference
'		strTerm - English Name of the Unused Term
'		strTermEq - French Name of the Unused Term
'		bAuthorized - If this is an Authorized Use Reference
'		bActive - If this Use Reference is in use (Active)
'	Assumes that the variable strCode exists in another file and has been set
'	to the value of the preferred Term which references this Unused Term.
'***************************************
Function updateUnusedTerm(intUTID,strTerm,bAuthorized,bActive, intLangID)
	With cmdUpdateUnusedTerm
		.Parameters("@UT_ID") = Nz(intUTID,Null)
		.Parameters("@Code") = strCode
		.Parameters("@Term") = strTerm
		.Parameters("@Authorized") = IIf(bAuthorized,SQL_TRUE,SQL_FALSE)
		.Parameters("@Active") = IIf(bActive,SQL_TRUE,SQL_FALSE)
		.Parameters("@LangID") = intLangID
		Set rsUpdateUnusedTerm = .Execute
	End With
	Set rsUpdateUnusedTerm = rsUpdateUnusedTerm.NextRecordset
	
	If cmdUpdateUnusedTerm.Parameters("@RETURN_VALUE").Value <> 0 Then
		updateUnusedTerm = "<li>" & cmdUpdateUnusedTerm.Parameters("@ErrMsg").Value & "</li>"
	End If
End Function

'***************************************
' End Function updateUnusedTerm
'***************************************
%>
