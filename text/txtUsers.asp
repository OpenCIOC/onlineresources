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
Dim TXT_ACCOUNT_UPDATED, _
	TXT_ACCOUNT_UPDATES, _
	TXT_ACCOUNT_IS_LOCKED, _
	TXT_ACCOUNT_NOT_UPDATED, _
	TXT_ACCOUNT_WILL_BE_LOCKED, _
	TXT_AGENCY, _
	TXT_ANY_OF_THE_FOLLOWING, _
	TXT_ANY_VIEW_THE_USER_CAN_ACCESS, _
	TXT_API_KEYS, _
	TXT_BASED_ON_EXISTING_VIEW_1, _
	TXT_BASED_ON_EXISTING_VIEW_2, _
	TXT_BASED_ON_EXISTING_VIEW_3, _
	TXT_BLOCKED_USER, _
	TXT_CAN_ACCESS_PROFILES, _
	TXT_CAN_ADD_RECORD, _
	TXT_CAN_ADD_SQL, _
	TXT_CAN_ASSIGN_FEEDBACK, _
	TXT_CAN_COPY_RECORD, _
	TXT_CAN_DELETE, _
	TXT_CAN_DO_BULK, _
	TXT_CAN_INDEX_TAXONOMY, _
	TXT_CAN_MANAGE_MEMBERS, _
	TXT_CAN_MANAGE_REFERRALS, _
	TXT_CAN_MANAGE_USERS, _
	TXT_CAN_REQUEST_UPDATE, _
	TXT_CAN_UPDATE_PUBS, _
	TXT_CAN_UPDATE_RECORD, _
	TXT_CAN_UPDATE_VACANCY, _
	TXT_CAN_VIEW_STATS, _
	TXT_CANT_EDIT_OWN_ACCOUNT_1, _
	TXT_CANT_EDIT_OWN_ACCOUNT_2, _
	TXT_CANT_EDIT_SUPERUSER, _
	TXT_CANT_EDIT_SUPERUSERGLOBAL, _
	TXT_CANT_LOGIN_NON_SECURE_DOMAIN, _
	TXT_CHANGE_PASSWORD, _
	TXT_CHECK_COOKIES, _
	TXT_CHOOSE_USER, _
	TXT_CHOOSE_USER_TYPE, _
	TXT_COMMENT_ALERT, _
	TXT_CONFIRM_PASSWORD, _
	TXT_CREATE_ACCOUNT, _
	TXT_CREATE_EDIT_USER_TYPE, _
	TXT_CREATE_USER, _
	TXT_CREATE_USER_TYPE, _
	TXT_DATABASE_DEFAULT, _
	TXT_DATABASE_LOGIN, _
	TXT_DEFAULT_VIEW, _
	TXT_EDIT_ACCOUNT, _
	TXT_EDIT_LOGIN_INFO, _
	TXT_EDIT_USER_TYPE, _
	TXT_EDITORIAL_VIEW, _
	TXT_EXPORT_PERMISSIONS, _
	TXT_EXTERNAL_APIS, _
	TXT_FIRST_NAME, _
	TXT_USER_INACTIVE_DATE, _
	TXT_INACTIVE_USER, _
	TXT_INDICATES_INACTIVE_USER, _
	TXT_INDICATES_LOCKED_ACCOUNT, _
	TXT_INITIALS, _
	TXT_INST_ACCESS_PROFILES_1, _
	TXT_INST_ACCESS_PROFILES_2, _
	TXT_INST_ACCESS_PROFILES_3, _
	TXT_INST_ACCOUNT_UPDATES_1, _
	TXT_INST_ACCOUNT_UPDATES_2, _
	TXT_INST_ADD_RECORD_1, _
	TXT_INST_ADD_RECORD_2, _
	TXT_INST_ADD_SQL_1, _
	TXT_INST_ADD_SQL_2, _
	TXT_INST_ASSIGN_FEEDBACK_1, _
	TXT_INST_ASSIGN_FEEDBACK_2, _
	TXT_INST_COMMENT, _
	TXT_INST_COPY_RECORD_1, _
	TXT_INST_COPY_RECORD_2, _
	TXT_INST_DELETE_1, _
	TXT_INST_DELETE_2, _
	TXT_INST_DO_BULK_1, _
	TXT_INST_DO_BULK_2, _
	TXT_INST_EXPORT_1, _
	TXT_INST_EXPORT_2, _
	TXT_INST_EXPORT_3, _
	TXT_INST_EXPORT_4, _
	TXT_INST_EXPORT_5, _
	TXT_INST_EXTERNAL_API, _
	TXT_INST_FEEDBACK_1, _
	TXT_INST_FEEDBACK_2, _
	TXT_INST_FULL_UPDATE_1, _
	TXT_INST_FULL_UPDATE_2, _
	TXT_INST_FULL_UPDATE_3, _
	TXT_INST_INDEX_TAXONOMY_1, _
	TXT_INST_INDEX_TAXONOMY_2, _
	TXT_INST_INDEX_TAXONOMY_3, _
	TXT_INST_INDEX_TAXONOMY_4, _
	TXT_INST_IMPORT_1, _
	TXT_INST_IMPORT_2, _
	TXT_INST_LOGIN_1, _
	TXT_INST_LOGIN_2, _
	TXT_INST_MANAGE_MEMBERS_1, _
	TXT_INST_MANAGE_MEMBERS_2, _
	TXT_INST_MANAGE_REFERRALS_1, _
	TXT_INST_MANAGE_REFERRALS_2, _
	TXT_INST_MANAGE_USERS_1, _
	TXT_INST_MANAGE_USERS_2, _
	TXT_INST_PASSWORD_1, _
	TXT_INST_PASSWORD_2, _
	TXT_INST_PASSWORD_3, _
	TXT_INST_REQUEST_UPDATE_1, _
	TXT_INST_REQUEST_UPDATE_2, _
	TXT_INST_SINGLE_LOGIN, _
	TXT_INST_SUPER_USER_1, _
	TXT_INST_SUPER_USER_2, _
	TXT_INST_SUPER_USER_3, _
	TXT_INST_SUPER_USER_GLOBAL_1, _
	TXT_INST_SUPER_USER_GLOBAL_2, _
	TXT_INST_SUPPRESS_EMAIL_1, _
	TXT_INST_SUPPRESS_EMAIL_2, _
	TXT_INST_SUPPRESS_EMAIL_3, _
	TXT_INST_UPDATE_PUBS_1, _
	TXT_INST_UPDATE_PUBS_2, _
	TXT_INST_UPDATE_PUBS_3, _
	TXT_INST_UPDATE_PUBS_4, _
	TXT_INST_UPDATE_PUBS_5, _
	TXT_INST_UPDATE_RECORD_1, _
	TXT_INST_UPDATE_RECORD_2, _
	TXT_INST_UPDATE_RECORD_3, _
	TXT_INST_UPDATE_RECORD_OPT_1, _
	TXT_INST_UPDATE_RECORD_OPT_2, _
	TXT_INST_UPDATE_RECORD_OPT_3, _
	TXT_INST_UPDATE_RECORD_OPT_4, _
	TXT_INST_UPDATE_VACANCY_1, _
	TXT_INST_UPDATE_VACANCY_2, _
	TXT_INST_UPDATE_VACANCY_OPT_1, _
	TXT_INST_UPDATE_VACANCY_OPT_2, _
	TXT_INST_UPDATE_VACANCY_OPT_3, _
	TXT_INST_UPDATE_VACANCY_OPT_4, _
	TXT_INST_USER_TYPE_NAME, _
	TXT_INST_VIEW_STATS_1, _
	TXT_INST_VIEW_STATS_2, _
	TXT_INST_VIEW_STATS_3, _
	TXT_INST_VIEW_STATS_4, _
	TXT_INST_VIEW_TYPE, _
	TXT_INST_VIEW_TYPE_EDITORIAL_1, _
	TXT_INST_VIEW_TYPE_EDITORIAL_2, _
	TXT_INST_VIEW_TYPE_OFFLINE, _
	TXT_INST_VIEW_TYPE_VACANCY_EDITORIAL_1, _
	TXT_INST_WEB_DEVELOPER_1, _
	TXT_INST_WEB_DEVELOPER_2, _
	TXT_INVALID_OLD_PASSWORD, _
	TXT_INVALID_USERNAME_PASSWORD, _
	TXT_IMPORT_PERMISSIONS, _
	TXT_LAST_ATTEMPT, _
	TXT_LAST_LOGIN, _
	TXT_LAST_NAME, _
	TXT_LOCKED_ACCOUNT, _
	TXT_LOGIN_FAILED, _
	TXT_LOGIN_TO_DATABASE, _
	TXT_MANAGE_USER_TYPES, _
	TXT_MAXIMUM_OF, _
	TXT_MY_ACCOUNT_ACCESS, _
	TXT_NEW_PASSWORD, _
	TXT_NEW_USER, _
	TXT_NO_CHANGES, _
	TXT_OLD_PASSWORD, _
	TXT_PASSWORD, _
	TXT_PASSWORD_DATE, _
	TXT_PASSWORD_NOT_SECURE, _
	TXT_PASSWORD_REQUIRED, _
	TXT_PASSWORDS_MUST_MATCH, _
	TXT_REPEATED_ATTEMPTS_BLOCKS_IP, _
	TXT_REQUEST_ACCOUNT_CHANGE, _
	TXT_REQUEST_ACCOUNT_CHANGE_FOR, _
	TXT_REQUEST_SENT, _
	TXT_RETURN_EDIT_USERS, _
	TXT_RETURN_USER_TYPES, _
	TXT_SAVED_SEARCHES, _
	TXT_SECURE_DOMAIN_LIST, _
	TXT_SEND_NEW_PASSWORD, _
	TXT_SEND_REQUEST, _
	TXT_SHOW_FIELDS, _
	TXT_SIGN_IN, _
	TXT_SINGLE_LOGIN, _
	TXT_START_PAGE, _
	TXT_STATUS_DELETE, _
	TXT_STATUS_NO_DELETE, _
	TXT_STATUS_NO_USE, _
	TXT_STATUS_USE, _
	TXT_SUPER_USER, _
	TXT_SUPER_USER_GLOBAL, _
	TXT_SUPPRESS_EMAIL, _
	TXT_THIS_USERS_ACCOUNT_INFO, _
	TXT_TRIES, _
	TXT_UNABLE_TO_SEND_REQUEST, _
	TXT_UNLOCK_THIS_ACCOUNT, _
	TXT_UPDATE_ACCOUNT_FAILED, _
	TXT_UPDATE_USER_TYPE_FAILED, _
	TXT_USER_CHANGE_HISTORY, _
	TXT_USER_IS_INACTIVE, _
	TXT_USER_IS_TECH_ADMIN, _
	TXT_USER_MAX_SEARCHES, _
	TXT_USER_NAME, _
	TXT_USER_NAME_REQUIRED, _
	TXT_USER_REQUEST_1, _
	TXT_USER_REQUEST_2, _
	TXT_USER_TYPE, _
	TXT_USER_TYPE_DELETED, _
	TXT_USER_TYPE_NAME, _
	TXT_USER_TYPE_NOT_DELETED, _
	TXT_USER_TYPE_NOT_UPDATED, _
	TXT_USER_TYPE_UPDATED, _
	TXT_VALID_START_PAGE, _
	TXT_VIEW_EDIT_USER_TYPE, _
	TXT_VIEW_FEEDBACK, _
	TXT_VIEW_OFFLINE, _
	TXT_WEB_DEVELOPER, _
	TXT_XML_SCHEMA

