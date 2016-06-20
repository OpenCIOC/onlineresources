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
%>

<% 'Base includes %>
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtHelp.asp" -->
<%
Call makePageHeader(TXT_SQL_HELP, TXT_SQL_HELP, False, False, False, False)
%>
<%
If g_objCurrentLang.Culture <> CULTURE_ENGLISH_CANADIAN Then
%>
<p class="Alert"><%=TXT_NO_SQL_HELP%></p>
<%
End If
%>
<h1><%=TXT_SQL_HELP%></h1>
<p>This <em>SQL Help</em> page outlines several techniques for constructing SQL statements for use in the <b>Add SQL</b> area of the Advanced Search form (and also for editing your Saved Searches). The ability to make use of SQL-based searches is determined by the <em>User Type</em> associated with your account, and most users will not have access to this feature - nor should they! The ability to directly query the database using SQL is a privilege that should only be granted to skilled, experienced users who understand that it should be used responsibly. The ability to use <em>Add SQL</em> should never be given to users who would otherwise have limitations on their ability to access the database. Those who have access to the Add SQL feature also have the ability to view and modify the SQL for their saved searches.</p>
<p><span class="HighLight"><strong>Please note</strong>: This is a long and detailed reference, and is not suitable for novice users</span>. Use the links below to skip to an appropriate section of the document:</p>
<ul>
	<li><a href="#what_can_i_do">What can I do with &quot;Add SQL&quot;?</a></li>
	<li>Constructing your search
		<ul>
			<li><a href="#search_conditions">About search conditions and joining criteria</a></li>
			<li><a href="#how_to_reference">How to reference key tables and fields</a>
				<ul>
					<li><a href="#base_tables">Searching CIOC Basic Tables (&quot;Base Tables&quot;)</a></li>
					<li><a href="#classification_systems">Searching Classification System Tables (including General Headings)</a></li>
					<li><a href="#drop_downs">Searching Drop-downs</a></li>
					<li><a href="#checklists">Searching Checklists (including Publications and Areas Served)</a></li>
					<li><a href="#statistics">Searching Statistics</a></li>
					<li><a href="#feedback">Searching Feedback</a></li>
				</ul>
			</li>
		</ul>
	</li>
	<li><a href="#examples">Example search criteria</a>
		<ul>
			<li><a href="#blank_not_blank">Search for fields that are blank or not blank</a></li>
			<li><a href="#like">Searching text fields using &quot;LIKE&quot;</a></li>
			<li><a href="#comparison_between_in">Searching using comparison operators, &quot;BETWEEN&quot;, and &quot;IN&quot;</a></li>
			<li><a href="#full_text">Searching full-text index fields using &quot;CONTAINS&quot; or &quot;FREETEXT&quot;</a></li>
			<li><a href="#boolean">Special note about searching boolean fields</a></li>
			<li><a href="#aggregate_functions">Using aggregate functions such as &quot;COUNT&quot;, &quot;SUM&quot;, &quot;AVG&quot;, &quot;MAX&quot;, &quot;MIN&quot;, etc</a></li>
			<li><a href="#date_functions">Using date functions such as &quot;GETDATE&quot;, &quot;DATEADD&quot;, &quot;DATEDIFF&quot;, &quot;MONTH&quot;, &quot;YEAR&quot;, etc</a></li>
			<li><a href="#saved_search">Using your <em>Saved Search</em> as a reference</a></li>
		</ul>
	</li>
	<li><a href="#expert">I'm practically an expert! Where can I find a more detailed reference?</a></li>
