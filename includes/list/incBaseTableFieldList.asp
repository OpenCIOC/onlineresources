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
Sub printBaseTableTextFieldList(strSelectName, bDate, bRadio, bWWW, bMultiple, bIncludeBlank)
%>
<select name=<%=AttrQs(strSelectName) & IIf(bMultiple," MULTIPLE size=""15""",vbNullString)%>>
<%If bIncludeBlank And Not bMultiple Then%>
<option value=""> -- </option>
<%End If%>
<option value="btd.ACCESSIBILITY_NOTES">ACCESSIBILITY_NOTES</option>
<option value="cbtd.ACTIVITY_NOTES">ACTIVITY_NOTES</option>
<option value="cbtd.AFTER_HRS_PHONE">AFTER_HRS_PHONE</option>
<option value="cbtd.APPLICATION">APPLICATION</option>
<option value="cbtd.AREAS_SERVED_NOTES">AREAS_SERVED_NOTES</option>
<option value="ccbtd.BEST_TIME_TO_CALL">BEST_TIME_TO_CALL</option>
<option value="cbtd.BOUNDARIES">BOUNDARIES</option>
<option value="cbtd.COMMENTS">COMMENTS</option>
<option value="cbt.CORP_REG_NO">CORP_REG_NO</option>
<option value="cbtd.CRISIS_PHONE">CRISIS_PHONE</option>
<option value="cbtd.DATES">DATES</option>
<option value="cbt.DD_CODE">DD_CODE</option>
<option value="btd.DESCRIPTION">DESCRIPTION</option>
<option value="btd.E_MAIL">E_MAIL</option>
<option value="cbtd.ELECTIONS">ELECTIONS</option>
<option value="cbtd.ELIGIBILITY_NOTES">ELIGIBILITY_NOTES</option>
<option value="cbt.EMPLOYEES_FT">EMPLOYEES_FT</option>
<option value="cbt.EMPLOYEES_PT">EMPLOYEES_PT</option>
<option value="cbt.EMPLOYEES_TOTAL">EMPLOYEES_TOTAL</option>
<option value="btd.ESTABLISHED">ESTABLISHED</option>
<option value="bt.EXTERNAL_ID">EXTERNAL_ID</option>
<%
Dim cmdExtraFieldList, rsExtraFieldList
Set cmdExtraFieldList = Server.CreateObject("ADODB.Command")
With cmdExtraFieldList
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_View_UpdateFields_l_Extra"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	.Parameters.Append .CreateParameter("InclDate", adBoolean, adParamInput, 1, IIf(bDate,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("InclRadio", adBoolean, adParamInput, 1, IIf(bRadio,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("InclWWW", adBoolean, adParamInput, 1, IIf(bWWW,SQL_TRUE,SQL_FALSE))
End With
Set rsExtraFieldList = Server.CreateObject("ADODB.Recordset")
With rsExtraFieldList
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdExtraFieldList
End With

With rsExtraFieldList
	While Not .EOF
%>
<option value="x<%=.Fields("ExtraFieldType")%>.<%=.Fields("FieldName")%>"><%=.Fields("FieldName")%></option>
<%
		.MoveNext
	Wend 
	.Close
End With

