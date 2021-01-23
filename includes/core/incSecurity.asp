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
' Purpose: 		Manage values for global variables to do with the current User and their security settings (User Type).
'				Set default values for security settings, which be used for public users and users with no module permissions.
'				Once User information is retrieved and we know the current User's default View (if any), call the procedure to set View data.
'				Compare the users credentials to the minimum credentials required for the current page
'				Contains a security failure procedure to redirect the user if they are attempting to view unauthorized information.
'
%>

<script language="python" runat="server">
from datetime import datetime, timedelta
from cioc.core.security import User, HashComponents, is_banned, get_remote_ip, is_basic_security_failure, do_login as py_do_login, do_logout as py_do_logout
from cioc.core.connection import ConnectionError

#***************************************
# Begin Function getRemoteIP
#	Get the remote IP of the request
#***************************************
def getRemoteIP():
	return get_remote_ip(pyrequest)

#***************************************
# End Sub getRemoteIP
#***************************************

def MD5Hash(strValue):
	return HashComponents(six.text_type(strValue))

def do_logout():
	py_do_logout(pyrequest)

def do_login(principal, unhashed_key):
	py_do_login(pyrequest, principal, MD5Hash(unhashed_key))

#***************************************
# Begin Sub getLogin
#	Check if the current user is logged into the database.
#	If the user is logged in with a valid active account, retrieve User Type settings.
#	If the user is not logged in or does not have a valid active account, set
#	default values for User Type settings.	If the user is not logged in,
#	confirm that the current user's IP Address has not been banned from the system.
#***************************************

