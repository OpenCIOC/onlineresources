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
'
' Purpose:		List agencies to edit, add new agency
'
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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../includes/core/incSendMail.asp" -->

<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

If Nl(Request("NumEmail")) Then
'Call sendEmail(bIgnoreBlock,strFrom,strTo,strReplyTo,strSubject,strMessage)
If sendEmail(True,"chris@cioc.ca","chris@kclsoftware.com",vbNullString,"CIOC Email test","This is a test email message") Then
Response.Write("Success")
Else
Response.Write("Failure")
End If
Else
	Dim intNumEmail, i, strTargetEmail
	intNumEmail = CInt(Request("NumEmail"))
	strTargetEmail = Request("TargetEmail")

	For i = 1 to intNumEmail
	 Call sendEmail(True, "chris@cioc.ca", strTargetEmail, vbNullString, "CIOC Email test #" & i, _
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit. In sodales imperdiet" & vbCrLf & _
		"erat et hendrerit. Fusce cursus sit amet ante vitae vehicula. Maecenas vel" & vbCrLf & _
		"accumsan sem. Sed posuere augue eu scelerisque vehicula. Phasellus in laoreet" & vbCrLf & _
		"sem. Nunc nec dolor eget magna consequat convallis. Fusce sollicitudin, odio" & vbCrLf & _
		"eget finibus maximus, turpis turpis maximus urna, id facilisis risus tortor at" & vbCrLf & _
		"leo. Proin sem libero, cursus non ullamcorper et, tincidunt et neque. Mauris" & vbCrLf & _
		"risus sem, vehicula a egestas ultrices, sagittis ultricies mauris. Pellentesque" & vbCrLf & _
		"eget nunc scelerisque, varius massa eu, fermentum magna. Aliquam congue est" & vbCrLf & _
		"lacinia odio vulputate aliquam. Donec augue erat, semper sed fermentum eget," & vbCrLf & _
		"auctor at massa." & vbCrLf & _
		"" & vbCrLf & _
		"Quisque sed magna dui. Donec et erat tortor. Duis nec eros suscipit, porttitor" & vbCrLf & _
		"tellus et, interdum odio. Duis metus nunc, iaculis et dignissim at, interdum eu" & vbCrLf & _
		"dui. In turpis neque, dapibus at maximus non, lacinia eu mauris. Ut ac" & vbCrLf & _
		"consectetur nulla, sit amet convallis tortor. Fusce iaculis tincidunt lectus et" & vbCrLf & _
		"ornare. Sed accumsan, ante sit amet ullamcorper facilisis, dolor arcu rhoncus" & vbCrLf & _
		"lacus, quis fringilla velit lacus eget ipsum." & vbCrLf & _
		"" & vbCrLf & _
		"Maecenas venenatis fringilla elementum. Mauris lacus lectus, euismod vitae" & vbCrLf & _
		"pellentesque a, porttitor nec lectus. Cras eleifend libero id est aliquam" & vbCrLf & _
		"ultricies. Sed convallis consequat ante vitae aliquet. Integer rhoncus" & vbCrLf & _
		"rhoncus condimentum. Nullam molestie dictum urna, eget porttitor leo" & vbCrLf & _
		"commodo a. Ut ut purus ante. Suspendisse congue dui at mattis luctus." & vbCrLf & _
		"Nullam cursus sapien et aliquet elementum. Praesent facilisis felis" & vbCrLf & _
		"facilisis, tempus magna non, dignissim massa. Vestibulum eu lorem finibus," & vbCrLf & _
		"dapibus justo sit amet, tincidunt est. Curabitur pharetra nisi sit amet" & vbCrLf & _
		"arcu faucibus placerat. In venenatis egestas justo, pretium sodales lorem" & vbCrLf & _
		"aliquet eu. Suspendisse euismod cursus elit vitae ornare." & vbCrLf & _
		"" & vbCrLf & _
		"Proin sit amet urna at sem scelerisque tristique. Quisque a nisi at nulla" & vbCrLf & _
		"varius condimentum quis vitae dui. In velit neque, elementum in imperdiet at," & vbCrLf & _
		"posuere ut nibh. Etiam nec suscipit lectus, a consequat urna. Phasellus" & vbCrLf & _
		"id imperdiet urna. Nulla tristique dignissim metus, quis mollis dui" & vbCrLf & _
		"tristique quis. Pellentesque nec velit quam." & vbCrLf & _
		"" & vbCrLf & _
		"Morbi maximus massa in odio commodo fringilla sagittis sit amet neque. Fusce" & vbCrLf & _
		"lobortis scelerisque massa, quis malesuada sapien cursus vitae. Donec viverra" & vbCrLf & _
		"velit a nisl sodales, eu lacinia nunc tincidunt. Sed ac purus sed mauris" & vbCrLf & _
		"dapibus venenatis. Fusce gravida orci mi, nec suscipit tellus vehicula nec." & vbCrLf & _
		"Pellentesque vitae varius eros, ut facilisis arcu. Donec sed urna ac justo" & vbCrLf & _
		"tempus pellentesque. Fusce hendrerit efficitur ligula non cursus. Nullam non" & vbCrLf & _
		"maximus urna. Class aptent taciti sociosqu ad litora torquent per conubia" & vbCrLf & _
		"nostra, per inceptos himenaeos." & vbCrLf _
	)
	Call Response.Write(".")
	Call Response.Flush()

	Next

End If

%>
<!--#include file="../includes/core/incClose.asp" -->