Set rsExtraFieldList = Nothing
Set cmdExtraFieldList = Nothing
%>
<option value="btd.FAX">FAX</option>
<%If bRadio Then%>
<option value="cbt.FEE_ASSISTANCE_AVAILABLE">FEE_ASSISTANCE_AVAILABLE</option>
<%End If%>
<option value="cbtd.FEE_ASSISTANCE_FOR">FEE_ASSISTANCE_FOR</option>
<option value="cbtd.FEE_ASSISTANCE_FROM">FEE_ASSISTANCE_FROM</option>
<option value="cbtd.FEE_NOTES">FEE_NOTES</option>
<option value="cbtd.FUNDING_NOTES">FUNDING_NOTES</option>
<option value="btd.GEOCODE_NOTES">GEOCODE_NOTES</option>
<option value="cbtd.HOURS">HOURS</option>
<option value="cbtd.INTERSECTION">INTERSECTION</option>
<option value="cbtd.LANGUAGE_NOTES">LANGUAGE_NOTES</option>
<option value="ccbt.LC_INFANT">LC_INFANT</option>
<option value="ccbt.LC_KINDERGARTEN">LC_KINDERGARTEN</option>
<option value="ccbtd.LC_NOTES">LC_NOTES</option>
<option value="ccbt.LC_PRESCHOOL">LC_PRESCHOOL</option>
<option value="ccbt.LC_SCHOOLAGE">LC_SCHOOLAGE</option>
<option value="ccbt.LC_TODDLER">LC_TODDLER</option>
<option value="ccbt.LC_TOTAL">LC_TOTAL</option>
<option value="btd.LEGAL_ORG">LEGAL_ORG</option>
<option value="ccbt.LICENSE_NUMBER">LICENSE_NUMBER</option>
<option value="btd.LOCATION_DESCRIPTION">LOCATION_DESCRIPTION</option>
<option value="btd.LOCATION_NAME">LOCATION_NAME</option>
<option value="cbtd.LOGO_ADDRESS">LOGO_ADDRESS</option>
<option value="cbtd.LOGO_ADDRESS_LINK">LOGO_ADDRESS_LINK</option>
<option value="btd.MAIL_BOX_TYPE">MAIL_BOX_TYPE</option>
<option value="btd.MAIL_BUILDING">MAIL_BUILDING</option>
<option value="btd.MAIL_CARE_OF">MAIL_CARE_OF</option>
<option value="btd.MAIL_CITY">MAIL_CITY</option>
<option value="btd.MAIL_COUNTRY">MAIL_COUNTRY</option>
<option value="btd.MAIL_PO_BOX">MAIL_PO_BOX</option>
<option value="bt.MAIL_POSTAL_CODE">MAIL_POSTAL_CODE</option>
<option value="btd.MAIL_PROVINCE">MAIL_PROVINCE</option>
<option value="btd.MAIL_STREET">MAIL_STREET</option>
<option value="btd.MAIL_STREET_DIR">MAIL_STREET_DIR</option>
<option value="btd.MAIL_STREET_NUMBER">MAIL_STREET_NUMBER</option>
<option value="btd.MAIL_STREET_TYPE">MAIL_STREET_TYPE</option>
<option value="btd.MAIL_SUFFIX">MAIL_SUFFIX</option>
<option value="cbt.MAX_AGE">MAX_AGE</option>
<option value="cbtd.MEETINGS">MEETINGS</option>
<option value="cbtd.MEMBERSHIP_NOTES">MEMBERSHIP_NOTES</option>
<option value="cbt.MIN_AGE">MIN_AGE</option>
<%If bRadio Then%>
<option value="bt.NO_UPDATE_EMAIL">NO_UPDATE_EMAIL</option>
<%End If%>
<option value="cbt.OCG_NO">OCG_NO</option>
<option value="btd.OFFICE_PHONE">OFFICE_PHONE</option>
<option value="btd.ORG_DESCRIPTION">ORG_DESCRIPTION</option>
<option value="btd.ORG_LEVEL_1">ORG_LEVEL_1</option>
<option value="btd.ORG_LEVEL_2">ORG_LEVEL_2</option>
<option value="btd.ORG_LEVEL_3">ORG_LEVEL_3</option>
<option value="btd.ORG_LEVEL_4">ORG_LEVEL_4</option>
<option value="btd.ORG_LEVEL_5">ORG_LEVEL_5</option>
<option value="cbtd.PRINT_MATERIAL">PRINT_MATERIAL</option>
<option value="cbtd.PUBLIC_COMMENTS">PUBLIC_COMMENTS</option>
<option value="cbtd.RESOURCES">RESOURCES</option>
<option value="ccbtd.SCHOOL_ESCORT_NOTES">SCHOOL_ESCORT_NOTES</option>
<option value="ccbtd.SCHOOLS_IN_AREA_NOTES">SCHOOLS_IN_AREA_NOTES</option>
<option value="btd.SERVICE_NAME_LEVEL_1">SERVICE_NAME_LEVEL_1</option>
<option value="btd.SERVICE_NAME_LEVEL_2">SERVICE_NAME_LEVEL_2</option>
<option value="btd.SITE_BUILDING">SITE_BUILDING</option>
<option value="btd.SITE_CITY">SITE_CITY</option>
<option value="btd.SITE_COUNTRY">SITE_COUNTRY</option>
<option value="cbtd.SITE_LOCATION">SITE_LOCATION</option>
<option value="bt.SITE_POSTAL_CODE">SITE_POSTAL_CODE</option>
<option value="btd.SITE_PROVINCE">SITE_PROVINCE</option>
<option value="btd.SITE_STREET">SITE_STREET</option>
<option value="btd.SITE_STREET_DIR">SITE_STREET_DIR</option>
<option value="btd.SITE_STREET_NUMBER">SITE_STREET_NUMBER</option>
<option value="btd.SITE_STREET_TYPE">SITE_STREET_TYPE</option>
<option value="btd.SITE_SUFFIX">SITE_SUFFIX</option>
<option value="btd.SORT_AS">SORT_AS</option>
<option value="btd.SOURCE_ADDRESS">SOURCE_ADDRESS</option>
<option value="btd.SOURCE_BUILDING">SOURCE_BUILDING</option>
<option value="btd.SOURCE_CITY">SOURCE_CITY</option>
<option value="btd.SOURCE_DB">SOURCE_DB</option>
<option value="btd.SOURCE_EMAIL">SOURCE_EMAIL</option>
<option value="btd.SOURCE_FAX">SOURCE_FAX</option>
<option value="btd.SOURCE_NAME">SOURCE_NAME</option>
<option value="btd.SOURCE_ORG">SOURCE_ORG</option>
<option value="btd.SOURCE_PHONE">SOURCE_PHONE</option>
<option value="btd.SOURCE_POSTAL_CODE">SOURCE_POSTAL_CODE</option>
<option value="btd.SOURCE_PROVINCE">SOURCE_PROVINCE</option>
<option value="btd.SOURCE_TITLE">SOURCE_TITLE</option>
<%If bRadio Then%>
<option value="ccbt.SPACE_AVAILABLE">SPACE_AVAILABLE</option>
<%End If%>
<option value="ccbtd.SPACE_AVAILABLE_NOTES">SPACE_AVAILABLE_NOTES</option>
<option value="btd.SUBMIT_CHANGES_TO">SUBMIT_CHANGES_TO</option>
<option value="cbtd.SUP_DESCRIPTION">SUP_DESCRIPTION</option>
<option value="cbt.TAX_REG_NO">TAX_REG_NO</option>
<option value="cbtd.TDD_PHONE">TDD_PHONE</option>
<option value="btd.TOLL_FREE_PHONE">TOLL_FREE_PHONE</option>
<option value="cbtd.TRANSPORTATION">TRANSPORTATION</option>
<option value="ccbtd.TYPE_OF_CARE_NOTES">TYPE_OF_CARE_NOTES</option>
<option value="bt.UPDATE_EMAIL">UPDATE_EMAIL</option>
<option value="cbtd.VACANCY_NOTES">VACANCY_NOTES</option>
<option value="cbt.WCB_NO">WCB_NO</option>
<%If bWWW Then%>
<option value="btd.WWW_ADDRESS">WWW_ADDRESS</option>
<%End If%>
</select>
<%
End Sub
%>

