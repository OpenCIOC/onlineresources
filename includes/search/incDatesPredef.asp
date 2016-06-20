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
Dim dateToday, _
	dateTomorrow, _
	dateYesterday, _
	date7days, _
	date10days, _
	dateLastMonthFirst, _
	dateThisMonthFirst, _
	dateNextMonthFirst, _
	dateTwoMonthsFirst

dateToday = "CONVERT(varchar(12),GETDATE(),106)"
dateTomorrow = "DATEADD(d,1,CONVERT(varchar(12),GETDATE(),106))"
dateYesterday = "DATEADD(d,-1,CONVERT(varchar(12),GETDATE(),106))"
date7days = "DATEADD(d,-6,CONVERT(varchar(12),GETDATE(),106))"
date10days = "DATEADD(d,-9,CONVERT(varchar(12),GETDATE(),106))"
dateThisMonthFirst = "DATEADD(d,1-DAY(GETDATE()),CONVERT(varchar(12),GETDATE(),106))"
dateLastMonthFirst = "DATEADD(m,-1," & dateThisMonthFirst & ")"
dateNextMonthFirst = "DATEADD(m,1," & dateThisMonthFirst & ")"
dateTwoMonthsFirst = "DATEADD(m,2," & dateThisMonthFirst & ")"
%>
