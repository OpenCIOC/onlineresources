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

<table class="BasicBorder cell-padding-2">
	<tr class="FieldLabelCenterClr">
		<td>&nbsp;</td>
		<td><%= TXT_TIME_MORNING %><br><%= TXT_TIME_BEFORE_12 %></td>
		<td><%= TXT_TIME_AFTERNOON %><br><%= TXT_TIME_12_6 %></td>
		<td><%= TXT_TIME_EVENING %><br><%= TXT_TIME_AFTER_6 %></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_MONDAY %></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_MONDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_M_Morning=<%=SQL_TRUE%>" type="checkbox"></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_MONDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_M_Afternoon=<%=SQL_TRUE%>" type="checkbox"></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_MONDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_M_Evening=<%=SQL_TRUE%>" type="checkbox"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_TUESDAY %></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_TUESDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_TU_Morning=<%=SQL_TRUE%>" type="checkbox"></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_TUESDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_TU_Afternoon=<%=SQL_TRUE%>" type="checkbox"></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_TUESDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_TU_Evening=<%=SQL_TRUE%>" type="checkbox"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_WEDNESDAY %></td>
		<td class="text-center"><input name="DateTime" title="<%=TXT_DAY_WEDNESDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_W_Morning=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_WEDNESDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_W_Afternoon=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_WEDNESDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_W_Evening=<%=SQL_TRUE%>" type="checkbox"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_THURSDAY %></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_THURSDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_TH_Morning=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_THURSDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_TH_Afternoon=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_THURSDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_TH_Evening=<%=SQL_TRUE%>" type="checkbox"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_FRIDAY %></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_FRIDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_F_Morning=<%=SQL_TRUE%>" type="checkbox" ></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_FRIDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_F_Afternoon=<%=SQL_TRUE%>" type="checkbox" ></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_FRIDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_F_Evening=<%=SQL_TRUE%>" type="checkbox" ></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_SATURDAY %></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_SATURDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_ST_Morning=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_SATURDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_ST_Afternoon=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_SATURDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_ST_Evening=<%=SQL_TRUE%>" type="checkbox"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%= TXT_DAY_SUNDAY %></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_SUNDAY & TXT_COLON & TXT_TIME_MORNING %>" value="SCH_SN_Morning=<%=SQL_TRUE%>" type="checkbox" ></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_SUNDAY & TXT_COLON & TXT_TIME_AFTERNOON %>" value="SCH_SN_Afternoon=<%=SQL_TRUE%>" type="checkbox"></td>
		<td  class="text-center"><input name="DateTime" title="<%=TXT_DAY_SUNDAY & TXT_COLON & TXT_TIME_EVENING %>" value="SCH_SN_Evening=<%=SQL_TRUE%>" type="checkbox"></td>
	</tr>
</table>
