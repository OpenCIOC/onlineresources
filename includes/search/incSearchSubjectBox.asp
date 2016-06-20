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
Dim bCanShowSubjectBox, _
	bHideSubjectBox

bCanShowSubjectBox = g_bUseCIC And g_bUseThesaurusView _
	And ((strSTypeOrg = "A" Or strSTypeOrg = "S") And Not (Nl(strSTermsOrg) And (UBound(exactSTerms) <= 0)) _
		Or Not Nl(strSubjID))

bHideSubjectBox = Request("HideSubj") = "on" _
	Or Not bCanShowSubjectBox

Sub printSubjectBox()
%>
<div class="SideBarBox">
<h2 class="RevBoxHeader"><%=TXT_SUBJECTS%></h2>
<div>
<%
		Call makeSubjectBox(False, Join(singleSTerms,OR_CON), Join(quotedSTerms,OR_CON), IIf(intSConOrg = JTYPE_BOOLEAN,strSTermsOrg,Join(exactSTerms," ")),strSubjID,True,False,"bresults.asp")
%>
</div>
<%		If user_bLoggedIn And Not g_bPrintMode Then%>
<hr>
<div style="text-align:center"><a class="ButtonLink" id="hide_subjects" href="<%=ps_strThisPage & "?" & IIf(Nl(strQueryString),vbNullString,strQueryString & "&")%>HideSubj=on"><%=TXT_HIDE_SUBJECTS%></a></div>
<%		End If%>
</div>
<%
End Sub
%>
