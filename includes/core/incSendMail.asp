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
from cioc.core.email import send_email,DeliveryException
def l_send_email(author, to, subject, message, ignore_block, domain_override=None):
	args = {}
	if domain_override:
		args['domain_override'] = domain_override

	try:
		send_email(pyrequest, author, to, subject, message, ignore_block, **args)
	except Exception:
		return False

	return True
</script>

<%
Function sendEmail(bIgnoreBlock,strFrom,strTo,strSubject,strMessage)
	sendEmail = l_send_email(CStr(strFrom), CStr(strTo), CStr(strSubject), CStr(strMessage), bIgnoreBlock)
End Function

Function sendEmail2(bIgnoreBlock,strFrom,strTo,strSubject,strMessage, intDomain)
	sendEmail2 = l_send_email(CStr(strFrom), CStr(strTo), CStr(strSubject), CStr(strMessage), bIgnoreBlock, intDomain)
End Function
%>
