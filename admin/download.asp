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
' Purpose:		List download page for the given module
'				(for links to database archive, resources, etc....)
'
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
<!--#include file="../text/txtDownload.asp" -->
<!--#include file="../includes/list/incDownloadURLList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<script language="python" runat="server">
import os, glob
from markupsafe import Markup

from cioc.core import constants as const
link_tmpl = Markup(u'''
<tr>
	<td><a href="%(link)s.zip">%(label)s</td>
	<td>&nbsp;</td>
</tr>
''')
dm_map = {const.DM_CIC: const.DM_S_CIC, const.DM_VOL: const.DM_S_VOL}
#<%= ps_strPathToStart & "downloads/" & strDBName & "Stats" & IIf(intDomain = DM_CIC, DM_S_CIC, DM_S_VOL)%>.zip
def generate_stats_links(domain, db_name, txt_download_stats):
	dirname = os.path.join(six.text_type(Request.ServerVariables('APPL_PHYSICAL_PATH')), 'download')
	dm = dm_map[domain]

	links = []
	fileprefix = db_name + 'Stats'
	for fullpath in glob.glob(os.path.join(dirname, fileprefix + '????' + dm + str(pyrequest.dboptions.MemberID) + '.zip')):
			filename = os.path.basename(fullpath)
			year = filename[len(fileprefix): len(fileprefix) + 4]
			linkname = fileprefix + year + dm 
			links.append(link_tmpl % {'link': pyrequest.passvars.makeLink('~/downloads/' + linkname), 'label': txt_download_stats + ' - ' + year })

	return ''.join(links)

</script>
<%
Dim intDomain, _
	strType

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			ps_strPathToStart, _
			vbNullString)
End Select
%>
<%
Call makePageHeader(TXT_DOWNLOAD & " (" & strType & ")", TXT_DOWNLOAD & " (" & strType & ")", True, False, True, True)

Call openDownloadURLListRst(intDomain)

Dim strDBName, aDirs
aDirs = Split(Request.ServerVariables("APPL_PHYSICAL_PATH"), "\")
strDBName = aDirs(UBound(aDirs)-1)

With rsListDownloadURL
	If Not .EOF Or Not Nl(strDBName) Then
%>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th class="RevTitleBox"><%=TXT_RESOURCE%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<% 
		If Not Nl(strDBName) Then 
%>
<tr>
	<td><a href="<%= ps_strPathToStart & "downloads/" & strDBName & IIf(intDomain = DM_CIC, DM_S_CIC, DM_S_VOL)%>.zip"><%= TXT_DOWNLOAD_RECORDS %></a></td>
	<td> </td>
</tr>
<%
		Response.Write(generate_stats_links(intDomain, strDBName, TXT_DOWNLOAD_STATS))
		End If

		Dim intPrevLang
		intPrevLang = g_objCurrentLang.LangID

		While Not .EOF
			If intPrevLang <> .Fields("LangID") And Not Nl(.Fields("LangID")) Then
%>
<tr>
	<th class="RevTitleBox"><%=TXT_RESOURCE%> - <%=.Fields("LanguageName")%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<%
				intPrevLang = .Fields("LangID")
			End If
%>
<tr>
	<td><a href="<%=.Fields("ResourceURL")%>"><%=.Fields("ResourceName")%></a></td>
	<td>
		<form action="download2.asp" method="post">
		<div style="display:none">
		<%=g_strCacheFormVals%>
		<input type="hidden" name="DM" value="<%=intDomain%>">
		<input type="hidden" name="URLID" value="<%=.Fields("URL_ID")%>">
		</div>
		<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
		</form>
	</td>
</tr>
<%
			.MoveNext
		Wend
%>
</table>
<%
	End If
End With
Call closeDownloadURLListRst()
%>
<br>
<form action="download2.asp" method="post">
<input type="hidden" name="DM" value="<%=intDomain%>">
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_ADD_NEW_RESOURCE%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="ResourceURL"><%=TXT_RESOURCE_URL%></labeL></td>
	<td><input type="text" size="<%=TEXT_SIZE%>" maxlength="150" name="ResourceURL" id="ResourceURL"></td>
</tr>
<%
	Dim strCulture
	For Each strCulture In active_cultures()
%>
<tr>
	<td class="FieldLabelLeft"><label for="ResourceName_<%=strCulture%>"><%=TXT_RESOURCE_NAME%><%If g_bMultiLingualActive Then%> (<%=Application("Culture_" & strCulture & "_LanguageName")%>)<%End If%></label></td>
	<td><input type="text" size="<%=TEXT_SIZE%>" maxlength="50" name="ResourceName_<%=strCulture%>" id="ResourceName_<%=strCulture%>"></td>
</tr>
<% 
	Next
%>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_ADD%>"></td>
</tr>
</table>
</form>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