def getLogin(banned_user_callback, handleDBConnectionError):
	global user_bLoggedIn, user_intID, user_strLogin, \
		user_strUserFirstName, user_strUserLastName, user_strInitials, \
		user_strAgency, user_strEmail, \
		user_intSavedSearchQuota, user_strMod, \
		user_bCIC, user_bVOL, user_bDOM, \
		user_intUserTypeCIC, user_intUserTypeVOL, user_intUserTypeDOM, \
		user_intViewCIC, user_intViewVOL, user_intViewDOM, \
		user_bAddCIC, user_bAddVOL, user_bAddDOM, \
		user_bCanAddSQLCIC, user_bCanAddSQLVOL, user_bCanAddSQLDOM, \
		user_bCanAssignFeedbackCIC, user_bCanAssignFeedbackVOL, \
		user_bCanDoBulkOpsCIC, user_bCanDoBulkOpsVOL, user_bCanDoBulkOpsDOM, \
		user_bCanDeleteRecordCIC, user_bCanDeleteRecordVOL, user_bCanDeleteRecordDOM, \
		user_bCanManageUsersCIC, user_bCanManageUsersVOL, user_bCanManageUsers, \
		user_bCanManageMembers, user_bCanManageReferrals, user_bCanAccessProfiles, \
		user_bCanRequestUpdateCIC, user_bCanRequestUpdateVOL, user_bCanRequestUpdateDOM, \
		user_intCanViewStatsCIC, user_intCanViewStatsVOL, user_intCanViewStatsDOM, \
		user_bCommentAlertCIC, user_bCommentAlertVOL, user_bCommentAlertDOM, \
		user_bCopyCIC, user_bCopyVOL, \
		user_bFeedbackAlertCIC, user_bFeedbackAlertVOL, user_bFeedbackAlertDOM, \
		user_bFullUpdateCIC, user_bFullUpdateVOL, user_bFullUpdateDOM, \
		user_bSuppressEmailCIC, user_bSuppressEmailVOL, user_bSuppressEmailDOM, \
		user_intPBID, user_bLimitedViewCIC, \
		user_intExportPermissionCIC, user_bImportPermissionCIC, \
		user_intUpdateCIC, user_intUpdateVOL, user_intUpdateDOM, \
		user_intCanUpdatePubs, user_intCanIndexTaxonomy, \
		user_bWebDevCIC, user_bWebDevVOL, user_bWebDev, \
		user_bSuperUserCIC, user_bSuperUserVOL, user_bSuperUser, user_bSuperUserDOM, \
		user_bSuperUserGlobalCIC, user_bSuperUserGlobalVOL, user_bSuperUserGlobal, user_bSuperUserGlobalDOM, \
		user_bTechAdmin


	try:
		user = pyrequest.user 
	except ConnectionError:
		handleDBConnectionError()

	user_bLoggedIn = bool(user)

	try:
		if not user:
			# check banned
			if is_banned(pyrequest) and not pyrequest.path.endswith('security_failure.asp'):
				banned_user_callback(get_remote_ip(pyrequest))
	except ConnectionError:
		handleDBConnectionError()


	user_intID = user.User_ID
	user_strLogin = user.Login
	user_strUserFirstName = user.FirstName
	user_strUserLastName = user.LastName
	user_strInitials = user.Initials
	user_strAgency = user.Agency
	user_strEmail = user.Email
	user_intSavedSearchQuota = user.SavedSearchQuota
	user_bWebDev = user.WebDeveloper
	user_bSuperUser = user.SuperUser
	user_bSuperUserGlobal = user.SuperUserGlobal
	user_bCanManageUsers = user.CanManageUsers
	user_strMod = user.Mod
	user_bTechAdmin = user.TechAdmin
		
		
	# CIC User Type data

	user_bCIC = bool(user.cic)

	user_intUserTypeCIC = user.cic.SL_ID
	user_bSuperUserCIC = user.cic.SuperUser
	user_bSuperUserGlobalCIC = user.cic.SuperUserGlobal
	user_bAddCIC = user.cic.CanAddRecord
	user_bCopyCIC = user.cic.CanCopyRecord
	user_intUpdateCIC = user.cic.CanEditRecord
	user_bFullUpdateCIC = user.cic.CanDoFullUpdate
	user_bCanDoBulkOpsCIC = user.cic.CanDoBulkOps
	user_bCanRequestUpdateCIC = user.cic.CanRequestUpdate
	user_bCanDeleteRecordCIC = user.cic.CanDeleteRecord
	user_intCanUpdatePubs = user.cic.CanUpdatePubs
	user_intCanIndexTaxonomy = user.cic.CanIndexTaxonomy
	user_bCanAssignFeedbackCIC = user.cic.CanAssignFeedback
	user_bCanAddSQLCIC = user.cic.CanAddSQL
	user_intCanViewStatsCIC = user.cic.CanViewStats
	user_bCanManageUsersCIC = user.cic.CanManageUsers
	user_intExportPermissionCIC = user.cic.ExportPermission
	user_bImportPermissionCIC = user.cic.ImportPermission
	user_bSuppressEmailCIC = user.cic.SuppressNotifyEmail
	user_bFeedbackAlertCIC = user.cic.FeedbackAlert
	user_bCommentAlertCIC = user.cic.CommentAlert
	user_intViewCIC = user.cic.ViewType
	user_intPBID = user.cic.PB_ID
	user_bLimitedViewCIC = user.cic.LimitedView

		
	# VOL User Type data

	user_bVOL = bool(user.vol)

	user_intUserTypeVOL = user.vol.SL_ID
	user_bSuperUserVOL = user.vol.SuperUser
	user_bSuperUserGlobalVOL = user.vol.SuperUserGlobal
	user_bAddVOL = user.vol.CanAddRecord
	user_bCopyVOL = user.vol.CanCopyRecord
	user_intUpdateVOL = user.vol.CanEditRecord
	user_bFullUpdateVOL = user.vol.CanDoFullUpdate
	user_bCanDoBulkOpsVOL = user.vol.CanDoBulkOps
	user_bCanRequestUpdateVOL = user.vol.CanRequestUpdate
	user_bCanDeleteRecordVOL = user.vol.CanDeleteRecord
	user_bCanAssignFeedbackVOL = user.vol.CanAssignFeedback
	user_bCanAddSQLVOL = user.vol.CanAddSQL
	user_bCanManageMembers = user.vol.CanManageMembers
	user_bCanManageReferrals = user.vol.CanManageReferrals
	user_bCanAccessProfiles = user.vol.CanAccessProfiles
	user_intCanViewStatsVOL = user.vol.CanViewStats
	user_bCanManageUsersVOL = user.vol.CanManageUsers
	user_bSuppressEmailVOL = user.vol.SuppressNotifyEmail
	user_bFeedbackAlertVOL = user.vol.FeedbackAlert
	user_bCommentAlertVOL = user.vol.CommentAlert
	user_intViewVOL = user.vol.ViewType


	if pyrequest.pageinfo.DbArea != DM_GLOBAL:
		user_bDOM = bool(user.dom)
		user_intUserTypeDOM = user.dom.UserType
		user_bAddDOM = user.dom.CanAddRecord
		user_intUpdateDOM = user.dom.CanEditRecord
		user_bFullUpdateDOM = user.dom.CanDoFullUpdate
		user_bCanDoBulkOpsDOM = user.dom.CanDoBulkOps
		user_bCanRequestUpdateDOM = user.dom.CanDoBulkOps
		user_bCanDeleteRecordDOM = user.dom.CanDeleteRecord 
		user_bCanAddSQLDOM = user.dom.CanAddSQL
		user_intCanViewStatsDOM = user.dom.CanViewStats
		user_bSuppressEmailDOM = user.dom.SuppressNotifyEmail
		user_bFeedbackAlertDOM = user.dom.FeedbackAlert
		user_bCommentAlertDOM = user.dom.CommentAlert
		user_bSuperUserGlobalDOM = user.dom.SuperUserGlobal
		user_bSuperUserDOM = user.dom.SuperUser
		user_intViewDOM = user.dom.ViewType



