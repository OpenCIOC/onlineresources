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
import cioc.core.volprofileuser as volprofileuser

vprofile_bLoggedIn = False
vprofile_strID = None
vprofile_strEmail = ''

def vprofile_check_login():
	global vprofile_bLoggedIn, vprofile_strID, vprofile_strEmail

	user = volprofileuser.VolProfileUser(pyrequest)

	vprofile_bLoggedIn = user.LoggedIn
	vprofile_strID = user.ProfileID
	vprofile_strEmail = user.Email

def setVProfileSession(strLoginName, strLoginKey):
	volprofileuser.do_login(pyrequest, strLoginName, strLoginKey)

def clearVProfileSession():
	volprofileuser.do_logout(pyrequest)

def update_user_id_l(strEmail):
	volprofileuser.remember(pyrequest, strEmail)

</script>
<%

Sub updateVProfileLoginCookie(strEmail)
	Dim tmp
	tmp = update_user_id_l(strEmail)
End Sub

Call vprofile_check_login()
%>
