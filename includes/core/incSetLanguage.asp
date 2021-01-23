<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'	   http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<%

Dim g_aText
ReDim g_aText(-1)

Sub addTextFile(strTextFileName)
	Dim i, t
	i = UBound(g_aText)
	ReDim Preserve g_aText(i+1)
	g_aText(i+1) = strTextFileName
End Sub

Sub ReloadTextFiles()
	Dim indTextProc
	If IsArray(g_aText) Then
		For Each indTextProc In g_aText
			Execute("Call " & indTextProc & "()")
		Next
	End If
End Sub

%>

<!--#include file="incInitPython.asp"-->
<script language="python" runat="server">
# XXX this needs to be the first bit of python executed
if Application.Value("InitPython"):
	initialize_python(str(Request.ServerVariables('APPL_PHYSICAL_PATH')))
	Application.SetValue("InitPython", False)


#import cioc.core.reloader as reloader
#reloader.check_reloader()
#reloader.start_profiler()
import six

from win32com.server.util import wrap, unwrap
from cioc.core import syslanguage
from cioc.core.requestshim import RequestShim, ShimSystemLanguage


CULTURE_ENGLISH_CANADIAN = syslanguage.CULTURE_ENGLISH_CANADIAN
CULTURE_FRENCH_CANADIAN = syslanguage.CULTURE_FRENCH_CANADIAN
CULTURE_GERMAN = syslanguage.CULTURE_GERMAN
CULTURE_SPANISH = syslanguage.CULTURE_SPANISH
CULTURE_CHINESE_SIMPLIFIED = syslanguage.CULTURE_CHINESE_SIMPLIFIED

LCID_ENGLISH_CANADIAN = syslanguage.LCID_ENGLISH_CANADIAN
LCID_FRENCH_CANADIAN = syslanguage.LCID_FRENCH_CANADIAN

pyrequest = RequestShim(Request, Response)
pycurent_lang = pyrequest.language
g_objCurrentLang = wrap(pycurent_lang)

if not Application.Value('CulturesUpdated') or Application.Value('CulturesUpdated') != syslanguage._updated:
	Application.SetValue('CulturesUpdated', syslanguage._updated)
	Application.SetValue("Cultures",[x.Culture for x in syslanguage._culture_list])
	#Application.SetValue("DefaultCulture", dboptions.DefaultCulture)
	for desc in syslanguage._culture_list:
		Application.SetValue(u'LangID_' + six.text_type(desc.LangID), desc.Culture)
		for key,value in desc._asdict().items():
			if key == 'Culture':
				Application.SetValue("Culture_" + value, True)
			else:
				Application.SetValue("Culture_" + desc.Culture + "_" + key, value)
	

_last_culture = None
_reload_callback = None
def _do_language_change(new_culture_description):
	global _last_culture


	culture = new_culture_description.Culture
	if culture != _last_culture:
		_last_culture = culture

		_reload_callback()

	if Response.LCID != new_culture_description.LCID:
		Response.LCID = new_culture_description.LCID


def set_reload_callback(callback):
	global _reload_callback
	_reload_callback = callback

	return callback

def create_language_object():
	return wrap(ShimSystemLanguage(pyrequest))


active_cultures = syslanguage.active_cultures
active_record_cultures = syslanguage.active_record_cultures

pycurent_lang.addListener(_do_language_change)
</script>

<%
Sub setSessionLanguage(strCulture)
	'Need check here to confirm strCulture is an active culture; if not, substitute active culture
	If strCulture <> g_objCurrentLang.Culture Then
		g_objCurrentLang.setSystemLanguage(CStr(strCulture))
	End If

End Sub
Call set_reload_callback(GetRef("ReloadTextFiles"))
%>
