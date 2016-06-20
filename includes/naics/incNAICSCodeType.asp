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
Const NAICS_SECTOR = 2
Const NAICS_SUBSECTOR = 3
Const NAICS_INDUSTRY_GROUP = 4
Const NAICS_INDUSTRY = 5
Const NAICS_NATIONAL_INDUSTRY = 6

Function getCodeType(intCodeLength)
	Select Case intCodeLength
		Case NAICS_SECTOR
			getCodeType = TXT_SECTOR
		Case NAICS_SUBSECTOR
			getCodeType = TXT_SUBSECTOR
		Case NAICS_INDUSTRY_GROUP
			getCodeType = TXT_INDUSTRY_GROUP
		Case NAICS_INDUSTRY
			getCodeType = TXT_INDUSTRY
		Case NAICS_NATIONAL_INDUSTRY
			getCodeType = TXT_NATIONAL_INDUSTRY
	End Select
End Function
%>