</ul>
<hr>
<a name="what_can_i_do"></a>
<h1>What can I do with &quot;Add SQL&quot;?</h1>
<p>When using regular search forms and links, the software translates the users' requests into SQL to retreive record results from the database. Add SQL allows the user to use this database language directly, making possible many types of searches that are not pre-configured in the software. With Add SQL, you can query information from any field or table in the database that contains record information...but you can also use as criteria several types of related information, including record view statistics and volunteer centre membership status.</p>
<hr>
<h1>Constructing your Search</h1>
<a name="search_conditions"></a>
<h2>About search conditions and joining criteria</h2>
<p>The part of the SQL statement that you will be writing is known as the <span class="HighLight"><strong>WHERE</strong></span> clause. It is the part of the statement that restricts which records are returned based on whether they match the criteria you provide. Your criteria (also called a <em>&quot;search condition&quot;</em>) is something that must be true in order for a record to be returned. Examples of some simple criteria would be:</p>
<p><strong>Records whose <em>&quot;Located In Community&quot;</em> field is blank:</strong>
<br><code>bt.LOCATED_IN_CM IS NULL</code></p>
<p><strong>Records with the string &quot;French&quot; somewhere in the <em>&quot;Languages&quot;</em> field:</strong>
<br><code>btd.CMP_Languages LIKE '%French%'</code></p>
<p><strong>Records with an &quot;Update Schedule&quot; date in the past:</strong>
<br><code>btd.UPDATE_SCHEDULE &lt; GETDATE()</code></p>
<p><strong>Records whose full-text index field &quot;Search Anywhere&quot; contains the keywords &quot;community&quot; and &quot;information&quot;:</strong>
<br><code>CONTAINS(btd.SRCH_Anywhere,'community and information')</code></p>
<p>You can <strong>modify criteria</strong> and <strong>join muliple criteria</strong> together using boolean search words like <span class="style2">NOT</span>, <span class="HighLight"><strong>AND</strong></span>, <span class="HighLight"><strong>OR</strong></span>. You can enclose your search condition(s) in brackets (...) to clarify your meaning when using boolean search words: e.g.:</p>
<p><strong>Records whose <em>&quot;Located In Community&quot;</em> field is null, but have either a mailing address or site address:</strong>
<br><code>bt.LOCATED_IN_CM IS NULL <strong>AND NOT</strong> <strong>(</strong>btd.SITE_CITY IS NULL <strong>AND</strong> btd.MAIL_CITY IS NULL<strong>)</strong></code></p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="how_to_reference"></a>
<h2>How to reference key tables and fields</h2>
<p>In the sub-sections that follow you will find examples of how to access data in different tables. <em><strong>This is not a comprehensive list of all ways to access data through Add SQL</strong></em>. Note that the criteria given in each example must be modified to be criteria appropriate to the task you wish to accomplish; for consistency, most examples of search criteria provided here use the <a href="#comparison_between_in">&quot;=&quot; comparison search</a>, as described in the next section of this document, <a href="#examples">Example Searches</a>. <strong>You should substitute appropriate criteria for your task</strong>. <em>FIELD_NAME</em> is used in most cases to represent a random field within the selected table; in most cases you can click the &quot;Show&quot; button to view the full list of available fields for the corresponding table, and <strong>you can also use a current download file to determine the actual names of fields in each table</strong>.</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="base_tables"></a>
<h3>Searching CIOC Basic Tables (&quot;Base Tables&quot;)</h3>
<p>CIOC &quot;Base Tables&quot; store values that occur a single time for each record. GBL_BaseTable is the primary table for organizations, and is used by both the Community Information and Volunteer Opportunities module. VOL_Opportunity represents the primary table for the Volunteer software. The Community Information module also has CIC_BaseTable, for storing standard Community Information fields that are specific to Community Information I&amp;R, and CCR_BaseTable, for storing information about Child Care Resources; these tables are not  accessible by the Volunteer software. In addition, the Community Information module has &quot;Equivalents&quot; for each Base Table, representing the French data for the record (if available).</p>
<table class="BasicBorder cell-padding-2" >
	<tr valign="top">
		<th width="190" class="RevTitleBox">CIOC Table Name</th>
		<th class="RevTitleBox">Example access from CIC Search</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">GBL_BaseTable</td>
		<td><code>bt.<em>FIELD_NAME</em> = <em>'search_value'</em></code>
		<p><input type="button" onClick="if (document.getElementById('gbl_basetable_fieldlist').style.display=='none') {document.getElementById('gbl_basetable_fieldlist').style.display='inline'; this.value='Hide bt.FIELD_NAME list';} else {document.getElementById('gbl_basetable_fieldlist').style.display='none'; this.value='Show bt.FIELD_NAME list';}" value="Show bt.FIELD_NAME list"></p>
		<div id="gbl_basetable_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>EMAIL_UPDATE_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>EMAIL_UPDATE_DATE_VOL</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>GEOCODE_TYPE</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>LATITUDE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LOCATED_IN_CM</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>LONGITUDE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MAIL_POSTAL_CODE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAP_PIN</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NO_UPDATE_EMAIL</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>PRIVACY_PROFILE</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>RECORD_OWNER</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>RSN</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>SITE_POSTAL_CODE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_EMAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_PASSWORD</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_PASSWORD_REQUIRED</td>
			<td>boolean</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">GBL_BaseTable_Description</td>
		<td><code>btd.<em>FIELD_NAME</em> = <em>'search_value'</em></code>
		<p><input type="button" onClick="if (document.getElementById('gbl_basetable_description_fieldlist').style.display=='none') {document.getElementById('gbl_basetable_description_fieldlist').style.display='inline'; this.value='Hide btd.FIELD_NAME list';} else {document.getElementById('gbl_basetable_description_fieldlist').style.display='none'; this.value='Show btd.FIELD_NAME list';}" value="Show btd.FIELD_NAME list"></p>
		<div id="gbl_basetable_description_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>ACCESSIBILITY_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>BTD_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>CMP_Accessibility</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_AltOrg</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_CrossRef</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_FormerOrg</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>COLLECTED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>COLLECTED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_EMAIL_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_EMAIL_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_FAX_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_FAX_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_NAME_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_NAME_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_ORG_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_ORG_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_PHONE_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_PHONE_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_TITLE_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_TITLE_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DELETION_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DESCRIPTION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>E_MAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ESTABLISHED</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_EMAIL_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_EMAIL_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_FAX_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_FAX_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_NAME_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_NAME_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_ORG_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_ORG_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_PHONE_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_PHONE_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_TITLE_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXEC_TITLE_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>FAX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>GEOCODE_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>IMPORT_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>LangID</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>LEGAL_ORG</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>LO_PUBLISH</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>MAIL_BOX_TYPE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_BUILDING</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_CARE_OF</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_CITY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_COUNTRY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_PO_BOX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_PROVINCE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_STREET</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_STREET_DIR</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_STREET_NUMBER</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_STREET_TYPE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAIL_SUFFIX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NON_PUBLIC</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>O2_PUBLISH</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>O3_PUBLISH</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>O4_PUBLISH</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>O5_PUBLISH</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>OFFICE_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ORG_LEVEL_1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ORG_LEVEL_2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ORG_LEVEL_3</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ORG_LEVEL_4</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ORG_LEVEL_5</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_BUILDING</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_CITY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_COUNTRY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_PROVINCE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_STREET</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_STREET_DIR</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_STREET_NUMBER</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_STREET_TYPE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_SUFFIX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SORT_AS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_ADDRESS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_BUILDING</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_CITY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_DB</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_EMAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_FAX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_NAME</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_ORG</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_POSTAL_CODE</td>
			<td>text</td>
		</tr>
		<tr valign="top">

			<td>SOURCE_PROVINCE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_TITLE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Anywhere</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Anywhere_U</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Org</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Org_U</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SUBMIT_CHANGES_TO</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TOLL_FREE_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_HISTORY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_SCHEDULE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>UPDATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VOLCONTACT_EMAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VOLCONTACT_FAX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VOLCONTACT_NAME</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VOLCONTACT_ORG</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VOLCONTACT_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VOLCONTACT_TITLE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>WWW_ADDRESS</td>
			<td>text</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">CIC_BaseTable</td>
		<td><code>cbt.<em>FIELD_NAME</em> = <em>'search_value'</em></code>
		<p><input type="button" onClick="if (document.getElementById('cic_basetable_fieldlist').style.display=='none') {document.getElementById('cic_basetable_fieldlist').style.display='inline'; this.value='Hide cbt.FIELD_NAME list';} else {document.getElementById('cic_basetable_fieldlist').style.display='none'; this.value='Show cbt.FIELD_NAME list';}" value="Show cbt.FIELD_NAME list"></p>
		<div id="cic_basetable_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DD_CODE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EMPLOYEES_FT</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>EMPLOYEES_PT</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>EMPLOYEES_RANGE</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EMPLOYEES_TOTAL</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_A</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_B</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_C</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_D</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_E</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_F</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_G</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_DROPDOWN_H</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_RADIO_A</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_RADIO_B</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_RADIO_C</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_RADIO_D</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_RADIO_E</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_RADIO_F</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>FEE_ASSISTANCE_AVAILABLE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>FISCAL_YEAR_END</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>MAX_AGE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MIN_AGE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>QUALITY</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>RECORD_TYPE</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>TAX_MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TAX_MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>WARD</td>
			<td>drop-down</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">CIC_BaseTable_Description</td>
		<td><code>cbtd.<em>FIELD_NAME</em> = <em>'search_value'</em></code>
		<p><input type="button" onClick="if (document.getElementById('cic_basetable_description_fieldlist').style.display=='none') {document.getElementById('cic_basetable_description_fieldlist').style.display='inline'; this.value='Hide cbtd.FIELD_NAME list';} else {document.getElementById('cic_basetable_description_fieldlist').style.display='none'; this.value='Show cbtd.FIELD_NAME list';}" value="Show cbtd.FIELD_NAME list"></p>
		<div id="cic_basetable_description_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>ACTIVITY_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>AFTER_HRS_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>APPLICATION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>AREAS_SERVED_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>BOUNDARIES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CBTD_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>CMP_AreasServed</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_Fees</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_Funding</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_Languages</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_NAICS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>COMMENTS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>CRISIS_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>DATES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>DD_CODE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ELECTIONS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ELIGIBILITY_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_B</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_C</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_D</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_E</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_F</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_G</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_H</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_NAME_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_EMAIL_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_FAX_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_NAME_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_ORG_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_PHONE_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_CONTACT_TITLE_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_EMAIL_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_WWW_A</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>FEE_ASSISTANCE_FOR</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>FEE_ASSISTANCE_FROM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>FEE_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>FUNDING_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>HOURS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>INTERSECTION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>LangID</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>LANGUAGE_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>LOGO_ADDRESS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>LOGO_ADDRESS_LINK</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MEETINGS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>PRINT_MATERIAL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>PUBLIC_COMMENTS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>RESOURCES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SITE_LOCATION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Subjects</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Subjects_U</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Taxonomy</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Taxonomy_U</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SUP_DESCRIPTION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TDD_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TRANSPORTATION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VACANCY_NOTES</td>
			<td>text</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">CCR_BaseTable</td>
		<td><code>ccbt.<em>FIELD_NAME</em> = <em>'search_value'</em></code>
		<p><input type="button" onClick="if (document.getElementById('ccr_basetable_fieldlist').style.display=='none') {document.getElementById('ccr_basetable_fieldlist').style.display='inline'; this.value='Hide ccbt.FIELD_NAME list';} else {document.getElementById('ccr_basetable_fieldlist').style.display='none'; this.value='Show ccbt.FIELD_NAME list';}" value="Show ccbt.FIELD_NAME list"></p>
		<div id="ccr_basetable_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>LC_INFANT</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LC_KINDERGARTEN</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LC_PRESCHOOL</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LC_SCHOOLAGE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LC_TODDLER</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LC_TOTAL</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>LICENSE_NUMBER</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>LICENSE_RENEWAL</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SPACE_AVAILABLE</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SPACE_AVAILABLE_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>SUBSIDY</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>TRANSPORTATION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TYPE_OF_PROGRAM</td>
			<td>drop-down</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">CCR_BaseTable_Description</td>
		<td><code>ccbtd.<em>FIELD_NAME</em> = <em>'search_value'</em></code>
		<p><input type="button" onClick="if (document.getElementById('ccr_basetable_description_fieldlist').style.display=='none') {document.getElementById('ccr_basetable_description_fieldlist').style.display='inline'; this.value='Hide ccbtd.FIELD_NAME list';} else {document.getElementById('ccr_basetable_description_fieldlist').style.display='none'; this.value='Show ccbtd.FIELD_NAME list';}" value="Show ccbtd.FIELD_NAME list"></p>
		<div id="ccr_basetable_description_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>BEST_TIME_TO_CALL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CCBTD_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>LangID</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>LC_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCHOOL_ESCORT_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCHOOLS_IN_AREA_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SPACE_AVAILABLE_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TYPE_OF_CARE_NOTES</td>
			<td>text</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">VOL_Opportunity</td>
		<td><p><code>EXISTS(SELECT * FROM VOL_Opportunity vo
		<br>WHERE bt.NUM=vo.NUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND vo.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
		<p><input type="button" onClick="if (document.getElementById('vol_opportunity_fieldlist').style.display=='none') {document.getElementById('vol_opportunity_fieldlist').style.display='inline'; this.value='Hide vo.FIELD_NAME list';} else {document.getElementById('vol_opportunity_fieldlist').style.display='none'; this.value='Show vo.FIELD_NAME list';}" value="Show vo.FIELD_NAME list"></p>
		<div id="vol_opportunity_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>ACCESSIBILITY_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>ADDITIONAL_REQUIREMENTS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>APPLICATION_DEADLINE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>BENEFITS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CLIENTS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CMP_Interests</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>COMMITMENT_LENGTH_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_EMAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_FAX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_NAME</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_ORG</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CONTACT_TITLE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>COST</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DELETION_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DISPLAY_UNTIL</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DUTIES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EMAIL_UPDATE_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>END_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>EXTRA</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>EXTRA_B</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>INTERACTION_LEVEL_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>LIABILITY_INSURANCE</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>LOCATION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MAX_AGE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MIN_AGE</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MINIMUM_HOURS</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MINIMUM_HOURS_PER</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>MORE_INFO_URL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>NO_UPDATE_EMAIL</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>NON_PUBLIC</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>NUM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>NUM_NEEDED_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>OP_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>OSSD</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>POLICE_CHECK</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>POSITION_TITLE</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>PROGRAM</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>PUBLIC_COMMENTS</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>RECORD_OWNER</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>REQUEST_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>SCH_F_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_F_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_F_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_F_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCH_M_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_M_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_M_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_M_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCH_SN_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_SN_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_SN_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_SN_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCH_ST_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_ST_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_ST_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_ST_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCH_TH_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_TH_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">

			<td>SCH_TH_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_TH_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCH_TU_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_TU_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_TU_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_TU_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCH_W_Afternoon</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_W_Evening</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_W_Morning</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>SCH_W_Time</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SCHEDULE_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SEASONS_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SKILL_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_EMAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_FAX</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_NAME</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_ORG</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_PHONE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_PUBLICATION</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_PUBLICATION_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>SOURCE_TITLE</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Anywhere</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>START_DATE_FIRST</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>START_DATE_LAST</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>TRAINING_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>TRANSPORTATION_NOTES</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_EMAIL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_HISTORY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>UPDATE_SCHEDULE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>UPDATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>VNUM</td>
			<td>text</td>
		</tr>
		</table>
		</div></td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="classification_systems"></a>
<h3>Searching Classification System Tables (including General Headings)</h3>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th width="190" class="RevTitleBox">CIOC Table Name</th>
		<th class="RevTitleBox">Example access from CIC Search</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">THS_Subject /
		<br>THS_Subject_Name</td>
		<td><code>EXISTS(SELECT * FROM CIC_BT_SBJ pr
		<br>INNER JOIN THS_Subject sj ON pr.Subj_ID=sj.Subj_ID
		<br>INNER JOIN THS_Subject_Name sjn ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@@LANGID
		<br>WHERE pr.NUM=bt.NUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND sjn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code>
		<p>(you may also use <code>sj.<em>FIELD_NAME</em> = <em>'search_value'</em></code>)</p>
		<p><input type="button" onClick="if (document.getElementById('ths_subject_fieldlist').style.display=='none') {document.getElementById('ths_subject_fieldlist').style.display='inline'; this.value='Hide sj.FIELD_NAME list';} else {document.getElementById('ths_subject_fieldlist').style.display='none'; this.value='Show sj.FIELD_NAME list';}" value="Show sj.FIELD_NAME list"></p>
		<div id="ths_subject_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>Authorized</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>Inactive</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>SRC_ID</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>Subj_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>SubjCat_ID</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>SubjGUID</td>
			<td>unique identifier</td>
		</tr>
		<tr valign="top">
			<td>UseAll</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>Used</td>
			<td>boolean</td>
		</tr>
		</table>
		</div>

		<p><input type="button" onClick="if (document.getElementById('ths_subject_name_fieldlist').style.display=='none') {document.getElementById('ths_subject_name_fieldlist').style.display='inline'; this.value='Hide sjn.FIELD_NAME list';} else {document.getElementById('ths_subject_name_fieldlist').style.display='none'; this.value='Show sjn.FIELD_NAME list';}" value="Show sjn.FIELD_NAME list"></p>
		<div id="ths_subject_name_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>Name</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>Notes</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>Subj_ID</td>
			<td>number</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">TAX_Term</td>
		<td><p><strong>To search by Code:</strong>
			<br><code>EXISTS(SELECT * FROM CIC_BT_TAX tl
			<br>INNER JOIN CIC_BT_TAX_TM tlt ON tl.BT_TAX_ID=tlt.BT_TAX_ID
			<br>WHERE tlt.NUM=bt.NUM
			<br>&nbsp;&nbsp;&nbsp;&nbsp;AND tlt.Code = <em>'search_value'</em>)</code></p>
			<p><strong>To search fields other than the Code:</strong>
			<br><code>EXISTS(SELECT * FROM CIC_BT_TAX tl
			<br>
			INNER JOIN CIC_BT_TAX_TM tlt ON tl.BT_TAX_ID=tlt.BT_TAX_ID
			<br>INNER JOIN TAX_Term tm ON tlt.Code=tm.Code
			<br>WHERE tlt.NUM=bt.NUM
			<br>&nbsp;&nbsp;&nbsp;&nbsp;AND tm.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
		<p><input type="button" onClick="if (document.getElementById('tax_term_fieldlist').style.display=='none') {document.getElementById('tax_term_fieldlist').style.display='inline'; this.value='Hide tm.FIELD_NAME list';} else {document.getElementById('tax_term_fieldlist').style.display='none'; this.value='Show tm.FIELD_NAME list';}" value="Show tm.FIELD_NAME list"></p>
		<div id="tax_term_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>Active</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>AltDefinition</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>AltDefinitionEq</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>AltTerm</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>AltTermEq</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>Authorized</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>BiblioRef</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>BiblioRefEq</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLocal</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLvl</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>CdLvl1</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLvl2</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLvl3</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLvl4</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLvl5</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CdLvl6</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>Code</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>Comments</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CommentsEq</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>Definition</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>DefinitionEq</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>Facet</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>IconURL</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>ParentCode</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>Source</td>
			<td>drop-down</td>
		</tr>
		<tr valign="top">
			<td>Term</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>TermEq</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>TM_ID</td>
			<td>number</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">NAICS</td>
		<td><p><strong>To search by Code:</strong>
		<br><code>EXISTS(SELECT * FROM CIC_BT_NC pr
		<br>WHERE pr.NUM=bt.NUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND pr.Code = <em>'search_value'</em>)</code></p>
		<p><strong>To search fields other than the Code:</strong>
		<br><code>EXISTS(SELECT * FROM CIC_BT_NC pr
		<br>INNER JOIN NAICS nc ON pr.Code=nc.Code
		<br>WHERE pr.NUM=bt.NUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND nc.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
		<p><input type="button" onClick="if (document.getElementById('naics_fieldlist').style.display=='none') {document.getElementById('naics_fieldlist').style.display='inline'; this.value='Hide nc.FIELD_NAME list';} else {document.getElementById('naics_fieldlist').style.display='none'; this.value='Show nc.FIELD_NAME list';}" value="Show nc.FIELD_NAME list"></p>
		<div id="naics_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>Classification</td>
			<td>full-text indexed</td>
		</tr>
		<tr valign="top">
			<td>CMP_Examples</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>Code</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CompMex</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>CompUS</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>Description</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>Parent</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SearchChildren</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>Source</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>SRCH_Anywhere</td>
			<td>full-text indexed</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">CIC_GeneralHeading</td>
		<td><p><strong>To search a Heading <em>regardless</em> of Publication:</strong>
		<br><code>EXISTS(SELECT * FROM CIC_BT_PB pbr
		<br>INNER JOIN CIC_BT_PB_GH ghr ON ghr.BT_PB_ID=pbr.BT_PB_ID
		<br>INNER JOIN CIC_GeneralHeading gh ON ghr.GH_ID=gh.GH_ID
		<br>INNER JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
		<br>WHERE pbr.NUM=bt.NUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND ghn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
		<p>(you may also use <code>gh.<em>FIELD_NAME</em> = <em>'search_value'</em></code>)</p>
		<p><strong>To search  a Heading in a <em>specific</em> Publication:</strong>
		<br><code>EXISTS(SELECT * FROM CIC_BT_PB pbr
		<br>INNER JOIN CIC_Publication pb ON pbr.PB_ID=pb.PB_ID
		<br>INNER JOIN CIC_BT_PB_GH ghr ON ghr.BT_PB_ID=pbr.BT_PB_ID
		<br>INNER JOIN CIC_GeneralHeading gh ON ghr.GH_ID=gh.GH_ID
		<br>INNER JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
		<br>WHERE pbr.NUM=bt.NUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND pb.<em>FIELD_NAME</em> = <em>'search_value'</em>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND ghn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
		<p>(you may also use <code>gh.<em>FIELD_NAME</em> = <em>'search_value'</em></code>)</p>
		<p><input type="button" onClick="if (document.getElementById('heading_fieldlist').style.display=='none') {document.getElementById('heading_fieldlist').style.display='inline'; this.value='Hide gh.FIELD_NAME list';} else {document.getElementById('heading_fieldlist').style.display='none'; this.value='Show gh.FIELD_NAME list';}" value="Show gh.FIELD_NAME list"></p>
		<div id="heading_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>GH_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>DisplayOrder</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>NonPublic</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>PB_ID</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>Used</td>
			<td>boolean</td>
		</tr>
		</table>
		</div>

		<p><input type="button" onClick="if (document.getElementById('heading_name_fieldlist').style.display=='none') {document.getElementById('heading_name_fieldlist').style.display='inline'; this.value='Hide ghn.FIELD_NAME list';} else {document.getElementById('heading_name_fieldlist').style.display='none'; this.value='Show ghn.FIELD_NAME list';}" value="Show ghn.FIELD_NAME list"></p>
		<div id="heading_name_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>GH_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>Name</td>
			<td>text</td>
		</tr>
		</table>
		</div>
		
		<p><input type="button" onClick="if (document.getElementById('publication_fieldlist').style.display=='none') {document.getElementById('publication_fieldlist').style.display='inline'; this.value='Hide pb.FIELD_NAME list';} else {document.getElementById('publication_fieldlist').style.display='none'; this.value='Show pb.FIELD_NAME list';}" value="Show pb.FIELD_NAME list"></p>
		<div id="publication_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr valign="top">
			<td>PB_ID</td>
			<td>number</td>
		</tr>
		<tr valign="top">
			<td>FieldHeadings</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>FieldHeadingsNP</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>FieldDesc</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>FieldHeadingGroups</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>FieldHeadingGroupsNP</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr valign="top">
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr valign="top">
			<td>NonPublic</td>
			<td>boolean</td>
		</tr>
		<tr valign="top">
			<td>PubCode</td>
			<td>text</td>
		</tr>
		</table>
		</div></td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="drop_downs"></a>
<h3>Searching Drop-Downs</h3>
<p>A <strong>drop-down</strong> allows you to add a <em>single value</em> from a pre-selected list to a record. The &quot;key&quot; identifying a drop-down value is stored 
in a <a href="#base_tables">Base Table</a>. If you know the key value of the drop-down field you want to search, you can search the value directly as specified in the section on <a href="#base_tables">Base Tables</a>. 
However in most cases, it may be difficult to determine the key without 
referencing the source table for the drop-down values.</p>

<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th width="190" class="RevTitleBox">Drop-Down</th>
		<th class="RevTitleBox">Example Access from CIC Search</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Drop-Down A</td>
		<td><code>EXISTS(SELECT * FROM CIC_ExtraDropDownA exda<br>INNER JOIN 
		CIC_ExtraDropDownA_Name exdan<br>&nbsp;&nbsp;&nbsp;&nbsp; ON 
		exda.EXDA_ID=exdan.EXDA_ID AND exdan.LangID=@@LANGID<br>WHERE exda.EXDA_ID=cbt.EXTRA_DROPDOWN_A
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND exdan.Name='<em>search_value</em>')</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Geocode Type</td>
		<td><code>EXISTS(SELECT * FROM GBL_GeoCodeType gt<br>INNER JOIN 
		GBL_GeoCodeType_Name gtn<br>&nbsp;&nbsp;&nbsp;&nbsp; ON gt.GCTypeID=gcn.GCTypeID 
		AND gtn.LangID=@@LANGID<br>WHERE gt.GCTypeID=bt.GEOCODE_TYPE
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND gt.GeoCodeType='<em>search_value</em>')</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Mapping Category</td>
		<td><code>EXISTS(SELECT * FROM GBL_MappingCategory mc<br>INNER JOIN 
		GBL_MappingCategory_Name mcn<br>&nbsp;&nbsp;&nbsp;&nbsp; ON mc.MapCatID=mcn.MapCatID 
		AND mcn.LangID=@@LANGID<br>WHERE mc.MapCatID=bt.MAP_PIN
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND mcn.Name='<em>search_value</em>')</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Record Quality</td>
		<td><code>EXISTS(SELECT * FROM CIC_Quality rq<br>WHERE rq.RQ_ID=cbt.QUALITY<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND 
		rq.Quality='<em>search_value</em>')</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Record Type</td>
		<td><code>EXISTS(SELECT * FROM CIC_RecordType rt<br>WHERE rt.RT_ID=cbt.RECORD_TYPE<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND 
		rt.RecordType='<em>search_value</em>')</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Type of Program</td>
		<td><code>EXISTS(SELECT * FROM CCR_TypeOfCare top<br>INNER JOIN 
		CCR_TypeOfCare_Name topn<br>&nbsp;&nbsp;&nbsp;&nbsp; ON top.TOP_ID=topn.TOP_ID 
		AND topn.LangID=@@LANGID<br>WHERE top.TOP_ID=ccbt.EXTRA_DROPDOWN_A
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND topn.Name='<em>search_value</em>')</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Ward</td>
		<td><code>EXISTS(SELECT * FROM CIC_Ward wd
		<br>WHERE wd.WD_ID=cbt.WARD
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND wd.WardNumber=<em>#</em>)</code></td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="checklists"></a>
<h3>Searching Checklists (including Publications and Areas Served)</h3>
<p>A <strong>checklist</strong> allows you  to add <em>multiple different values</em> to the same record. There are 3 ways to search against checklist data:</p>
<ol>
		<li>Search for a specific checklist value that has been added to the record</li>
		<li>Search within the notes for any checklist value *</li>
		<li>Search within the notes connected to  a specific checklist value</li>
</ol>
<p>* Note that general notes not tied to a specific checklist value are stored in the appropriate <a href="#base_tables">Base Table</a>.</p>
<p>Most checklist searches are constructed in the same fashion; this document will provide a template for each of the 3 searches mentioned above; use the template along with the table that follows that describes what to substitute into these templates in order to work with a specific checklist. ALT_ORG and FORMER_ORG searches are a special case, because they do not have a special checklist table. Values are stored the way &quot;notes&quot; are stored in other checklists.</p>
<p><strong>1. Search for a specific checklist value that has been added to the record</strong></p>
<p><code>EXISTS(SELECT * FROM <em>ChecklistJoinTable</em> pr
<br>INNER JOIN <em>ChecklistTable</em> fr
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.<em>ChecklistID</em> = fr.<em>ChecklistID</em>
<br>INNER JOIN <em>ChecklistTable_Name</em> frn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON fr.<em>ChecklistID</em> = frn.<em>ChecklistID</em> AND 
frn.LangID=@@LANGID
<br>WHERE bt.NUM=pr.NUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND frn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
<p><strong>2. Search within the notes for any checklist value</strong></p>
<p><code>EXISTS(SELECT * FROM <em>ChecklistJoinTable</em> pr
<br>INNER JOIN <em>ChecklistJoinTable_Notes</em> prn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.BT_<em>ChecklistID</em> = prn.BT_<em>ChecklistID</em>
AND prn.LangID=@@LANGID<br>WHERE bt.NUM=pr.NUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND prn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
<p><strong>3. Search within the notes connected to  a specific checklist value</strong></p>
<p><code>EXISTS(SELECT * FROM <em>ChecklistJoinTable</em> pr
<br>INNER JOIN <em>ChecklistJoinTable_Notes</em> prn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.BT_<em>ChecklistID</em> = prn.BT_<em>ChecklistID</em>
AND prn.LangID=@@LANGID<br>INNER JOIN <em>ChecklistTable</em> fr
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.<em>ChecklistID</em> = fr.<em>ChecklistID</em>
<br>INNER JOIN <em>ChecklistTable_Name</em> frn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON fr.<em>ChecklistID</em> = frn.<em>ChecklistID</em> AND 
frn.=@@LANGID
<br>WHERE bt.NUM=pr.NUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND frn.<em>FIELD_NAME</em> = <em>'search_value'</em>
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND prn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>

<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th class="RevTitleBox">Checklist</th>
		<th class="RevTitleBox"><em>ChecklistTable</em></th>
		<th class="RevTitleBox"><em>ChecklistJoinTable</em></th>
		<th class="RevTitleBox"><em>ChecklistID</em></th>
		<th class="RevTitleBox"><em>FIELD_NAME</em> options (not complete)</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Accessibility</td>
		<td>GBL_Accessibility</td>
		<td>GBL_BT_AC</td>
		<td>AC_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Alt. Org</td>
		<td>&nbsp;</td>
		<td>fr.GBL_BT_ALTORG</td>
		<td>&nbsp;</td>
		<td>fr.ALT_ORG
		<br>fr.PUBLISH&nbsp;*
		<br>fr.LangID&nbsp;**</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Bus Route</td>
		<td>CIC_BusRoute</td>
		<td>CIC_BT_BT</td>
		<td>BR_ID</td>
		<td>fr.RouteNumber
		<br>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Area Served</td>
		<td>GBL_Community</td>
		<td>CIC_BT_CM</td>
		<td>CM_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Distribution</td>
		<td>CIC_Distribution</td>
		<td>CIC_BT_DST</td>
		<td>DST_ID</td>
		<td>fr.DistCode
		<br>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Checklist A</td>
		<td>CIC_ExtraCheckListA</td>
		<td>CIC_BT_EXCA</td>
		<td>EXCA_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Checklist B</td>
		<td>CIC_ExtraCheckListB</td>
		<td>CIC_BT_EXCB</td>
		<td>EXCB_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Checklist C</td>
		<td>CIC_ExtraCheckListC</td>
		<td>CIC_BT_EXCC</td>
		<td>EXCC_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Checklist D</td>
		<td>CIC_ExtraCheckListD</td>
		<td>CIC_BT_EXCD</td>
		<td>EXCD_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Checklist E</td>
		<td>CIC_ExtraCheckListE</td>
		<td>CIC_BT_EXCE</td>
		<td>EXCE_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">&quot;Extra&quot; Checklist F</td>
		<td>CIC_ExtraCheckListF</td>
		<td>CIC_BT_EXCF</td>
		<td>EXCF_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Fees</td>
		<td>CIC_FeeType</td>
		<td>CIC_BT_FT</td>
		<td>FT_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Former Org.</td>
		<td>&nbsp;</td>
		<td>GBL_BT_FORMERORG</td>
		<td>&nbsp;</td>
		<td>fr.FORMER_ORG
		<br>fr.DATE_OF_CHANGE
		<br>fr.PUBLISH&nbsp;*
		<br>fr.LangID&nbsp;**</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Funding</td>
		<td>CIC_Funding</td>
		<td>CIC_BT_FD</td>
		<td>FD_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Language</td>
		<td>GBL_Language</td>
		<td>CIC_BT_LN</td>
		<td>LN_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Membership&nbsp;Type</td>
		<td>CIC_MembershipType</td>
		<td>CIC_BT_MT</td>
		<td>MT_ID</td>
		<td>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Publication</td>
		<td>CIC_Publication</td>
		<td>CIC_BT_PB</td>
		<td>PB_ID</td>
		<td>fr.PubCode
		<br>fr.NonPublic *
		<br>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">School</td>
		<td>CCR_School</td>
		<td>CCR_BT_SCH</td>
		<td>SCH_ID</td>
		<td>fr.SchoolBoard
		<br>frn.Name
		<br>pr.InArea *
		<br>pr.InAreaNotes
		<br>pr.Escort *
		<br>pr.EscortNotes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Service Level</td>
		<td>CIC_ServiceLevel</td>
		<td>CIC_BT_SL</td>
		<td>SL_ID</td>
		<td>fr.ServiceLevelCode
		<br>frn.Name</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Type of Care</td>
		<td>CCR_TypeOfCare</td>
		<td>CCR_BT_TOC</td>
		<td>TOC_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Vacancy (Service)</td>
		<td>CIC_Vacancy_UnitType</td>
		<td>CIC_BT_VUT</td>
		<td>VUT_ID</td>
		<td>frn.Name
		<br>pr.Capacity
		<br>pr.Vacancy
		<br>pr.WaitList *
		<br>pr.WaitListDate
		<br>prn.Notes
		<br>prn.ServiceTitle</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Vacancy (Target Population)</td>
		<td>CIC_Vacancy_TargetPop</td>
		<td>CIC_BT_VUT vut INNER JOIN CIC_BT_VUT_TP tp ON vut.BT_VUT_ID=tp.BT_VUT_ID</td>
		<td>VUT_ID</td>
		<td>frn.Name</td>
	</tr>
</table>
<p>* NonPublic, InArea, Escort, and WaitList are <a href="#boolean">boolean fields</a>.
<br>** LangID is a number representing a language selector: {0 = English, 2 = French}</p>

<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="statistics"></a>
<h3>Statistics</h3>
<p>Community Information module statistics can be found in the table <strong>CIC_Stats_RSN</strong>. This information is accessed through the record search using:</p>
<p><code>EXISTS(SELECT * FROM CIC_Stats_RSN st
<br>WHERE bt.RSN=st.RSN
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND <strong>[criteria]</strong>)</code></p>
<p><strong>Records that have not been accessed this month</strong>:
<br><code>NOT EXISTS(SELECT * FROM CIC_Stats_RSN st
<br>WHERE bt.RSN=st.RSN
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND MONTH(st.AccessDate) = MONTH(GETDATE())
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND YEAR(st.AccessDate) = YEAR(GETDATE())
<br>)</code></p>
<p><strong>Records that have had more than 10 hits today:</strong>
<br><code>EXISTS(SELECT COUNT(*) FROM CIC_Stats_RSN st
<br>WHERE bt.RSN=st.RSN
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND FLOOR(CAST(st.AccessDate AS FLOAT)) = FLOOR(CAST(GETDATE() AS FLOAT))
<br>&nbsp;&nbsp;&nbsp;&nbsp;HAVING COUNT(*) &gt; 10)</code></p>
<p>Note that statistical searches are often very slow, because of the large amount of data being processed. In most cases, it is easier and more effective to search for records using CIOC's built-in statistical tool rather than to build statistical searching into your Add SQL statements. See the sections on <a href="#date_functions">date functions</a> and <a href="#aggregate_functions">aggregate functions</a> for more useful ways to use the information in the statistics table.</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="feedback"></a>
<h3>Feedback</h3>
<p>Community Information module feedback can be found in the tables <strong>GBL_FeedbackEntry</strong>, <strong>GBL_Feedback</strong>, <strong>CIC_Feedback</strong>, <strong>CCR_Feedback</strong> and <strong>CIC_Feedback_Publication</strong>. This information is accessed through the record search using:</p>
<p><strong>Records that have feedback of any kind:</strong>
<br><code>EXISTS(SELECT * FROM GBL_FeedbackEntry fbe
<br>WHERE fbe.NUM=bt.NUM)</code></p>
<p><strong>Accessing information in the GBL_Feedback table</strong>:
<br><code>EXISTS(SELECT * FROM GBL_FeedbackEntry fbe
<br>&nbsp;&nbsp;&nbsp;&nbsp;INNER JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID
<br>WHERE fbe.NUM=bt.NUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND <strong>[criteria]</strong>)</code></p>
<p><strong>Records that have publication feedback:</strong>
<br><code>EXISTS(SELECT * FROM GBL_FeedbackEntry fbe
<br>&nbsp;&nbsp;&nbsp;&nbsp;INNER JOIN CIC_Feedback_Publication pfb ON fbe.FB_ID=pfb.FB_ID
<br>WHERE fbe.NUM=bt.NUM)</code></p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="examples"></a>
<hr>
<h2>Example Search Criteria</h2>
<p>Use the examples in this section to create criteria for use in various searches as described in <a href="#how_to_reference">How to reference key tables and fields</a></p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="blank_not_blank"></a>
<h3>Search for fields that are blank or not blank</h3>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th class="RevTitleBox">Example Search</th>
		<th class="RevTitleBox">Meaning</th>
	</tr>
	<tr valign="top">
		<td><em>table.FIELD_NAME</em> <strong>IS NOT NULL</strong></td>
		<td>value is not blank</td>
	</tr>
	<tr valign="top">
		<td><em>table.FIELD_NAME</em> <strong>IS NULL</strong></td>
		<td>has any non-blank value</td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="like"></a>
<h3>Searching text fields using &quot;LIKE&quot;</h3>
<p><span class="HighLight"><strong>LIKE</strong></span> searches compare a value (such as the data in a field) to a search pattern. In CIOC, LIKE searches are generally case and accent insensitve. LIKE searches are effective on regular text fields and also full-text indexed fields (which are also just text fields). The search pattern may include a number of wild card characters, including:</p>
<ul>
	<li><span class="HighLight"><strong>%</strong></span> - represents an unknown string of any value and length. Place this at the beginning, middle or end of your search pattern to indicate part of the value that can be ignored (e.g., 'cat%' will match <em>cats</em>, <em>catch</em>, <em>catasphrophic</em>, etc).</li>
	<li><span class="HighLight"><strong>_</strong></span> - represents a single character of any value.</li>
	<li><span class="HighLight">[ ]</span> - represents a single character provided in the list between the brackets; e.g. '[abcd]at' would match <em>bat</em> and <em>cat</em> but not <em>sat</em>. The list can be individual characters, a range of characters such as a-z, or both; e.g. [a,m-z].</li>
	<li><span class="HighLight">[^]</span> - represents a single character <strong>not</strong> in the list between the brackets; e.g. '[^abcd]at' would match <em>sat</em> and <em>hat</em> but not <em>cat</em>. The list can be individual characters, a range of characters such as a-z, or both; e.g. [^a,m-z].</li>
</ul>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th class="RevTitleBox">Example Search</th>
		<th class="RevTitleBox">Meaning</th>
	</tr>
	<tr valign="top">
		<td><em>table.FIELD_NAME</em> <strong>LIKE</strong> <em>'search pattern'</em></td>
		<td>equal to the given search pattern</td>
	</tr>
	<tr valign="top">
		<td><em>table.FIELD_NAME</em> <strong>NOT LIKE</strong> <em>'search pattern'</em></td>
		<td>is not equal to the given search pattern</td>
	</tr>
	<tr valign="top">
		<td><em>table.FIELD_NAME</em> <strong>LIKE</strong> <em>table.FIELD_NAME_2</em></td>
		<td>equal to the value of the given field</td>
	</tr>
	<tr valign="top">
		<td><em>table.FIELD_NAME</em> <strong>LIKE</strong> <em>table.FIELD_NAME_2 + 'search pattern'</em></td>
		<td>equal to  value of the given field joined with the given search pattern</td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="comparison_between_in"></a>
<h3>Searching using comparison operators, &quot;BETWEEN&quot;, and &quot;IN&quot;</h3>
<p>You can compare two fields, or a field and a value, using <strong>comparison operators</strong>; e.g.:</p>
<ul>
	<li><em>table.FIELD_NAME</em> <strong>=</strong> <em>table.FIELD_NAME_2</em></li>
	<li><em>table.FIELD_NAME = 'some text value'</em></li>
	<li><em>table.FIELD_NAME &gt; 1</em></li>
	<li><em>table.FIELD_NAME</em> != 0</li>
</ul>
<p>These operators are most commonly used with boolean, numeric, or data fields, but also work on text fields. The following are the available comparison operators:</p>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th class="RevTitleBox">Operator</th>
		<th class="RevTitleBox">Meaning</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>=</strong></span></td>
		<td>value one and value two are equal</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>!=</strong></span> OR <span class="HighLight"><strong>&lt;&gt;</strong></span></td>
		<td>value one and value two are not equal</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>&gt;</strong></span></td>
		<td>value one is greater than value two</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>&lt;</strong></span></td>
		<td>value one is less than value two</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>&gt;=</strong></span> OR <span class="HighLight"><strong>!&lt;</strong></span></td>
		<td>value one is greater than or equal to value two</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>&lt;=</strong></span> OR <span class="HighLight"><strong>!&gt;</strong></span></td>
		<td>value one is less than or equal to value two</td>
	</tr>
</table>
<p>The <span class="HighLight"><strong>BETWEEN</strong></span> operator allows you to indicate that a value must fall within a given range. This is equivalent to saying the value is <strong>greater than or equal to</strong>  the first comparison value <strong>and</strong> <strong>less than or equal to</strong> the second comparison value.  e.g.</p>
<ul>
	<li><code><em>table.FIELD_NAME</em> <strong>BETWEEN</strong> <em>table.FIELD_NAME_2</em> <strong>AND</strong> <em>table.FIELD_NAME_3</em></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>BETWEEN</strong> <em>1</em> <strong>AND</strong> <em>10</em></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>BETWEEN</strong> <em>'12-Mar-2004'</em> <strong>AND</strong> <em>'23-Apr-2005'</em></code></li>
	<li><code><em>'12-Mar-2004'</em> <strong>BETWEEN</strong> <em>table.FIELD_NAME</em> <strong>AND</strong> <em>table.FIELD_NAME_2</em></code></li>
</ul>
<p>The <span class="HighLight"><strong>IN</strong></span> operator allows you to indicate that the value must match a value from a given list. This is equivalent to saying that value is <strong>equal to</strong> the first comparions value, <strong>or equal to</strong> the second comparison value, <strong>or equal to</strong> the third comparison value, etc. e.g.</p>
<ul>
	<li><code><em>table.FIELD_NAME</em> <strong>IN</strong> (<em>table.FIELD_NAME_2,table.FIELD_NAME_3,table.FIELD_NAME_3</em>)</code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>IN</strong> (<em>0,1,2,3</em>)</code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>IN</strong> (<em>'apple','berry','cactus','daffodil'</em>)</code></li>
	<li><code><em>'search_value'</em> <strong>IN</strong> <em>(</em><em>table.FIELD_NAME_2</em><strong>,</strong><em>table.FIELD_NAME_3,table.FIELD_NAME_3</em>)</code></li>
</ul>
<p>Rather than providing a list of values, you can also use the <strong>IN</strong> operator along with a &quot;sub-query&quot; to return a list of values to match. e.g.</p>
<ul>
	<li><code><em>table.FIELD_NAME</em> <strong>IN</strong> (<em>SELECT table2.FIELD_NAME_2 FROM table2</em>)</code></li>
	<li><code><em>'search_value'</em>  <strong>IN</strong> (<em>SELECT table2.FIELD_NAME_2 FROM table2 WHERE table2.NUM=bt.NUM</em>)</code></li>
</ul>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="full_text"></a>
<h3>Searching full-text index fields using &quot;CONTAINS&quot; or &quot;FREETEXT&quot;</h3>
<p>The <span class="HighLight"><strong>CONTAINS</strong></span> predicate allows you to search full-text indexed fields using keywords and phrases. This is the type of search performed when doing a keyword search from the Basic or Advanced Search forms. For example, a search phrase from the Basic Search entered as [ child* &quot;after school&quot; ] in &quot;Keywords&quot; would be translated into:</p>
<p><code>CONTAINS(bt.SRCH_Anywhere,'child* AND &quot;after school&quot;')</code></p>
<p>Words or phrases that match can occur anywhere within the field(s) being searched (however, if searching across multiple fields, there must be a single field that matches the criteria, even if that is not the same field in each record). In general, you may use many of the same techniques (wildcards etc) as searching using keywords in the basic or advanced search, with the following exceptions:</p>
<ul>
	<li>All terms and phrases <em><strong>must</strong></em> be separated by <em>AND</em>, <em>OR</em>, <em>AND NOT</em>, or <em>OR NOT</em>.</li>
	<li>You may also use brackets to group different parts of your search. For example: <strong>(cats AND dog</strong><strong>s) OR (pigs AND cows) OR &quot;orange monkeys</strong>&quot;, or <strong>cross AND NOT red</strong>.</li>
	<li>Advanced users may also make use of the special SQL Server <span class="HighLight"><strong>FORMSOF</strong></span> function from within a Boolean search which allows you to search word forms. For example, FORMSOF(<span class="HighLight"><strong>INFLECTIONAL</strong></span>, run) would match all the different tenses of the word &quot;run&quot;: &quot;run&quot;, &quot;runs&quot;, &quot;running&quot;, and &quot;ran&quot;. Alternatively, FORMSOF(<span	class="HighLight"><strong>THESAURUS</strong></span>, happy) <span class="Alert">**</span> would match alternate meanings of the word &quot;happy&quot;, like: &quot;happy&quot;, &quot;cheerful&quot;, &quot;glad&quot;, etc. e.g. CONTAINS(bt.SRCH_Anywhere,'FORMSOF(THESAURUS, happy)')</li>
</ul>
<p>Using <span class="HighLight"><strong>FREETEXT</strong></span> instead of <strong>CONTAINS</strong> is like automatically including the <em>OR</em> connector between your terms and using the <em>FORMSOF</em> for all keywords. This search is simple, but often overly-generous. For example, the search:</p>
<p><code>FREETEXT(btd.SRCH_Org,'canada ontario')</code></p>
<p>...would match <em>'Canadian Food Inspection Agency'</em>, <em>'Citizenship &amp; Immigration Canada'</em>, and <em>'Green Party of Ontario'</em>.</p>
<p><span class="Alert">** Note</span>: the use of THESAURUS is dependent on creating a Thesaurus file for each language in SQL Server. Because CIOC has not currently created Thesaurus files for any language on its servers, this feature cannot be used effectively at this time.</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="boolean"></a>
<h3>Special note about searching boolean fields</h3>
<p>Boolean fields are those that have a yes/no value, represented in the database as <strong>1</strong> for <em>yes</em> and <strong>0</strong> for <em>no</em>. In some cases (but not all), boolean fields can also allow a third state of <em>unknown</em> or <em>no value</em> represented by <strong>NULL</strong>. Possible ways to search boolean fields include:</p>
<ul>
	<li><code><em>table.FIELD_NAME</em> <strong>= 1</strong></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>= 0</strong></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>= 'true'</strong></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>= 'false'</strong></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>IS NULL</strong></code></li>
	<li><code><em>table.FIELD_NAME</em> <strong>IS NOT NULL</strong></code></li>
</ul>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="aggregate_functions"></a>
<h3>Using aggregate functions such as &quot;COUNT&quot;, &quot;SUM&quot;, &quot;AVG&quot;, &quot;MAX&quot;, &quot;MIN&quot;, etc</h3>
<p>When working against tables that are related to the <a href="#base_tables">Base Tables</a>, you can use aggregate functions to analyze the related information as a set rather than by individual criteria. Related tables for which aggregate functions may be useful include the checklist, classification and statistics tables, among others. The following table outlines the syntax and use of several kinds of aggregate functions. For more information on aggregate functions, consult the SQL Server documentation as mentioned in the <a href="#expert">last section</a> of this document.</p>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th width="190" class="RevTitleBox">Function / Syntax</th>
		<th class="RevTitleBox">Purpose</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">COUNT</span>(?)</strong></td>
		<td>Count the number of <strong>non-null</strong> occurances of the value specified in the placeholder ?. Most often, a * is used, which will simply count the existance of the record regardless of the values in any field.</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">SUM</span>(?)</strong></td>
		<td>Numeric addition of the <strong>non-null</strong> occurances of the value specified in the placeholder ?. Only useful on numeric values.</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">AVG</span>(?)</strong></td>
		<td>Average of the <strong>non-null</strong> occurances of the value specified in the placeholder ?. Only useful on numeric or date values.</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">MIN</span>(?)</strong></td>
		<td>Minimum of the <strong>non-null</strong> occurances of the value specified in the placeholder ?.</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">MAX</span>(?)</strong></td>
		<td>Maximum of the <strong>non-null</strong> occurances of the value specified in the placeholder ?.</td>
	</tr>
</table>
<p>It is important to note that aggregate functions often make use of the <span class="style2">HAVING</span> search condition rather than the WHERE condition. Some practical examples using aggregate functions:</p>
<p><strong>Records with at least 10 views:</strong>
<br><code>(SELECT <strong>COUNT</strong>(*) FROM CIC_Stats_RSN st
<br>WHERE st.RSN=bt.RSN) &gt; 10</code></p>
<p><strong>Records with at least 2 different languages from: Spanish, Italian, Dutch, and German:</strong>
<br><code>EXISTS(SELECT * FROM CIC_BT_LN pr
<br>INNER JOIN GBL_Language fr ON pr.LN_ID=fr.LN_ID
<br>INNER JOIN GBL_Language_Name frn ON fr.LN_ID=frn.LN_ID
<br>WHERE pr.NUM=bt.NUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND frn.LanguageType IN ('Spanish','Italian','Dutch','German')
<br><strong>HAVING</strong> <strong>COUNT</strong>(*) &gt; 1)</code></p>
<p><strong>Records not accessed in the past 6 months:</strong>
<br><code>NOT EXISTS(SELECT * FROM CIC_Stats_RSN st WHERE st.RSN=bt.RSN)
<br>OR EXISTS(SELECT * FROM CIC_Stats_RSN st WHERE st.RSN=bt.RSN
<br>&nbsp;&nbsp;&nbsp;&nbsp;<strong>HAVING</strong> <strong>MAX</strong>(st.AccessDate) &lt; DATEADD(mm,-6,GETDATE()))</code></p>
<p><strong>Records having linked Taxonomy Terms with more than 2 links:</strong>
<br><code>EXISTS(SELECT * FROM CIC_BT_TAX tl
<br>WHERE tl.NUM=bt.NUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt
<br>&nbsp;&nbsp;&nbsp;&nbsp;WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID <strong>HAVING</strong> <strong>COUNT</strong>(*) &gt; 2)
<br>)</code></p>
<p><strong>Records accessed an average of 50 or more times per month in the current year:</strong>
<br><code>EXISTS(SELECT * FROM
<br>&nbsp;&nbsp;&nbsp;&nbsp;(SELECT COUNT(*) AS MonthCount
<br>&nbsp;&nbsp;&nbsp;&nbsp;FROM CIC_Stats_RSN st
<br>&nbsp;&nbsp;&nbsp;&nbsp;WHERE st.RSN=bt.RSN
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND YEAR(AccessDate) = YEAR(GETDATE())
<br>&nbsp;&nbsp;&nbsp;&nbsp;GROUP BY MONTH(AccessDate)) st2
<br><strong>HAVING</strong> <strong>AVG</strong>(MonthCount) &gt; 50)</code></p>

<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="date_functions"></a>
<h3>Using date functions such as &quot;GETDATE&quot;, &quot;DATEADD&quot;, &quot;DATEDIFF&quot;, &quot;MONTH&quot;, &quot;YEAR&quot;, etc</h3>
<p>Often, working with dates is as simple as using the  <a href="#comparison_between_in">comparison, &quot;BETWEEN&quot;, and &quot;IN&quot; operators</a> mentioned in a previous section. When more complicated queries are required, the functions in the following table are likely to come in handy. For more information on date functions, consult the SQL Server documentation as mentioned in the <a href="#expert">last section</a> of this document</p>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th width="190" class="RevTitleBox">Function / Syntax</th>
		<th class="RevTitleBox">Purpose</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><span class="HighLight"><strong>GETDATE()</strong></span></td>
		<td><p>Get the current date and time on the database server.</p>
			<p><strong>Records whose Update Schedule is in the past:</strong>			
			<br><code>btd.UPDATE_SCHEDULE&lt; <strong>GETDATE()</strong></code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">FLOOR(
		<br>&nbsp;&nbsp;&nbsp;&nbsp;CAST(</span><em>datevalue</em>&nbsp;<span class="HighLight">AS&nbsp;FLOAT)
		<br>)</span></strong></td>
		<td><p>Get the date portion of a date <strong>without the time</strong>. This is critical for some types of date comparisons; both GETDATE() and <em>most date fields in the software actually contain time information</em>, even though this is not often displayed to the end user. That means that '24-Mar-2008 3:00:00 PM' = '24-Mar-2008 3:01:00 PM' would not be true, because of the time difference.</p>
		<p><strong>Records last modified today:</strong>		
		<br><code><strong>FLOOR(CAST(</strong>btd.MODIFIED_DATE <strong>AS&nbsp;FLOAT))</strong> = <strong>FLOOR(CAST(</strong>GETDATE() <strong>AS FLOAT))</strong></code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DAY</span>(<em>datevalue</em>)</strong></td>
		<td><p>Get the numeric day of the month value of the date. This function does not respect the month or year; therefore DAY('21-Mar-2008') is the same value as DAY('21-Jun-2009'). For that reason, this function has limited value outside statistical analysis.</p>
		<p><strong>Records accessed at least 50% more often in the second half of the month:</strong>				
		<br><code>((SELECT COUNT(*) FROM CIC_Stats_RSN st
		<br>WHERE st.RSN=bt.RSN AND <strong>DAY</strong>(AccessDate) &gt; 15)
		<br>&gt;
		<br>(SELECT COUNT(*) AS DayCount FROM CIC_Stats_RSN st
		<br>WHERE st.RSN=bt.RSN AND <strong>DAY</strong>(AccessDate) &lt;= 15) * 1.5)</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">MONTH</span>(<em>datevalue</em>)</strong></td>
		<td><p>Get the numeric month value of the date (e.g. 1 = March). This function does not respect the year; therefore MONTH('21-Mar-2008') is the same value as MONTH('22-Mar-2009'). For that reason, you may need to use this function in combination with the YEAR function.</p>
		<p><strong>Records that are due to be updated in March:</strong>
		<br><code><strong>MONTH</strong>(btd.UPDATE_SCHEDULE) = 3</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">YEAR</span>(<em>datevalue</em>)</strong></td>
		<td><p>Get the 4-digit year value of the date.</p>
		<p><strong>Records that were due to be updated in 2008 or earlier:</strong>
		<br><code><strong>YEAR</strong>(btd.UPDATE_SCHEDULE) &lt;= 2008</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATEPART</span>(<em>?</em>, <em>datevalue</em>)</strong></td>
		<td><p>Return a portion of the date, determined by the value placed in the ? placeholder. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records most accessed more in the current month than any other month of the year:</strong>		
		<br><code>EXISTS(SELECT * FROM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;(SELECT TOP 1 MonthNumber FROM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(SELECT COUNT(*) AS MonthCount, MONTH(AccessDate) AS MonthNumber
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FROM CIC_Stats_RSN st
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;WHERE st.RSN=bt.RSN
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GROUP BY MONTH(AccessDate), YEAR(AccessDate)
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;) st2
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GROUP BY MonthNumber
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ORDER BY AVG(MonthCount) DESC
		<br>&nbsp;&nbsp;&nbsp;&nbsp;) st3
		<br>WHERE MonthNumber = <strong>DATEPART</strong>(mm,GETDATE()))</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATENAME</span>(<em>?</em>, <em>datevalue</em>)</strong></td>
		<td><p>Same as DATEPART, but returns the name (rather than number) of the part of the date. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records with an Update Schedule that falls on a weekend:</strong>		
		<br><code><strong>DATENAME</strong>(dw,btd.UPDATE_SCHEDULE) IN ('Saturday','Sunday')</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATEDIFF</span>(<em>?</em>,
		<br>&nbsp;&nbsp;&nbsp;&nbsp;<em>datevalue1</em>, <em>datevalue2</em>)</strong></td>
		<td><p>Returns the difference between two dates. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records that need to be updated within 1-6 months of their last update date:</strong>		
		<br><code><strong>DATEDIFF</strong>(mm,btd.UPDATE_DATE,btd.UPDATE_SCHEDULE) BETWEEN 1 AND 6</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATEADD</span>(<em>?</em>,
		<br>&nbsp;&nbsp;&nbsp;&nbsp;<em>amount</em>, <em>datevalue</em>)</strong></td>
		<td><p>Adds <em>amount</em> to the given <em>datevalue</em> in the increments specified in <em>?</em>. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records that are more than 6 months overdue:</strong>		
		<br><code>btd.UPDATE_SCHEDULE &lt; <strong>DATEADD</strong>(mm,-6,GETDATE())</code></p></td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="saved_search"></a>
<h3>Using your <em>Saved Search</em> as a reference</h3>
<p>If you are able to construct a similar search using pre-defined search options (such as through the Advanced Search page), you can save your search and go to the Saved Search management area to view and edit the SQL that created the search results. This is a good way to understand how the searches are constructed, and get access to working search criteria to modify for other uses.</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<hr>
<a name="expert"></a>
<h2>I'm practically an expert! Where can I find a more detailed reference?</h2>
<p>This document can't come close to telling you all the possibilities for searching. For more documentation, visit the <a href="http://msdn.microsoft.com/en-us/library/ms173545(SQL.90).aspx" target="_blank">Transact-SQL Reference for search conditions</a> that is part of Microsoft's <em>Books Online</em> for SQL Server 2005. You can browse documentation or download a copy for offline use.</p>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
