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
from win32com.server.util import wrap, unwrap
from cioc.core import constants as const
class dictwrapper(object):
	_public_methods_ = ['get', 'set', 'isvalid']

	def __init__(self, d):
		self.d = d


	def get(self, key, default=None):
		return self.d.get(key, default)

	def set(self, key, value):
		self.d[key] = value

	def isvalid(self):
		return not not self.d

def l_recent_search_store(db_area, sql, info, datetime, view_name, view_type, search_language, record_count):
	if db_area == const.DM_CIC:
		recentsearches = pyrequest.recentsearches.cic
	else:
		recentsearches = pyrequest.recentsearches.vol

	val = {'sql': sql, 'info': info, 'datetime': datetime, 'view_name': view_name, 'view_type': view_type, 'search_language': search_language, 'record_count': record_count}
	return recentsearches.add(val)

def recentSearchLoad(db_area, key):
	if db_area == const.DM_CIC:
		recentsearches = pyrequest.recentsearches.cic
	else:
		recentsearches = pyrequest.recentsearches.vol

	d = recentsearches.get(key)

	return wrap(dictwrapper(d))

</script>
<%

Function recentSearchStore(intDomain, strSQL, strInfo, strDate, strViewName, intViewType, strLanguage, intRecordCount)
	recentSearchStore = l_recent_search_store(intDomain, strSQL, strInfo, strDate, strViewName, intViewType, strLanguage, intRecordCount)
End Function

Dim strRecentSearchKey, _
	strLastSearchSessionTime, _
	strLastSearchSessionSQL, _
	strLastSearchSessionInfo, _
	aLastSearchSessionInfo, _
	bRecentSearchFound, _
	bCanRefineSearch

bRecentSearchFound = False
bCanRefineSearch = user_bLoggedIn

Sub InitializeRecentSearch()
	Dim objLastSearch

	If user_bLoggedIn Then
		strRecentSearchKey = Request("RS")

		If Nl(strRecentSearchKey) Then
			Exit Sub
		End If

		Set objLastSearch = recentSearchLoad(ps_intDbArea, strRecentSearchKey)
		If Not objLastSearch.isvalid() Then
			Exit Sub
		End If

		bRecentSearchFound = True

		strLastSearchSessionSQL = objLastSearch.get("sql")
		strLastSearchSessionTime = objLastSearch.get("datetime", TXT_UNKNOWN)
		strLastSearchSessionInfo = Nz(objLastSearch.get("info"),TXT_YOUR_PREVIOUS_SEARCH & " [" & strLastSearchSessionTime & "]")
		aLastSearchSessionInfo = Split(strLastSearchSessionInfo,"-{|}-")
	End If

End Sub

%>
