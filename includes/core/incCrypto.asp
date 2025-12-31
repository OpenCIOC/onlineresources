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
from cioc.core.security import getRandomString, getRandomPassword
from hashlib import md5

def py_hex_md5(to_hash):
	chrsz = 8
	mask = 0x000000FF
	return md5(bytes(ord(x) & mask for x in str(to_hash))).hexdigest()
</script>
<%
'**********************************************************
' Begin Function calcMD5Hash
'	Hash the string object strToHash
'***********************************************************
Function calcMD5Hash(strToHash)
	calcMD5Hash = py_hex_md5(strToHash)
End Function
'***************************************
' End Function calcMD5Hash
'***************************************
%>