#***************************************
# End Sub getLogin
#***************************************
#***************************************
# Begin Sub checkSecurity
#	Compare the user's credentials against the minimum requirements of the current page.
#	If the user does not have permission to access the current page, 
#	call a security failure or send them to the login page if they are not logged in.
#***************************************
def checkSecurity(ps_bLogin, securityFailure, handleDBConnetionError):
	try:
		if is_basic_security_failure(pyrequest, ps_bLogin):
			securityFailure()
	except ConnectionError:
		handleDBConnetionError()
#***************************************
# End Sub checkSecurity
#***************************************

def has_api_permission(dom, permission):
	if dom == DM_CIC:
		return permission in pyrequest.user.cic.ExternalAPIs
	
	return permission in pyrequest.user.vol.ExternalAPIs
</script>
<%

'***************************************
' Begin Sub securityFailure
'***************************************
Sub securityFailure()
	Call goToPageB(ps_strRootPath & "security_failure.asp")
End Sub
'***************************************
' End Sub securityFailure
'***************************************

Sub EnsureSSL()
	If Not Nl(Request.ServerVariables("HTTP_CIOC_SSL_POSSIBLE")) And Nl(Request.ServerVariables("HTTP_CIOC_USING_SSL")) Then
		Response.Redirect "https://" & Request.ServerVariables("HTTP_HOST") & Request.ServerVariables("URL") & StringIf(Not Nl(Request.ServerVariables("QUERY_STRING")), "?" & Request.ServerVariables("QUERY_STRING"))
	End If
End Sub

Sub BannedUserCallback(strRemoteIP)
	Call handleError(strRemoteIP & TXT_COLON & TXT_USER_BANNED, _
		ps_strPathToStart & "security_failure.asp", vbNullString)
End Sub

' Get login information
Call getLogin(GetRef("BannedUserCallback"), GetRef("handleDBConnetionError"))
' Get information for the current View
Call getViewData(GetRef("SetPrintMode"), GetRef("handleDBConnetionError"))
' Confirm that the current user has permission to view this page
Call checkSecurity(ps_bLogin, GetRef("securityFailure"), GetRef("handleDBConnetionError"))

'***************************************
' Begin Sub HTTPBasicUnauth
'	Send HTTP Basic unauthorized message
'	And end the request
'***************************************
Sub HTTPBasicUnauth(strRealm)
	Call Response.AddHeader("WWW-Authenticate", "Basic realm=""" & strRealm & """")
	Response.Status = "401 Unauthorized"
	%><!--#include file="../../includes/core/incClose.asp" --><%
	Call Response.Clear()
	Call Response.End()
End Sub
'***************************************
' End Sub HTTPBasicUnauth
'***************************************

%>
