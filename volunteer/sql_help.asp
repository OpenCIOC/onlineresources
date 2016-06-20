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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtHelp.asp" -->
<%
Call makePageHeader(TXT_SQL_HELP, TXT_SQL_HELP, False, False, False, False)
%>
<%
If g_objCurrentLang.Culture <> CULTURE_ENGLISH_CANADIAN Then
%>
<p><span class="AlertBubble"><%=TXT_NO_SQL_HELP%></span></p>
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
					<li><a href="#classification_systems">Searching Classification Systems (including Communities)</a></li>
					<li><a href="#checklists">Searching Checklists</a></li>
					<li><a href="#statistics">Searching Statistics</a></li>
					<li><a href="#feedback">Searching Feedback</a></li>
					<li><a href="#membership">Volunteer Centre Membership</a></li>
					<li><a href="#referrals">Referrals</a></li>
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
<p><strong>Records whose <em>&quot;Location&quot;</em> field is blank:</strong>
<br>
<code>vo.LOCATION IS NULL</code></p>
<p><strong>Records with the string &quot;child&quot; somewhere in the <em>&quot;Clients&quot;</em> field:</strong>
<br>
<code>vo.CLIENTS LIKE '%child%'</code></p>
<p><strong>Records with an &quot;Update Schedule&quot; date in the past:</strong>
<br>
<code>vod.UPDATE_SCHEDULE &lt; GETDATE()</code></p>
<p><strong>Records whose full-text index field &quot;Areas of Interest &quot; contains the keywords &quot;administration&quot; and &quot;animals&quot;:</strong>
<br>
<code>CONTAINS(vod.CMP_Interests,'administration and animals')</code></p>
<p>You can <strong>modify criteria</strong> and <strong>join muliple criteria</strong> together using boolean search words like <span class="style2">NOT</span>, <span class="HighLight"><strong>AND</strong></span>, <span class="HighLight"><strong>OR</strong></span>. You can enclose your search condition(s) in brackets (...) to clarify your meaning when using boolean search words: e.g.:</p>
<p><strong>Records whose <em>&quot;Location&quot;</em> field is null, but have either a mailing address or site address in the organization record:</strong>
<br>
<code>vo.LOCATION IS NULL <strong>AND NOT</strong> <strong>(</strong>btd.SITE_CITY IS NULL <strong>AND</strong> btd.MAIL_CITY IS NULL<strong>)</strong></code></p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="how_to_reference"></a>
<h2>How to reference key tables and fields</h2>
<p>In the sub-sections that follow you will find examples of how to access data in different tables. <em><strong>This is not a comprehensive list of all ways to access data through Add SQL</strong></em>. Note that the criteria given in each example must be modified to be criteria appropriate to the task you wish to accomplish; for consistency, most examples of search criteria provided here use the <a href="#comparison_between_in">&quot;=&quot; comparison search</a>, as described in the next section of this document, <a href="#examples">Example Searches</a>. <strong>You should substitute appropriate criteria for your task</strong>. <em>FIELD_NAME</em> is used in most cases to represent a random field within the selected table; in most cases you can click the &quot;Show&quot; button to view the full list of available fields for the corresponding table, and <strong>you can also use a current download file to determine the actual names of fields in each table</strong>.</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="base_tables"></a>
<h3>Searching CIOC Basic Tables (&quot;Base Tables&quot;)</h3>
<p>CIOC &quot;Base Tables&quot; store values that occur a single time for each record. GBL_BaseTable is the primary table for organizations, and is used by both the Community Information and Volunteer Opportunities module. VOL_Opportunity represents the primary table for the Volunteer software. The Community Information module also has CIC_BaseTable, for storing standard Community Information fields that are specific to Community Information I&amp;R, and CCR_BaseTable, for storing information about Child Care Resources; these tables are not  accessible by the Volunteer software. In addition, the Community Information module has &quot;Equivalents&quot; for each Base Table, representing the French data for the record (if available).</p>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th width="190" class="RevTitleBox">CIOC Table Name</th>
		<th class="RevTitleBox">Example access from Volunteer Search</th>
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
		<td class="FieldLabelLeft">VOL_Opportunity</td>
		<td><p><code>vo.<em>FIELD_NAME</em> = <em>'search_value'</em></code></p>
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
			<td>NUM_NEEDED_ANYWHERE</td>
			<td>number</td>
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
<h3>Searching Classification System Tables (including Communities)</h3>
<table class="BasicBorder cell-padding-2">
	<tr valign="top">
		<th width="190" class="RevTitleBox">CIOC Table Name</th>
		<th class="RevTitleBox">Example access from CIC Search</th>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">VOL_Interest</td>
		<td><code>EXISTS(SELECT * FROM VOL_OP_AI pr
		<br>INNER JOIN VOL_Interest ai<br>&nbsp;&nbsp;&nbsp;&nbsp; ON pr.AI_ID=ai.AI_ID<br>INNER JOIN 
		VOL_Interest_Name ain<br>&nbsp;&nbsp;&nbsp;&nbsp; ON ai.AI_ID=ain.AI_ID 
		AND ain.LangID=@@LANGID<br>WHERE pr.VNUM=vo.VNUM
		<br>&nbsp;&nbsp;&nbsp; &nbsp;AND ain.Name = <em>'search_value'</em>)</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">VOL_InterestGroup</td>
		<td><code>EXISTS(SELECT * FROM VOL_OP_AI pr
		<br>INNER JOIN VOL_Interest ai<br>&nbsp;&nbsp;&nbsp;&nbsp; ON pr.AI_ID=ai.AI_ID
		<br>INNER JOIN VOL_InterestGroup ig<br>&nbsp;&nbsp;&nbsp;&nbsp; ON ai.IG_ID=ig.IG_ID<br>
		INNER JOIN 
		VOL_InterestGroup_Name ign<br>&nbsp;&nbsp;&nbsp;&nbsp; ON ig.IG_ID=ign.IG_ID 
		AND ign.LangID=@@LANGID<br>WHERE pr.VNUM=vo.VNUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND ign.Name = <em>'search_value'</em>)</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">VOL_CommunitySet</td>
		<td><code>EXISTS(SELECT * FROM VOL_OP_CommunitySet pr
		<br>INNER JOIN VOL_CommunitySet cs
		<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.CommunitySetID=cs.CommunitySet_ID
		<br>WHERE pr.VNUM=vo.VNUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND cs.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code>
		<p><input type="button" onClick="if (document.getElementById('vo_communityset_fieldlist').style.display=='none') {document.getElementById('vol_communityset_fieldlist').style.display='inline'; this.value='Hide cs.FIELD_NAME list';} else {document.getElementById('vol_communityset_fieldlist').style.display='none'; this.value='Show cs.FIELD_NAME list';}" value="Show cs.FIELD_NAME list"></p>
		<div id="vol_communityset_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr>
			<td>AreaServed</td>
			<td>text</td>
		</tr>
		<tr>
			<td>CommunitySetID</td>
			<td>number</td>
		</tr>
		<tr>
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr>
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr>
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr>
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr>
			<td>SetName</td>
			<td>text</td>
		</tr>
		</table>
		</div></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">GBL_Community
		<br>("Number of Positions")</td>
		<td><code>EXISTS(SELECT * FROM VOL_OP_CM pr
		<br>INNER JOIN GBL_Community cm<br>&nbsp;&nbsp;&nbsp;&nbsp; ON pr.CM_ID=cm.CM_ID
		<br>INNER JOIN GBL_Community_Name cmn<br>&nbsp;&nbsp;&nbsp;&nbsp; ON 
		cmn.CM_ID=cmn.CM_ID<br>WHERE pr.VNUM=vo.VNUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND cmn.Name = <em>'search_value'</em>)
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND pr.NUM_NEEDED = <em>#</em>)</code></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">VOL_CommunityGroup
			<br>("Number of Positions")</td>
		<td><code>EXISTS(SELECT * FROM VOL_OP_CM pr
		<br>INNER JOIN GBL_Community cm
		<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.CM_ID=cm.CM_ID
		<br>INNER JOIN VOL_CommunityGroup_CM vcgc
		<br>&nbsp;&nbsp;&nbsp;&nbsp;ON vc.VOL_OP_CM=vcgc.CM_ID
		<br>INNER JOIN VOL_CommunityGroup vcg
		<br>&nbsp;&nbsp;&nbsp;&nbsp;ON vcgc.CommunityGroupID=vcgc.CommunityGroupID<br>WHERE pr.VNUM=vo.VNUM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND vcg.<em>FIELD_NAME</em> = <em>'search_value'</em>)
		<br>&nbsp;&nbsp;&nbsp;&nbsp;AND pr.<em>FIELD_NAME</em> = <em>#</em>)</code>
		<p><input type="button" onClick="if (document.getElementById('vol_communitygroup_fieldlist').style.display=='none') {document.getElementById('vol_communitygroup_fieldlist').style.display='inline'; this.value='Hide vcg.FIELD_NAME list';} else {document.getElementById('vol_communitygroup_fieldlist').style.display='none'; this.value='Show vcg.FIELD_NAME list';}" value="Show vcg.FIELD_NAME list"></p>
		<div id="vol_communitygroup_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr>
			<td>CommunitySetID</td>
			<td>number</td>
		</tr>
		<tr>
			<td>BallID</td>
			<td>number</td>
		</tr>
		<tr>
			<td>CommunityGroupID</td>
			<td>number</td>
		</tr>
		<tr>
			<td>CREATED_DATE</td>
			<td>date</td>
		</tr>
		<tr>
			<td>MODIFIED_DATE</td>
			<td>date</td>
		</tr>
		<tr>
			<td>CREATED_BY</td>
			<td>text</td>
		</tr>
		<tr>
			<td>MODIFIED_BY</td>
			<td>text</td>
		</tr>
		<tr>
			<td>CommunityGroupName</td>
			<td>text</td>
		</tr>
		<tr>
			<td>CommunityGroupNameEq</td>
			<td>text</td>
		</tr>
		<tr>
			<td>ImageURL</td>
			<td>text</td>
		</tr>
		</table>
		</div>
		<p><input type="button" onClick="if (document.getElementById('vol_op_cm2_fieldlist').style.display=='none') {document.getElementById('vol_op_cm2_fieldlist').style.display='inline'; this.value='Hide pr.FIELD_NAME list';} else {document.getElementById('vol_op_cm2_fieldlist').style.display='none'; this.value='Show pr.FIELD_NAME list';}" value="Show pr.FIELD_NAME list"></p>
		<div id="vol_op_cm2_fieldlist" style="display:none;"><table class="BasicBorder cell-padding-2">
		<tr valign="top">
			<th>Field Name</th>
			<th>Type</th>
		</tr>
		<tr>
			<td>NUM_NEEDED</td>
			<td>number</td>
		</tr>
		<tr>
			<td>OP_CM_ID</td>
			<td>number</td>
		</tr>
		<tr>
			<td>VNUM</td>
			<td>number</td>
		</tr>
		<tr>
			<td>CM_ID</td>
			<td>number</td>
		</tr>
		</table>
		</div>
		</td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="checklists"></a>
<h3>Searching Checklists</h3>
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
<br>WHERE vo.VNUM=pr.VNUM<br>&nbsp;&nbsp;&nbsp;&nbsp;AND frn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
<p><strong>2. Search within the notes for any checklist value</strong></p>
<p><code>EXISTS(SELECT * FROM <em>ChecklistJoinTable</em> pr
<br>INNER JOIN <em>ChecklistJoinTable_Notes</em> prn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.OP_<em>ChecklistID</em> = prn.OP_<em>ChecklistID</em>
AND prn.LangID=@@LANGID<br>WHERE vo.VNUM=pr.VNUM<br>&nbsp;&nbsp;&nbsp;&nbsp;AND prn.<em>FIELD_NAME</em> = <em>'search_value'</em>)</code></p>
<p><strong>3. Search within the notes connected to  a specific checklist value</strong></p>
<p><code>EXISTS(SELECT * FROM <em>ChecklistJoinTable</em> pr
<br>INNER JOIN <em>ChecklistJoinTable_Notes</em> prn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.OP_<em>ChecklistID</em> = prn.OP_<em>ChecklistID</em>
AND prn.LangID=@@LANGID<br>INNER JOIN <em>ChecklistTable</em> fr
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON pr.<em>ChecklistID</em> = fr.<em>ChecklistID</em>
<br>INNER JOIN <em>ChecklistTable_Name</em> frn
<br>&nbsp;&nbsp;&nbsp;&nbsp;ON fr.<em>ChecklistID</em> = frn.<em>ChecklistID</em> AND 
frn.LangID=@@LANGID
<br>WHERE vo.VNUM=pr.VNUM<br>&nbsp;&nbsp;&nbsp;&nbsp;AND frn.<em>FIELD_NAME</em> = <em>'search_value'</em>
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
		<td>VOL_OP_AC</td>
		<td>AC_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Commitment Length</td>
		<td>VOL_CommitmentLength</td>
		<td>VOL_OP_CL</td>
		<td>CL_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft" style="height: 32px">Interaction Level</td>
		<td style="height: 32px">VOL_InteractionLevel</td>
		<td style="height: 32px">VOL_OP_IL</td>
		<td style="height: 32px">IL_ID</td>
		<td style="height: 32px"><p>frn.Name
		<br>prn.Notes</p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Suitability</td>
		<td>VOL_Suitability</td>
		<td>VOL_OP_SB</td>
		<td>SB_ID</td>
		<td>frn.Name
		</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Seasons</td>
		<td>VOL_Seasons</td>
		<td>VOL_OP_SSN</td>
		<td>SSN_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Training</td>
		<td>VOL_Training</td>
		<td>VOL_OP_TRN</td>
		<td>TRN_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft">Transportation</td>
		<td>VOL_Transportation</td>
		<td>VOL_OP_TRP</td>
		<td>TRP_ID</td>
		<td>frn.Name
		<br>prn.Notes</td>
	</tr>
</table>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="statistics"></a>
<h3>Statistics</h3>
<p>Community Information module statistics can be found in the table <strong>VOL_Stats_OPID</strong>. This information is accessed through the record search using:</p>
<p><code>EXISTS(SELECT * FROM VOL_Stats_OPID st
<br>
WHERE vo.OP_ID=st.OP_ID<br>&nbsp;&nbsp;&nbsp;&nbsp;AND <strong>[criteria]</strong>)</code></p>
<p><strong>Records that have not been accessed this month</strong>:
<br><code>NOT EXISTS(SELECT * FROM VOL_Stats_OPID st
<br>
WHERE vo.OP_ID=st.OP_ID<br>&nbsp;&nbsp;&nbsp;&nbsp;AND MONTH(st.AccessDate) = MONTH(GETDATE())
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND YEAR(st.AccessDate) = YEAR(GETDATE())
<br>)</code></p>
<p><strong>Records that have had more than 10 hits today:</strong>
<br>
<code>EXISTS(SELECT COUNT(*) FROM VOL_Stats_OPID st
<br>
WHERE vo.OP_ID=st.OP_ID
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND FLOOR(CAST(st.AccessDate AS FLOAT)) = FLOOR(CAST(GETDATE() AS FLOAT))
<br>&nbsp;&nbsp;&nbsp;&nbsp;HAVING COUNT(*) &gt; 10)</code></p>
<p>Note that statistical searches are often very slow, because of the large amount of data being processed. In most cases, it is easier and more effective to search for records using CIOC's built-in statistical tool rather than to build statistical searching into your Add SQL statements. See the sections on <a href="#date_functions">date functions</a> and <a href="#aggregate_functions">aggregate functions</a> for more useful ways to use the information in the statistics table.</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="feedback"></a>
<h3>Feedback</h3>
<p>Community Information module feedback can be found in the table <strong>VOL_Feedback</strong><strong></strong>. This information is accessed through the record search using:</p>
<p><strong>Records that have feedback of any kind:</strong>
<br>
<code>EXISTS(SELECT * FROM VOL_Feedback fb
<br>
WHERE fb.VNUM=vo.VNUM)</code></p>
<p><strong>Accessing information in the VOL_Feedback table</strong>:
<br><code>EXISTS(SELECT * FROM VOL_Feedback fb
<br>WHERE fb.VNUM=vo.VNUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND <strong>[criteria]</strong>)</code></p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="membership"></a>
<h3>Volunteer Centre Membership</h3>
<p>[Information to be added at a later date]</p>
<p class="SmallNote">[ <a href="#top">Top of Page</a> ]</p>

<a name="referrals"></a>
<h3>Referrals</h3>
<p>[Information to be added at a later date]</p>
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
<p><code>CONTAINS(btd.SRCH_Anywhere,'child* AND &quot;after school&quot;')</code></p>
<p>Words or phrases that match can occur anywhere within the field(s) being searched (however, if searching across multiple fields, there must be a single field that matches the criteria, even if that is not the same field in each record). In general, you may use many of the same techniques (wildcards etc) as searching using keywords in the basic or advanced search, with the following exceptions:</p>
<ul>
	<li>All terms and phrases <em><strong>must</strong></em> be separated by <em>AND</em>, <em>OR</em>, <em>AND NOT</em>, or <em>OR NOT</em>.</li>
	<li>You may also use brackets to group different parts of your search. For example: <strong>(cats AND dog</strong><strong>s) OR (pigs AND cows) OR &quot;orange monkeys</strong>&quot;, or <strong>cross AND NOT red</strong>.</li>
	<li>Advanced users may also make use of the special SQL Server <span class="HighLight"><strong>FORMSOF</strong></span> function from within a Boolean search which allows you to search word forms. For example, FORMSOF(<span class="HighLight"><strong>INFLECTIONAL</strong></span>, run) would match all the different tenses of the word &quot;run&quot;: &quot;run&quot;, &quot;runs&quot;, &quot;running&quot;, and &quot;ran&quot;. Alternatively, FORMSOF(<span	class="HighLight"><strong>THESAURUS</strong></span>, happy) <span class="Alert">**</span> would match alternate meanings of the word &quot;happy&quot;, like: &quot;happy&quot;, &quot;cheerful&quot;, &quot;glad&quot;, etc. e.g. CONTAINS(btd.SRCH_Anywhere,'FORMSOF(THESAURUS, happy)')</li>
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
<br>
<code>(SELECT <strong>COUNT</strong>(*) FROM VOL_Stats_OPID st
<br>
WHERE st.OPID=vo.OPID) &gt; 10</code></p>
<p><strong>Records available during only one season from: Spring, Summer, Fall, Winter:</strong>
<br><code>EXISTS(SELECT * FROM VOL_OP_SSN pr
<br>INNER JOIN VOL_Season fr ON pr.SSN_ID=fr.SSN_ID<br>INNER JOIN VOL_Season_Name frn ON fr.SSN_ID=frn.SSN_ID AND frn.LangID=@@LANGID
<br>WHERE pr.VNUM=vo.VNUM
<br>&nbsp;&nbsp;&nbsp;&nbsp;AND frn.Name IN ('Spring','Summer','Fall','Winter')
<br><strong>HAVING</strong> <strong>COUNT</strong>(*) = 1)</code></p>
<p><strong>Records not accessed in the past 6 months:</strong>
<br>
<code>NOT EXISTS(SELECT * FROM VOL_Stats_OPID st WHERE st.OP_ID=vo.OP_ID)
<br>
OR EXISTS(SELECT * FROM VOL_Stats_OPID st WHERE st.OP_ID=vo.OP_ID
<br>&nbsp;&nbsp;&nbsp;&nbsp;<strong>HAVING</strong> <strong>MAX</strong>(st.AccessDate) &lt; DATEADD(mm,-6,GETDATE()))</code></p>
<p><strong>Records accessed an average of 50 or more times per month in the current year:</strong>
<br>
<code>EXISTS(SELECT * FROM
<br>
&nbsp;&nbsp;&nbsp;&nbsp;(SELECT COUNT(*) AS MonthCount
<br>
&nbsp;&nbsp;&nbsp;&nbsp;FROM VOL_Stats_OPID st
<br>
&nbsp;&nbsp;&nbsp;&nbsp;WHERE st.OP_ID=vo.OP_ID
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AND YEAR(AccessDate) = YEAR(GETDATE())
<br>
&nbsp;&nbsp;&nbsp;&nbsp;GROUP BY MONTH(AccessDate)) st2
<br>
<strong>HAVING</strong> <strong>AVG</strong>(MonthCount) &gt; 50)</code></p>
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
			<br>
			<code>vod.UPDATE_SCHEDULE&lt; <strong>GETDATE()</strong></code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">FLOOR(
		<br>&nbsp;&nbsp;&nbsp;&nbsp;CAST(</span><em>datevalue</em>&nbsp;<span class="HighLight">AS&nbsp;FLOAT)
		<br>)</span></strong></td>
		<td><p>Get the date portion of a date <strong>without the time</strong>. This is critical for some types of date comparisons; both GETDATE() and <em>most date fields in the software actually contain time information</em>, even though this is not often displayed to the end user. That means that '24-Mar-2008 3:00:00 PM' = '24-Mar-2008 3:01:00 PM' would not be true, because of the time difference.</p>
		<p><strong>Records last modified today:</strong>		
		<br>
		<code><strong>FLOOR(CAST(</strong>vod.MODIFIED_DATE <strong>AS&nbsp;FLOAT))</strong> = <strong>FLOOR(CAST(</strong>GETDATE() <strong>AS FLOAT))</strong></code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DAY</span>(<em>datevalue</em>)</strong></td>
		<td><p>Get the numeric day of the month value of the date. This function does not respect the month or year; therefore DAY('21-Mar-2008') is the same value as DAY('21-Jun-2009'). For that reason, this function has limited value outside statistical analysis.</p>
		<p><strong>Records accessed at least 50% more often in the second half of the month:</strong>				
		<br>
		<code>((SELECT COUNT(*) FROM VOL_Stats_OPID st
		<br>
		WHERE st.OP_ID=vo.OP_ID AND <strong>DAY</strong>(AccessDate) &gt; 15)
		<br>&gt;
		<br>
		(SELECT COUNT(*) AS DayCount FROM VOL_Stats_OPID st
		<br>
		WHERE st.OP_ID=vo.OP_ID AND <strong>DAY</strong>(AccessDate) &lt;= 15) * 1.5)</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">MONTH</span>(<em>datevalue</em>)</strong></td>
		<td><p>Get the numeric month value of the date (e.g. 1 = March). This function does not respect the year; therefore MONTH('21-Mar-2008') is the same value as MONTH('22-Mar-2009'). For that reason, you may need to use this function in combination with the YEAR function.</p>
		<p><strong>Records that are due to be updated in March:</strong>
		<br>
		<code><strong>MONTH</strong>(vod.UPDATE_SCHEDULE) = 3</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">YEAR</span>(<em>datevalue</em>)</strong></td>
		<td><p>Get the 4-digit year value of the date.</p>
		<p><strong>Records that were due to be updated in 2008 or earlier:</strong>
		<br>
		<code><strong>YEAR</strong>(vod.UPDATE_SCHEDULE) &lt;= 2008</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATEPART</span>(<em>?</em>, <em>datevalue</em>)</strong></td>
		<td><p>Return a portion of the date, determined by the value placed in the ? placeholder. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records most accessed more in the current month than any other month of the year:</strong>		
		<br><code>EXISTS(SELECT * FROM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;(SELECT TOP 1 MonthNumber FROM
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(SELECT COUNT(*) AS MonthCount, MONTH(AccessDate) AS MonthNumber
		<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FROM VOL_Stats_OPID st
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;WHERE st.OP_ID=vo.OP_ID
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
		<br>
		<code><strong>DATENAME</strong>(dw,vod.UPDATE_SCHEDULE) IN ('Saturday','Sunday')</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATEDIFF</span>(<em>?</em>,
		<br>&nbsp;&nbsp;&nbsp;&nbsp;<em>datevalue1</em>, <em>datevalue2</em>)</strong></td>
		<td><p>Returns the difference between two dates. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records that need to be updated within 1-6 months of their last update date:</strong>		
		<br>
		<code><strong>DATEDIFF</strong>(mm,vod.UPDATE_DATE,vod.UPDATE_SCHEDULE) BETWEEN 1 AND 6</code></p></td>
	</tr>
	<tr valign="top">
		<td class="FieldLabelLeft"><strong><span class="HighLight">DATEADD</span>(<em>?</em>,
		<br>&nbsp;&nbsp;&nbsp;&nbsp;<em>amount</em>, <em>datevalue</em>)</strong></td>
		<td><p>Adds <em>amount</em> to the given <em>datevalue</em> in the increments specified in <em>?</em>. Some possible values of ? include: <strong>yy</strong> (year), <strong>mm</strong> (month), <strong>dd</strong> (day of the month), <strong>dw</strong> (day of the week), <strong>dy</strong> (day of the year), <strong>qq</strong> (quarter), <strong>wk</strong> (week of the year), <strong>hh</strong> (hour of the day), <strong>mi</strong> (minutes of the hour), <strong>ss</strong> (seconds of the minute).</p>
		<p><strong>Records that are more than 6 months overdue:</strong>		
		<br>
		<code>vod.UPDATE_SCHEDULE &lt; <strong>DATEADD</strong>(mm,-6,GETDATE())</code></p></td>
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
<!--#include file="../includes/core/incClose.asp" -->
