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
def cleanup_python():
	#if pyrequest.params.get('Profile', '') == 'Stop':
	#	import cioc.core.reloader as reloader
	#	reloader.stop_profiler()

	# moved to render_header in includes\core\incHeader
	for fn in pyrequest.finished_callbacks:
		fn(pyrequest)


	for key in 'session viewdata pageinfo config connmgr passvars'.split():
		try:
			delattr(pyrequest, key)
		except AttributeError:
			pass

</script>
<%


If IsObject(cnnAdminEn) Then
	If Not (cnnAdminEn Is Nothing) Then
		If (cnnAdminEn.State <> adStateClosed) Then
			cnnAdminEn.Close
		End If
	End If
End If
Set cnnAdminEn = Nothing

If IsObject(cnnAdminFr) Then
	If Not (cnnAdminFr Is Nothing) Then
		If (cnnAdminFr.State <> adStateClosed) Then
			cnnAdminFr.Close
		End If
	End If
End If
Set cnnAdminFr = Nothing

If IsObject(cnnCICEn) Then
	If Not (cnnCICEn Is Nothing) Then
		If (cnnCICEn.State <> adStateClosed) Then
			cnnCICEn.Close
		End If
	End If
End If
Set cnnCICEn = Nothing

If IsObject(cnnCICFr) Then
	If Not (cnnCICFr Is Nothing) Then
		If (cnnCICFr.State <> adStateClosed) Then
			cnnCICFr.Close
		End If
	End If
End If
Set cnnCICFr = Nothing

If IsObject(cnnVOLEn) Then
	If Not (cnnVOLEn Is Nothing) Then
		If (cnnVOLEn.State <> adStateClosed) Then
			cnnVOLEn.Close
		End If
	End If
End If
Set cnnVOLEn = Nothing

If IsObject(cnnVOLFr) Then
	If Not (cnnVOLFr Is Nothing) Then
		If (cnnVOLFr.State <> adStateClosed) Then
			cnnVOLFr.Close
		End If
	End If
End If
Set cnnVOLFr = Nothing

Call cleanup_python()
%>