Sub setTxtUsers()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ACCOUNT_UPDATED = "The account was successfully updated"
			TXT_ACCOUNT_UPDATES = "Account Updates"
			TXT_ACCOUNT_IS_LOCKED = "This account has been locked due to 5 unsuccessful login attempts. A user with account management privileges must unlock the account."
			TXT_ACCOUNT_NOT_UPDATED = "The account was not updated" & TXT_COLON
			TXT_ACCOUNT_WILL_BE_LOCKED = TXT_WARNING & "This account will be locked after [#] more unsuccessful login attempt(s)."
			TXT_AGENCY = "Agency"
			TXT_ANY_OF_THE_FOLLOWING = "Any of the following" & TXT_COLON
			TXT_ANY_VIEW_THE_USER_CAN_ACCESS = "Any View(s) the user can access"
			TXT_API_KEYS = "Manage API Keys"
			TXT_BASED_ON_EXISTING_VIEW_1 = "Based on the current Default View of "
			TXT_BASED_ON_EXISTING_VIEW_2 = ", a user of this type would also see the View(s)" & TXT_COLON
			TXT_BASED_ON_EXISTING_VIEW_3 = ". If you have made changes to the Default View, submit the form to refresh this list."
			TXT_BLOCKED_USER = "User [USER] is a blocked account."
			TXT_CAN_ACCESS_PROFILES = "Can Access Profiles"
			TXT_CAN_ADD_RECORD = "Can Add Records"
			TXT_CAN_ADD_SQL = "Add SQL"
			TXT_CAN_ASSIGN_FEEDBACK = "Can Assign Feedback"
			TXT_CAN_COPY_RECORD = "Can Copy Records"
			TXT_CAN_DELETE = "Can Delete Records"
			TXT_CAN_DO_BULK = "Bulk Operations"
			TXT_CAN_INDEX_TAXONOMY = "Can Index Records"
			TXT_CAN_MANAGE_MEMBERS = "Can Manage Members"
			TXT_CAN_MANAGE_REFERRALS = "Can Manage Referrals"
			TXT_CAN_MANAGE_USERS = "Can Manage Users"
			TXT_CAN_REQUEST_UPDATE = "Can Request Update"
			TXT_CAN_UPDATE_PUBS = "Can Update Publications"
			TXT_CAN_UPDATE_RECORD = "Can Update Records"
			TXT_CAN_UPDATE_VACANCY = "Can Update Vacancy"
			TXT_CAN_VIEW_STATS = "Can View Statistics"
			TXT_CANT_EDIT_OWN_ACCOUNT_1 = "You cannot edit the permissions of your own account."
			TXT_CANT_EDIT_OWN_ACCOUNT_2 = "You can use <a href=""" & makeLinkB("account.asp") & """>My Account</a> to manage your name and password, but only another Super User can change your Agency or Security Level."
			TXT_CANT_EDIT_SUPERUSER = "Only another Super User can edit an account that has Super User privileges (in any module)."	
			TXT_CANT_EDIT_SUPERUSERGLOBAL = "Only another Global Super User can edit an account that has Global Super User privileges (in any module)."
			TXT_CANT_LOGIN_NON_SECURE_DOMAIN = "Login not permitted from insecure domain name"
			TXT_CHANGE_PASSWORD = "Change Password"
			TXT_CHECK_COOKIES = "Check that cookies are enabled for this site and try again."
			TXT_CHOOSE_USER = "Choose a user from the list below or add a new user."
			TXT_CHOOSE_USER_TYPE = "Choose a User Type from the list below or add a new User Type."
			TXT_COMMENT_ALERT = "Comment Alert"
			TXT_CONFIRM_PASSWORD = "Confirm Password"
			TXT_CREATE_ACCOUNT = "Create New Account"
			TXT_CREATE_EDIT_USER_TYPE = "Create / Edit User Type"
			TXT_CREATE_USER = "Create New User"
			TXT_CREATE_USER_TYPE = "Create User Type"
			TXT_DATABASE_DEFAULT = "Database Default"
			TXT_DATABASE_LOGIN = "Database Login"
			TXT_DEFAULT_VIEW = "Default View"
			TXT_EDIT_ACCOUNT = "Edit Account" & TXT_COLON
			TXT_EDIT_LOGIN_INFO = "Edit your login information"
			TXT_EDIT_USER_TYPE = "Edit User Type"
			TXT_EDITORIAL_VIEW = "Editorial View(s)"
			TXT_EXPORT_PERMISSIONS = "Export Permissions"
			TXT_EXTERNAL_APIS = "External APIs"
			TXT_FIRST_NAME = "First Name"
			TXT_USER_INACTIVE_DATE = "Last Status Change"
			TXT_INACTIVE_USER = "User [USER] is an inactive account."
			TXT_INDICATES_INACTIVE_USER = "<span class=""Alert"">*</span> indicates that the User is Inactive (cannot sign in)"
			TXT_INDICATES_LOCKED_ACCOUNT = "<span class=""Alert HighLight"">X</span> indicates a locked account due to repeated unsuccessful sign-in attempts"
			TXT_INITIALS = "Initials"
			TXT_INST_ACCESS_PROFILES_1 = "User can access partial Volunteer Profile information"
			TXT_INST_ACCESS_PROFILES_2 = "Profile information is available <em>only</em> when permission is given by the Profile user. " & _
				"Information is currently limited to search profile and contact information only."
			TXT_INST_ACCESS_PROFILES_3 = "Super Users can always access Profile information (if permission is given by the user)."
			TXT_INST_ACCOUNT_UPDATES_1 = "User can update their own name, initials, and Email."
			TXT_INST_ACCOUNT_UPDATES_2 = "User can update their own password."
			TXT_INST_ADD_RECORD_1 = "User can add records"
			TXT_INST_ADD_RECORD_2 = "Super Users can always add a record."
			TXT_INST_ADD_SQL_1 = "Can search using &quot;Add SQL&quot;"
			TXT_INST_ADD_SQL_2 = "Super Users can always search with Add SQL."
			TXT_INST_ASSIGN_FEEDBACK_1 = "User can assign a new record suggestions to a specific Agency."
			TXT_INST_ASSIGN_FEEDBACK_2 = "Super Users can always assign new record suggestions."
			TXT_INST_COPY_RECORD_1 = "User can copy records"
			TXT_INST_COPY_RECORD_2 = "Super Users can always copy a record."
			TXT_INST_COMMENT = "User sees an alert if a record has comments"
			TXT_INST_DELETE_1 = "User can delete records"
			TXT_INST_DELETE_2 = "Users can only delete records for which they have update privileges. Super Users can always delete records."
			TXT_INST_DO_BULK_1 = "User can perform bulk record operations (e.g. Add/Remove Code, multi-record Email requests)"
			TXT_INST_DO_BULK_2 = "Super users can always perform bulk operations."
			TXT_INST_EXPORT_1 = "User cannot export records"
			TXT_INST_EXPORT_2 = "User can export records from own Agency"
			TXT_INST_EXPORT_3 = "User can export records from own View"
			TXT_INST_EXPORT_4 = "User can export all records"
			TXT_INST_EXPORT_5 = "Super Users can always export any record."
			TXT_INST_EXTERNAL_API = "User can use the following external APIs:"
			TXT_INST_FEEDBACK_1 = "User sees an alert if a record has feedback, and can view a list of feedback available in their View. This does not include new record suggestions."
			TXT_INST_FEEDBACK_2 = "Super Users and those with Update and Add permissions can always see the list of feedback."
			TXT_INST_FULL_UPDATE_1 = "User can perform a full update"
			TXT_INST_FULL_UPDATE_2 = "Use this option to indicate that the user can change the update date and update schedule of a record and delete feedback while processing a record. It is recommended that you not give full update permissions if the update form for the View selected above does not contain all the fields you use. This option is only useful if the user has update permission."
			TXT_INST_FULL_UPDATE_3 = "Super Users can always perform a full update."
			TXT_INST_INDEX_TAXONOMY_1 = "User cannot index records using the AIRS / INFO LINE Taxonomy"
			TXT_INST_INDEX_TAXONOMY_2 = "User can index records from their own Agency"
			TXT_INST_INDEX_TAXONOMY_3 = "User can index all records in own View"
			TXT_INST_INDEX_TAXONOMY_4 = "Super Users can always index records with the AIRS / INFO LINE Taxonomy."
			TXT_INST_IMPORT_1 = "User can import records"
			TXT_INST_IMPORT_2 = "Super Users can always import any record."
			TXT_INST_LOGIN_1 = "Note: you must have cookies enabled to sign in successfully. Logins and passwords are case-sensitive."
			TXT_INST_LOGIN_2 = "Please remember to log out when you are finished."
			TXT_INST_MANAGE_MEMBERS_1 = "Can manager Volunteer Centre Member information."
			TXT_INST_MANAGE_MEMBERS_1 = "Super Users can always manage Volunteer Centre Member information."
			TXT_INST_MANAGE_REFERRALS_1 = "User can create and edit Volunteer Referrals for records from their own Agency"
			TXT_INST_MANAGE_REFERRALS_2 = "Super Users can manage Referrals for all records."
			TXT_INST_MANAGE_USERS_1 = "User can create and modify user accounts"
			TXT_INST_MANAGE_USERS_2 = "Users can only modify counts with equal or lower permissions to their accounts. Users cannot modify their own accounts. Super Users can always create and modify accounts."
			TXT_INST_PASSWORD_1 = "We cannot guarantee the security of your password. Please do not use a password you use for other services."
			TXT_INST_PASSWORD_2	= "Passwords should be at least 8 characters long, with at least one lowercase letter, uppercase letter, and number."
			TXT_INST_PASSWORD_3 = "You don't need to fill in this part of the form unless you want to change your existing password."
			TXT_INST_REQUEST_UPDATE_1 = "User can view mail form / Email an update request for <strong>an individual record from their Agency</strong>."
			TXT_INST_REQUEST_UPDATE_2 = "Super Users can always request an update."
			TXT_INST_SINGLE_LOGIN = "This user may only have one active logged in session."
			TXT_INST_SUPER_USER_1 = "User is a Super User"
			TXT_INST_SUPER_USER_2 = "Super Users can create and modify user accounts for any Agency, update checklists and publications, perform operations on multiple records from within a results set (e.g. Add Pub Code, Find &amp; Replace, Email Update Request), add or modify any record, delete records or restore them, and edit setup information."
			TXT_INST_SUPER_USER_3 = "Because this database is shared by multiple CIOC Members, this type of Super User is a <strong>Local</strong> Super User with some limitations. A Local Super User can only manage set areas specific to their own Membership."
			TXT_INST_SUPER_USER_GLOBAL_1 = "User is a Global Super User"
			TXT_INST_SUPER_USER_GLOBAL_2 = "Global Super Users manage areas of the software that are shared among all the CIOC Members in this database. Global Super Users also act as Local Super Users for their own Membership."
			TXT_INST_SUPPRESS_EMAIL_1 = "User can suppress notification Emails to organizations and administrators"
			TXT_INST_SUPPRESS_EMAIL_2 = "Use this option to indicate that a user can choose to have the system not send Emails to the organization or update adminstrator when submitting feedback."
			TXT_INST_SUPPRESS_EMAIL_3 = "Super Users can always suppress Emails."
			TXT_INST_UPDATE_PUBS_1 = "User cannot update Publications"
			TXT_INST_UPDATE_PUBS_2 = "User can update Publication data in records"
			TXT_INST_UPDATE_PUBS_3 = "User can update all Publication data"
			TXT_INST_UPDATE_PUBS_4 = "Use this option to indicate that a user can update the publication codes, descriptions, and headings of any record in their view."
			TXT_INST_UPDATE_PUBS_5 = "If the view selected above is a limited Publication view, the user can only edit Headings and Descriptions for that Publication, and can update General Headings for a set of records in bulk. Super Users can always update all publications."
			TXT_INST_UPDATE_RECORD_1 = "Limit updating to records of the following types (<strong>optional</strong>)" & TXT_COLON
			TXT_INST_UPDATE_RECORD_2 = "Super Users can update any record they can access."
			TXT_INST_UPDATE_RECORD_3 = "Limit updating records to the following languages (<strong>optional</strong>):"
			TXT_INST_UPDATE_RECORD_OPT_1 = "User cannot update records"
			TXT_INST_UPDATE_RECORD_OPT_2 = "User can update all records in their Editorial View(s)"
			TXT_INST_UPDATE_RECORD_OPT_3 = "User can update records from their own Agency"
			TXT_INST_UPDATE_RECORD_OPT_4 = "User can update records belonging to specific Agencies" & TXT_COLON
			TXT_INST_UPDATE_VACANCY_1 = "Enabling vacancy information editing will provide an interface on search results and record details pages to increment and decrement vacant space only."
			TXT_INST_UPDATE_VACANCY_2 = "Super Users can update vacancy information for any record they can access."
			TXT_INST_UPDATE_VACANCY_OPT_1 = "User cannot update vacancy information"
			TXT_INST_UPDATE_VACANCY_OPT_2 = "User can update vacancy information for all records in their Vacancy Editorial View(s) (see below)"
			TXT_INST_UPDATE_VACANCY_OPT_3 = "User can update vacancy information for records from their own Agency"
			TXT_INST_UPDATE_VACANCY_OPT_4 = "User can update vacancy information for records belonging to specific Agencies:"
			TXT_INST_USER_TYPE_NAME = "Use a descriptive name that makes it clear what the view and permission are. (e.g. &quot;Staff View - VOL View Only&quot;, &quot;Management View - CIC Agency Admin&quot;)"
			TXT_INST_VIEW_STATS_1 = "Users cannot view statistics."
			TXT_INST_VIEW_STATS_2 = "Users can view statistics for records in views they have access to."
			TXT_INST_VIEW_STATS_3 = "Users can view all statistics on all records."
			TXT_INST_VIEW_STATS_4 = "Super Users can always view statistics on all records."
			TXT_INST_VIEW_TYPE = "The user's Default View is the one they start in when they initially sign in to the database. This View is also used to determine which other Views (if any) that this user may access; this is based on which Views the chosen View &quot;Can See&quot;."
			TXT_INST_VIEW_TYPE_EDITORIAL_1 = "If the user has permission to update records, indicate the View(s) in which they can perform updates" & TXT_COLON
			TXT_INST_VIEW_TYPE_EDITORIAL_2 = "Users can only perform updates in Views they can access. If you are creating a new record or have updated the Default View for this User Type, submit the form to refresh the list of possible Editorial Views." 
			TXT_INST_VIEW_TYPE_OFFLINE = "View to use with offline tools for this user type. No selected view prevents this user type from using offline tools."
			TXT_INST_VIEW_TYPE_VACANCY_EDITORIAL_1 = "If the user has permission to update vacancy information, indicate the View(s) in which they can perform updates:"
			TXT_INST_WEB_DEVELOPER_1 = "User is a Website Designer / Developer for this application"
			TXT_INST_WEB_DEVELOPER_2 = "Use this privilege to allow users that <em>do not</em> have Super User status to manage Design Templates and Layouts. Note that this type of user cannot assign Design Templates and Layouts to Views."
			TXT_INVALID_OLD_PASSWORD = "Old password is incorrect."
			TXT_INVALID_USERNAME_PASSWORD = "No account exists for user: [USER], or the password is incorrect."
			TXT_IMPORT_PERMISSIONS = "Import Permissions"
			TXT_LAST_ATTEMPT = "Last Attempt" & TXT_COLON
			TXT_LAST_LOGIN = "Last Login"
			TXT_LAST_NAME = "Last Name"
			TXT_LOCKED_ACCOUNT = "Locked Account"
			TXT_LOGIN_FAILED = "Login to the database failed"
			TXT_LOGIN_TO_DATABASE = "Log in to the database" & TXT_COLON
			TXT_MANAGE_USER_TYPES = "Manage User Types"
			TXT_MAXIMUM_OF = "Maximum of "
			TXT_MY_ACCOUNT_ACCESS = "&quot;My Account&quot; Access"
			TXT_NEW_PASSWORD = "New Password"
			TXT_NEW_USER = "New User"
			TXT_NO_CHANGES = "You did not make any changes to your account information."
			TXT_OLD_PASSWORD = "Old Password"
			TXT_PASSWORD = "Password"
			TXT_PASSWORD_DATE = "Last Password Change"
			TXT_PASSWORD_NOT_SECURE = "The password you gave is not secure. You will be redirected to the <em>My Account</em> page when you sign in until the password is changed."
			TXT_PASSWORD_REQUIRED = "You must provide a password."
			TXT_PASSWORDS_MUST_MATCH = "New password and confirm password do not match."
			TXT_REPEATED_ATTEMPTS_BLOCKS_IP = "Note that repeated unauthorized attempts to access the database that lock multiple accounts will block all login attempts to the database from the above IP Address. Should this occur, you will need to notify your database technical support to have the IP Address block removed."
			TXT_REQUEST_ACCOUNT_CHANGE = "Request a change to your account"
			TXT_REQUEST_ACCOUNT_CHANGE_FOR = "Account change request for "
			TXT_REQUEST_SENT = "Your request to update your account has been sent."
			TXT_RETURN_EDIT_USERS = "Return to Edit Users"
			TXT_RETURN_USER_TYPES = "Return to User Types"
			TXT_SAVED_SEARCHES = " saved searches (0-255)"
			TXT_SECURE_DOMAIN_LIST = "Please choose a secure domain from the list below to login:"
			TXT_SEND_NEW_PASSWORD = "Request a password reset"
			TXT_SEND_REQUEST = "Send Request"
			TXT_SHOW_FIELDS = "Show Fields"
			TXT_SIGN_IN = "Sign In"
			TXT_SINGLE_LOGIN = "Single Login"
			TXT_START_PAGE = "Start Page"
			TXT_STATUS_DELETE = "Because this User Type is not being used, you can delete it using the button at the bottom of the form."
			TXT_STATUS_NO_DELETE = "Because this User Type is being used, you cannot currently delete it."
			TXT_STATUS_NO_USE = "This User Type is <strong>not</strong> being used by any users."
			TXT_STATUS_USE = "This User Type is <strong>being used</strong> by the following users" & TXT_COLON
			TXT_SUPER_USER = "Super User"
			TXT_SUPER_USER_GLOBAL = "Global Super User"
			TXT_SUPPRESS_EMAIL = "Suppress Email"
			TXT_THIS_USERS_ACCOUNT_INFO = "Below is this users's current account information" & TXT_COLON
			TXT_TRIES = "tries"
			TXT_UNABLE_TO_SEND_REQUEST = "Your request to update your account could not be sent."
			TXT_UNLOCK_THIS_ACCOUNT = "Unlock this account"
			TXT_UPDATE_ACCOUNT_FAILED = "Update Account Failed"
			TXT_UPDATE_USER_TYPE_FAILED = "Update User Type Failed"
			TXT_USER_CHANGE_HISTORY = "Account Change History"
			TXT_USER_IS_INACTIVE = "User is Inactive (cannot sign in)"
			TXT_USER_IS_TECH_ADMIN = "The user is a Technical Administrator"
			TXT_USER_MAX_SEARCHES = "User's maximum number of saved searches"
			TXT_USER_NAME = "User Name"
			TXT_USER_NAME_REQUIRED = "You must specify a user name."
			TXT_USER_REQUEST_1 = "The user "
			TXT_USER_REQUEST_2 = " has requested a change to their account. Please review the change request below."
			TXT_USER_TYPE = "User Type"
			TXT_USER_TYPE_DELETED = "The User Type was successfully deleted"
			TXT_USER_TYPE_NAME = "User&nbsp;Type&nbsp;Name"
			TXT_USER_TYPE_NOT_DELETED = "The User Type was not deleted" & TXT_COLON
			TXT_USER_TYPE_NOT_UPDATED = "The User Type was not updated" & TXT_COLON
			TXT_USER_TYPE_UPDATED = "The User Type was successfully updated"
			TXT_VIEW_EDIT_USER_TYPE = "View / Edit User Type"
			TXT_VIEW_FEEDBACK = "View Feedback"
			TXT_VIEW_OFFLINE = "Offline Tools View"
			TXT_WEB_DEVELOPER = "Website Designer / Developer"
			TXT_XML_SCHEMA = "XML Schema"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACCOUNT_UPDATED = "Le compte a été mis à jour avec succès."
			TXT_ACCOUNT_UPDATES = "Mises à jour des comptes"
			TXT_ACCOUNT_IS_LOCKED = "Ce compte a été verrouillé suite à 5 tentatives de connexion incorrectes. Le compte doit être déverrouillé par un utilisateur possédant des privilèges de gestion des comptes."
			TXT_ACCOUNT_WILL_BE_LOCKED = TXT_WARNING & "Ce compte sera verrouillé après [#] tentative(s) de connexion incorrecte(s) supplémentaire(s)."
			TXT_ACCOUNT_NOT_UPDATED = "Le compte n'a pas été mise à jour." & TXT_COLON
			TXT_ANY_OF_THE_FOLLOWING = "Parmi les suivantes" & TXT_COLON
			TXT_ANY_VIEW_THE_USER_CAN_ACCESS = "Toutes les vues auxquelles l'utilisateur peut accéder"
			TXT_API_KEYS = "TRANSLATE_FR -- Manage API Keys"
			TXT_AGENCY = "Agence"
			TXT_BASED_ON_EXISTING_VIEW_1 = "Selon la vue par défaut actuelle de "
			TXT_BASED_ON_EXISTING_VIEW_2 = ", un utilisateur de ce type peut également voir les vues" & TXT_COLON
			TXT_BASED_ON_EXISTING_VIEW_3 = ". Si vous avez effectué des modifications à la vue par défaut, soumettez le formulaire pour rafraîchir cette liste."
			TXT_BLOCKED_USER = "L'utilisateur [USER] est un compte verrouillé."
			TXT_CAN_ACCESS_PROFILES = "Peut accéder aux profils"
			TXT_CAN_ADD_RECORD = "Peut ajouter des dossiers"
			TXT_CAN_ADD_SQL = "Ajouter SQL"
			TXT_CAN_ASSIGN_FEEDBACK = "Peut attribuer une rétroaction"
			TXT_CAN_COPY_RECORD = "Peut copier des dossiers"
			TXT_CAN_DELETE = "Peut supprimer des dossiers"
			TXT_CAN_DO_BULK = "Opérations en gros"
			TXT_CAN_INDEX_TAXONOMY = "Peut indexer des dossiers"
			TXT_CAN_MANAGE_MEMBERS = "Peut gérer les membres"
			TXT_CAN_MANAGE_REFERRALS = "Peut gérer les références"
			TXT_CAN_MANAGE_USERS = "Peut gérer les utilisateurs"
			TXT_CAN_REQUEST_UPDATE = "Peut demander une mise à jour"
			TXT_CAN_UPDATE_PUBS = "Peut mettre à jour les publications"
			TXT_CAN_UPDATE_RECORD = "Peut mettre à jour les dossiers"
			TXT_CAN_UPDATE_VACANCY = "TRANSLATE_FR -- Can Update Vacancy"
			TXT_CAN_VIEW_STATS = "Peut visualiser les statistiques"
			TXT_CANT_EDIT_OWN_ACCOUNT_1 = "Vous n'avez pas l'autorisation de modifier votre propre compte."
			TXT_CANT_EDIT_OWN_ACCOUNT_2 = "Vous pouvez utiliser <a href=""" & makeLinkB("account.asp") & """>Mon compte</a> pour gérer votre nom et votre mot de passe, mais seul un super-utilisateur peut modifier votre agence ou niveau de sécurité."
			TXT_CANT_EDIT_SUPERUSER = "Seul un super-utilisateur peut modifier un compte ayant les droits d'un super-utilisateur (quelque soit le module)."	
			TXT_CANT_EDIT_SUPERUSERGLOBAL = "Seul un autre super-utilisateur global peut modifier un compte ayant les droits d'un super-utilisateur global (quelque soit le module)."
			TXT_CANT_LOGIN_NON_SECURE_DOMAIN = "TRANSLATE_FR -- Login not permitted from insecure domain name"
			TXT_CHANGE_PASSWORD = "Modifier le mot de passe"
			TXT_CHECK_COOKIES = "Vérifiez que les cookies sont autorisés et réessayez."
			TXT_CHOOSE_USER = "Sélectionnez un utilisateur compris dans la liste ci-dessous ou ajoutez un nouvel utilisateur."
			TXT_CHOOSE_USER_TYPE = "Sélectionnez un type d'utilisateur compris dans la liste ci-dessous ou ajoutez un nouveau type d'utilisateur."
			TXT_COMMENT_ALERT = "Alerte concernant les commentaires"
			TXT_CONFIRM_PASSWORD = "Confirmer le mot de passe"
			TXT_CREATE_ACCOUNT = "Créer un nouveau compte"
			TXT_CREATE_EDIT_USER_TYPE = "Créer / Modifier un type d'utilisateur"
			TXT_CREATE_USER = "Créer un nouvel utilisateur"
			TXT_CREATE_USER_TYPE = "Créer un type d'utilisateur"
			TXT_DATABASE_DEFAULT = "Paramètres par défaut de la base de données"
			TXT_DATABASE_LOGIN = "Connexion à la base de données"
			TXT_DEFAULT_VIEW = "Vue par défaut"
			TXT_EDIT_ACCOUNT = "Modifier le compte" & TXT_COLON
			TXT_EDIT_LOGIN_INFO = "Modifier les informations de votre compte"
			TXT_EDIT_USER_TYPE = "Modifier le type d'utilisateur"
			TXT_EDITORIAL_VIEW = "Vue(s) de mise à jour"
			TXT_EXPORT_PERMISSIONS = "Exporter les autorisations"
			TXT_EXTERNAL_APIS = "API externes."
			TXT_FIRST_NAME = "Prénom"
			TXT_USER_INACTIVE_DATE = "Dernier changement de statut"
			TXT_INACTIVE_USER = "Le compte de l'utilisateur [USER] est inactif."
			TXT_INDICATES_INACTIVE_USER = "<span class=""Alert"">*</span> signifie que l'utilisateur est inactif (il ne peut pas ouvrir de session)"
			TXT_INDICATES_LOCKED_ACCOUNT = "<span class=""Alert HighLight"">X</span> indique un compte verrouillé en raison de tentatives de connexion incorrectes répétées"
			TXT_INITIALS = "Initiales"
			TXT_INST_ACCESS_PROFILES_1 = "L'utilisateur peut accéder à des informations partielles sur les profils de bénévoles"
			TXT_INST_ACCESS_PROFILES_2 = "Les informations sur les profils sont <em>uniquement</em> disponibles quand l'utilisateur du profil en donne la permission. " & _
				"L'information est présentement limitée à la recherche sur les profils et les coordonnées uniquement."
			TXT_INST_ACCESS_PROFILES_3 = "Les super-utilisateurs peuvent toujours accéder aux informations sur les profils (si l'utilisateur aen donne l'autorisation)."
			TXT_INST_ACCOUNT_UPDATES_1 = "L'utilisateur peut mettre à jour son nom, ses initiales et son courriel."
			TXT_INST_ACCOUNT_UPDATES_2 = "L'utilisateur peut mettre à jour son mot de passe."
			TXT_INST_ADD_RECORD_1 = "L'utilisateur peut créer des dossiers"
			TXT_INST_ADD_RECORD_2 = "Les super-utilisateurs peuvent toujours créer un dossier."
			TXT_INST_ADD_SQL_1 = "Peut rechercher en utilisant &quot;Ajouter SQL&quot;"
			TXT_INST_ADD_SQL_2 = "Les super-utilisateurs peuvent toujours rechercher avec Ajouter SQL."
			TXT_INST_ASSIGN_FEEDBACK_1 = "L'utilisateur peut attribuer une suggestion de nouveau dossier à une agence spécifique."
			TXT_INST_ASSIGN_FEEDBACK_2 = "Les super-utilisateurs peuvent toujours attribuer des suggestions de nouveaux dossiers."
			TXT_INST_COPY_RECORD_1 = "L'utilisateur peut copier des dossiers"
			TXT_INST_COPY_RECORD_2 = "Les super-utilisateurs peuvent toujours copier un dossier."
			TXT_INST_COMMENT = "L'utilisateur reçoit un message d'alerte si un dossier est accompagné de commentaires."
			TXT_INST_DELETE_1 = "L'utilisateur peut supprimer des dossiers"
			TXT_INST_DELETE_2 = "Les utilisateurs peuvent uniquement supprimer les dossiers pour lesquels ils ont les privilèges de mise à jour. Les super-utilisateurs peuvent toujours supprimer des dossiers."
			TXT_INST_DO_BULK_1 = "L'utilisateur peut effectuer des opérations en gros sur les dossiers (par ex. Ajouter/Supprimer un code, demandes par courriel sur des dossiers multiples)"
			TXT_INST_DO_BULK_2 = "Les super-utilisateurs peuvent toujours effectuer des opérations en gros."
			TXT_INST_EXPORT_1 = "L'utilisateur ne peut pas exporter de dossier"
			TXT_INST_EXPORT_2 = "L'utilisateur peut exporter les dossiers de sa propre agence"
			TXT_INST_EXPORT_3 = "L'utilisateur peut exporter des dossiers de sa propre vue"
			TXT_INST_EXPORT_4 = "L'utilisateur peut exporter tous les dossiers"
			TXT_INST_EXPORT_5 = "Les super-utilisateurs peuvent toujours exporter des dossiers."
			TXT_INST_EXTERNAL_API = "L'utilisateur peut utiliser les API externes suivantes :"
			TXT_INST_FEEDBACK_1 = "L'utilisateur reçoit un message d'alerte si le dossier est accompagné d'une rétroaction et peut afficher la liste des rétroactions disponibles dans leur vue. Cela n'inclut pas les suggestions de nouveaux dossiers."
			TXT_INST_FEEDBACK_2 = "Les super-utilisateurs et ceux possédant les autorisations de mise à jour et de création peuvent toujours voir la liste des rétroactions."
			TXT_INST_FULL_UPDATE_1 = "L'utilisateur peut effectuer une mise à jour complète"
			TXT_INST_FULL_UPDATE_2 = "Utiliser cette option pour indiquer que l'utilisateur peut modifier la date de mise à jour et le calendrier des mises à jour et peut supprimer la rétroaction lors du traitement du dossier. Il est recommandé de ne pas donner d'autorisation de mise à jour complète si le formulaire de mise à jour pour la vue sélectionnée ci-dessus ne contient pas tous les champs utilisés. Cette option est utile seulement si l'utilisateur a l'autorisation de mettre à jour."
			TXT_INST_FULL_UPDATE_3 = "Les super-utilisateurs peuvent toujours effectuer une mise à jour complète."
			TXT_INST_INDEX_TAXONOMY_1 = "L'utilisateur ne peut pas indexer de dossiers avec la Taxonomie AIRS/211 LA County"
			TXT_INST_INDEX_TAXONOMY_2 = "L'utilisateur peut indexer les dossiers de sa propre agence"
			TXT_INST_INDEX_TAXONOMY_3 = "L'utilisateur peut indexer tous les dossiers dans sa propre vue"
			TXT_INST_INDEX_TAXONOMY_4 = "Les super-utilisateurs peuvent toujours indexer des dossiers avec la Taxonomie AIRS/211 LA County."
			TXT_INST_IMPORT_1 = "L'utilisateur peut importer des dossiers"
			TXT_INST_IMPORT_2 = "Les super-utilisateurs peuvent toujours importer des dossiers."
			TXT_INST_LOGIN_1 = "Remarque : vous devez autoriser les cookies pour pouvoir vous connecter . Les noms d'utilisateur et les mots de passe respectent la casse."
			TXT_INST_LOGIN_2 = "Pensez à vous déconnecter quand vous avez terminé."
			TXT_INST_MANAGE_MEMBERS_1 = "Peut gérer les renseignements du membre du centre de bénévolat."
			TXT_INST_MANAGE_MEMBERS_2 = "Les super-utilisateurs peuvent toujours gérer les renseignements du membre du centre de bénévolat."
			TXT_INST_MANAGE_REFERRALS_1 = "L'utilisateur peut créer et modifier des références de bénévolat pour les dossiers de sa propre agence"
			TXT_INST_MANAGE_REFERRALS_2 = "Les super-utilisateurs peuvent gérer les références pour tous les dossiers."
			TXT_INST_MANAGE_USERS_1 = "L'utilisateur peut créer et modifier des comptes d'utilisateur"
			TXT_INST_MANAGE_USERS_2 = "Les utilisateurs peuvent seulement modifier les comptes dont les autorisations sont égales ou inférieures aux leurs. Les utilisateurs ne peuvent pas modifier leur propre compte. Les super-utilisateurs peuvent toujours créer et modifier des comptes."
			TXT_INST_PASSWORD_1 = "La sécurité de votre mot de passe ne peut être garantie. Veuillez ne pas utiliser le même mot de passe que pour d'autres services."
			TXT_INST_PASSWORD_2	= "Les mots de passe doivent comporter au moins 8 caractères, y compris au minimum une lettre minuscule, une lettre majuscule et un chiffre."
			TXT_INST_PASSWORD_3 = "Vous n'avez pas besoin de remplir cette partie du formulaire, à moins que vous souhaitiez changer votre mot de passe actuel."
			TXT_INST_REQUEST_UPDATE_1 = "L'utilisateur peut voir le formulaire par courrier ou envoyer par courriel une demande de mise à jour pour <strong>un dossier individuel de son agence</strong>."
			TXT_INST_REQUEST_UPDATE_2 = "Les super-utilisateurs peuvent toujours faire une demande de mise à jour."
			TXT_INST_SINGLE_LOGIN = "Cet utilisateur peut n'avoir qu'une seule session active à la fois."
			TXT_INST_SUPER_USER_1 = "L'utilisateur est un super-utilisateur"
			TXT_INST_SUPER_USER_2 = "Les super-utilisateurs peuvent créer et modifier des comptes d'utilisateur pour n'importe quelle agence, mettre à jour des listes de contrôle et des publications, effectuer des opérations sur plusieurs dossiers compris dans un ensemble de résultats (par ex. ajouter un code de publication, Rechercher/Remplacer, faire une demande de mise à jour par courriel), créer ou modifier un dossier, supprimer des dossiers ou les restaurer et, modifier des informations de configuration."
			TXT_INST_SUPER_USER_3 = "Cette base de données est partagée par plusieurs membres CIOC, en conséquence ce type de super-utilisateur est un super-utilisateur <strong>local</strong> avec quelques limites. Un super-utilisateur local peut seulement gérer des zones déterminées spécifiques à sa propre membriété."
			TXT_INST_SUPER_USER_GLOBAL_1 = "L'utilisateur est un super-utilisateur global"
			TXT_INST_SUPER_USER_GLOBAL_2 = "Les super-utilisateurs globaux gèrent les zones du logiciel qui sont communes à tous les membres CIOC dans cette base de données. Les super-utilisateurs globaux agissent également comme super-utilisateur local pour leur propre membriété."
			TXT_INST_SUPPRESS_EMAIL_1 = "L'utilisateur peut supprimer des notifications par courriel aux organisations et administrateurs"
			TXT_INST_SUPPRESS_EMAIL_2 = "Utiliser cette option pour indiquer qu'un utilisateur peut choisir si le système enverra des courriels à l'organisme ou des mises à jour à l'administrateur lors de la soumission d'une rétroaction."
			TXT_INST_SUPPRESS_EMAIL_3 = "Les super-utilisateurs peuvent toujours supprimer les courriels."
			TXT_INST_UPDATE_PUBS_1 = "L'utilisateur ne peut pas mettre à jour les publications"
			TXT_INST_UPDATE_PUBS_2 = "L'utilisateur peut mettre à jour les données de publication dans les dossiers"
			TXT_INST_UPDATE_PUBS_3 = "L'utilisateur peut mettre à jour toutes les données de publication"
			TXT_INST_UPDATE_PUBS_4 = "Utiliser cette option pour indiquer qu'un utilisateur peut mettre à jour les codes de publication, les descriptions et les en-têtes de n'importe quel dossier dans sa vue."
			TXT_INST_UPDATE_PUBS_5 = "Si la vue sélectionnée ci-dessus est une vue limitée par publication, l'utilisateur ne peut modifier que les en-têtes et les descriptions pour cette publication uniquement et, il peut mettre à jour les en-têtes généraux pour un ensemble de dossiers en gros. Les super-utilisateurs peuvent toujours mettre à jour toutes les publications."
			TXT_INST_UPDATE_RECORD_1 = "Limiter la mise à jour aux dossiers de type suivant (<strong>facultatif</strong>)" & TXT_COLON
			TXT_INST_UPDATE_RECORD_2 = "Les super-utilisateurs peuvent mettre à jour tous les dossiers auxquels ils peuvent accéder."
			TXT_INST_UPDATE_RECORD_3 = "Limiter la mise à jour des dossiers aux langues suivantes (<strong>facultatif</strong>) :"
			TXT_INST_UPDATE_RECORD_OPT_1 = "L'utilisateur ne peut pas mettre à jour les dossiers"
			TXT_INST_UPDATE_RECORD_OPT_2 = "L'utilisateur peut mettre à jour tous les dossiers dans leurs vues de mise à jour"
			TXT_INST_UPDATE_RECORD_OPT_3 = "L'utilisateur peut mettre à jour les dossiers de sa propre agence"
			TXT_INST_UPDATE_RECORD_OPT_4 = "L'utilisateur peut mettre à jour les dossiers appartenant à des agences spécifique" & TXT_COLON
			TXT_INST_UPDATE_VACANCY_1 = "TRANSLATE_FR -- Enabling vacancy information editing will provide an interface on search results and record details pages to increment and decrement vacant space only."
			TXT_INST_UPDATE_VACANCY_2 = "TRANSLATE_FR -- Super Users can update vacancy information for any record they can access."
			TXT_INST_UPDATE_VACANCY_OPT_1 = "TRANSLATE_FR -- User cannot update vacancy information"
			TXT_INST_UPDATE_VACANCY_OPT_2 = "TRANSLATE_FR -- User can update vacancy information for all records in their Vacancy Editorial View(s) (see below)"
			TXT_INST_UPDATE_VACANCY_OPT_3 = "TRANSLATE_FR -- User can update vacancy information for records from their own Agency"
			TXT_INST_UPDATE_VACANCY_OPT_4 = "TRANSLATE_FR -- User can update vacancy information for records belonging to specific Agencies:"
			TXT_INST_USER_TYPE_NAME = "Utilisez un nom descriptif qui clarifie quelles sont la vue et les autorisations. (par ex. &quot;Vue Personnel - Vue Bénévolat seul.&quot;, &quot;Vue Gestionnaire - Admin CIC&quot;)"
			TXT_INST_VIEW_STATS_1 = "TRANSLATE_FR -- Users cannot view statistics."
			TXT_INST_VIEW_STATS_2 = "Les utilisateurs peuvent voir les statistiques pour les dossiers dans les vues auxquelles ils ont accès."
			TXT_INST_VIEW_STATS_3 = "TRANSLATE_FR -- Users can view all statistics on all records."
			TXT_INST_VIEW_STATS_4 = "Les super-utilisateurs peuvent toujours voir les statistiques sur tous les dossiers."
			TXT_INST_VIEW_TYPE = "TRANLSATE_FR -- The user's Default View is the one they start in when they initially sign in to the database. This View is also used to determine which other Views (if any) that this user may access; this is based on which Views the chosen View &quot;Can See&quot;."
			TXT_INST_VIEW_TYPE_OFFLINE = "Vue à utiliser avec les outils hors-ligne pour ce type d'utilisateur. Ce type d'utilisateur ne peut pas utiliser les outils hors-ligne lorsqu'il n'y a pas de vue sélectionnée."
			TXT_INST_VIEW_TYPE_VACANCY_EDITORIAL_1 = "TRANSLATE_FR -- If the user has permission to update vacancy information, indicate the View(s) in which they can perform updates:"
			TXT_INST_WEB_DEVELOPER_1 = "L'utilisateur est un concepteur /développeur de site web pour cette application"
			TXT_INST_WEB_DEVELOPER_2 = "Utiliser ce privilège pour permettre aux utilisateurs qui <em>n'ont pas</em> le statut de super-utilisateur de gérer les modèles de conception et les mises en page. À noter que ce type d'utilisateur ne peut pas attribuer de modèles de conception et de mises en page aux vues."
			TXT_INVALID_OLD_PASSWORD = "L'ancien mot de passe est incorrect."
			TXT_INVALID_USERNAME_PASSWORD = "Il n'existe pas de compte pour l'utilisateur [USER] ou bien le mot de passe est incorrect."
			TXT_IMPORT_PERMISSIONS = "Autorisations d'importation"
			TXT_LAST_ATTEMPT = "Dernière tentative" & TXT_COLON
			TXT_LAST_LOGIN = "Dernière connexion"
			TXT_LAST_NAME = "Nom de famille"
			TXT_LOCKED_ACCOUNT = "Compte verrouillé"
			TXT_LOGIN_FAILED = "La connexion à la base de données a échoué"
			TXT_LOGIN_TO_DATABASE = "Se connecter à la base de données" & TXT_COLON
			TXT_MANAGE_USER_TYPES = "Gérer les types d'utilisateur"
			TXT_MAXIMUM_OF = "Maximum de "
			TXT_MY_ACCOUNT_ACCESS = "Accès à &quot;Mon compte&quot;"
			TXT_NEW_PASSWORD = "Nouveau mot de passe"
			TXT_NEW_USER = "Nouvel utilisateur"
			TXT_NO_CHANGES = "Vous n'avez pas modifié d'information sur votre compte."
			TXT_OLD_PASSWORD = "Ancien mot de passe"
			TXT_PASSWORD = "Mot de passe"
			TXT_PASSWORD_DATE = "Dernière modification du mot de passe"
			TXT_PASSWORD_NOT_SECURE = "Le mot de passe que vous avez donné n'est pas sécurisé. Vous serez redirigé vers la page <em>Mon compte</em> quand vous vous connecterez, jusqu'à ce que votre mot de passe soit modifié."
			TXT_PASSWORD_REQUIRED = "Vous devez fournir un mot de passe."
			TXT_PASSWORDS_MUST_MATCH = "Le nouveau mot de passe ne correspond pas à la confirmation."
			TXT_REPEATED_ATTEMPTS_BLOCKS_IP = "À noter qu'en cas de multiples tentatives d'accès non autorisées à la base de données verrouillant plusieurs comptes, toutes les tentatives de connexion en provenance de l'adresse IP ci-dessus seront bloquées. Si cela se produit, vous devez le notifier au personnel de soutien technique de la base de donnée pour débloquer l'adresse IP."
			TXT_REQUEST_ACCOUNT_CHANGE = "Demander la modification de votre compte"
			TXT_REQUEST_ACCOUNT_CHANGE_FOR = "Demande de modification du compte de "
			TXT_REQUEST_SENT = "Votre demande de mise à jour de votre compte a été envoyée."
			TXT_RETURN_EDIT_USERS = "Retourner à la modification des types d'utilisateur"
			TXT_RETURN_USER_TYPES = "Retourner aux types d'utilisateur"
			TXT_SAVED_SEARCHES = " recherches sauvegardées (0-255)"
			TXT_SECURE_DOMAIN_LIST = "TRANSLATE_FR -- Please choose a secure domain from the list below to login:"
			TXT_SEND_NEW_PASSWORD = "Demander la réinitialisation d'un mot de passe"
			TXT_SEND_REQUEST = "Envoyer la demande"
			TXT_SHOW_FIELDS = "Afficher les champs"
			TXT_SIGN_IN = "Ouvrir une session"
			TXT_SINGLE_LOGIN = "Compte unique"
			TXT_START_PAGE = "Page de démarrage"
			TXT_STATUS_DELETE = "Comme ce type d'utilisateur n'est pas utilisé, vous pouvez le supprimer en activant le bouton en bas du formulaire."
			TXT_STATUS_NO_DELETE = "Comme ce type d'utilisateur est actuellement utilisé, vous ne pouvez pas le supprimer."
			TXT_STATUS_NO_USE = "Ce type d'utilisateur <strong>n'est pas</strong> utilisé par aucun utilisateur."
			TXT_STATUS_USE = "Ce type d'utilisateur est <strong>utilisée</strong> par les utilisateurs suivants" & TXT_COLON
			TXT_SUPER_USER = "Super-utilisateur"
			TXT_SUPER_USER_GLOBAL = "Super-utilisateur global"
			TXT_SUPPRESS_EMAIL = "Supprimer le courriel"
			TXT_THIS_USERS_ACCOUNT_INFO = "Ci-dessous les informations courantes du compte de cet utilisateur" & TXT_COLON
			TXT_TRIES = "essais"
			TXT_UNABLE_TO_SEND_REQUEST = "Votre demande de mise à jour de votre compte n'a pas pu être envoyée."
			TXT_UNLOCK_THIS_ACCOUNT = "Déverrouiller ce compte"
			TXT_UPDATE_ACCOUNT_FAILED = "La mise à jour du compte a échoué"
			TXT_UPDATE_USER_TYPE_FAILED = "La mise à jour du type d'utilisateur a échoué"
			TXT_USER_IS_INACTIVE = "L'utilisateur est inactif (il ne peut pas ouvrir de session)"
			TXT_USER_IS_TECH_ADMIN = "L'utilisateur est un administrateur technique"
			TXT_USER_CHANGE_HISTORY = "Historique des changements au compte"
			TXT_USER_MAX_SEARCHES = "TR_FR -- User's maximum number of saved searches"
			TXT_USER_NAME = "Nom d'utilisateur"
			TXT_USER_NAME_REQUIRED = "Vous devez préciser un nom d'utilisateur."
			TXT_USER_REQUEST_1 = "L'utilisateur "
			TXT_USER_REQUEST_2 = " a demandé que son compte soit modifié. Veuillez vérifier la demande de modification ci-dessous."
			TXT_USER_TYPE = "Type d'utilisateur"
			TXT_USER_TYPE_DELETED = "Le type d'utilisateur a été supprimé avec succès"
			TXT_USER_TYPE_NAME = "Nom du type d'utilisateur"
			TXT_USER_TYPE_NOT_DELETED = "Le type d'utilisateur n'a pas été supprimé" & TXT_COLON
			TXT_USER_TYPE_NOT_UPDATED = "Le type d'utilisateur n'a pas été mis à jour" & TXT_COLON
			TXT_USER_TYPE_UPDATED = "Le type d'utilisateur a été mis à jour avec succès"
			TXT_VIEW_EDIT_USER_TYPE = "Voir / Modifier un type d'utilisateur"
			TXT_VIEW_FEEDBACK = "Voir la rétroaction"
			TXT_VIEW_OFFLINE = "Vue des outils hors-ligne"
			TXT_WEB_DEVELOPER = "Concepteur / Développeur de site web"
			TXT_XML_SCHEMA = "Schéma XML"
	End Select
End Sub

Call setTxtUsers()
%>
