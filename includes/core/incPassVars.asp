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
def updateCachedVars():
	global g_strCacheHTTPVals, g_strCacheFormVals
	g_strCacheHTTPVals = passvars.cached_url_vals
	g_strCacheFormVals = passvars.cached_form_vals

def _on_passvars_change(passvars):
	global g_intUseViewCIC, g_intUseViewVOL, g_strRequestLn, g_strDefaultCulture

	g_intUseViewCIC = passvars.UseViewCIC
	g_intUseViewVOL = passvars.UseViewVOL
	g_strRequestLn = passvars.RequestLn
	g_strDefaultCulture = passvars.DefaultCulture

	updateCachedVars()


def getHTTPVals(strExcludeKeys, bForm):
	# TODO remove when we can replace use in inTaxPassVars.asp
	return passvars.getHTTPVals([x.strip() for x in strExcludeKeys.split(',')], bForm)


def makeDetailsLink(strNUM, strHTTPVals, strExcludeKeys):
	return passvars.makeDetailsLink(strNUM, strHTTPVals, strExcludeKeys)

def makeVOLDetailsLink(strVNUM, strHTTPVals, strExcludeKeys):
	return passvars.makeVOLDetailsLink(strVNUM, strHTTPVals, strExcludeKeys)

def makeLink(strToURL, strHTTPVals, strExcludeKeys):
	return passvars.makeLink(strToURL, strHTTPVals, strExcludeKeys)

def makeLinkB(strToURL):
	if strToURL is None:
		return ''
	return passvars.makeLink(strToURL)

def makeLinkAdmin(strToURL, strHTTPVals):
	return passvars.makeLinkAdmin(strToURL, strHTTPVals)

def initializeCachedVars():
	# XXX Is this used?
	passvars.initialize()

def initialize_pass_vars():
	global passvars, strRecordRoot

	passvars = pyrequest.passvars
	strRecordRoot = passvars.record_root

	passvars.addListener(_on_passvars_change)

	#initialize values
	_on_passvars_change(passvars)

def initialize_session():
	session = pyrequest.session

def l_set_session_value(key, value):
	#Response.Write("SET: %s, %s<br>" %(key, repr(value)))
	pyrequest.session[str(key)] = value

def l_get_session_value(key):
	try:
		value = pyrequest.session[str(key)]
		#Response.Write("GET: %s, %s<br>" %(key, repr(value)))
		if isinstance(value, tuple) and not len(value):
			return None
		return value
	except KeyError:
		return None

def finalize_session():
	pyrequest.session.save()

def run_response_callbacks():
	for fn in pyrequest.response_callbacks:
		fn(pyrequest, pyrequest.response)
	pyrequest.response_callbacks = []

</script>
<%

Sub setSessionValue(strKey, objVal)
	Dim tmp
	tmp = l_set_session_value(strKey, objVal)

End Sub

Function getSessionValue(strKey)
	getSessionValue = l_get_session_value(strKey)
End Function

Sub goToDetailsPage(strNUM,strPassVars,strExcludeKeys)
	Dim strLink
	strLink =  makeDetailsLink(strNUM, strPassVars, strExcludeKeys)

	Call run_response_callbacks()
%>
<!--#include file="incClose.asp" -->
<%
	Response.Redirect(strLink)
End Sub

Sub goToPage(strToURL,strPassVars,strExcludeKeys)
	Dim strLink
	strLink = makeLink(strToURL,strPassVars,strExcludeKeys)

	Call run_response_callbacks()
%>
<!--#include file="incClose.asp" -->
<%
	Response.Redirect(strLink)
End Sub

Sub goToPageB(strToURL)
	Call goToPage(strTOURL,vbNullString,vbNullString)
End Sub

Call initialize_pass_vars()
Call initialize_session()
%>

