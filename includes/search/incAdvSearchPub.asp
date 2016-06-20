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
' Purpose: 
'
%>

<%
Dim strPublicationSearchUI, _
	strPublicationDropDown, _
	strGeneralHeadingUI, _
	bHavePublications, _
	bHaveGeneralHeadings, _
	bHavePubsWithGeneralHeadings
	
bHavePublications = False
bHavePubsWithGeneralHeadings = False
bHaveGeneralHeadings = False
strPublicationSearchUI = vbNullString
strPublicationDropDown = vbNullString
strGeneralHeadingUI = vbNullString

Sub getPublicationOptionList()

	bHavePublications = False
	bHavePubsWithGeneralHeadings = False
	strPublicationSearchUI = vbNullString
	strPublicationDropDown = vbNullString
	
	Call openPubListRst(False, False)
	With rsListPub
		If Not .EOF Then
			bHavePublications = True
			While Not .EOF
				strPublicationSearchUI = strPublicationSearchUI & vbCrLf & _
					"<option value=" & AttrQs(.Fields("PB_ID")) & ">" & Server.HTMLEncode(IIf(g_bUsePubNamesOnly,.Fields("PubName"),.Fields("PubCode"))) &"</option>"
				.MoveNext
			Wend
			
		End If
	End With
	Call closePubListRst()

	Call openPubListRst(True, Null)
	bHavePubsWithGeneralHeadings = Not rsListPub.EOF
	strPublicationDropDown = makePubList(vbNullString,vbNullString,"GHPBID",vbNullString,g_bCanSeeNonPublicPub,True,False)
	strPublicationDropDown = Replace(Replace(strPublicationDropDown, "<option value=""""> -- </option>", "<option value="""">" & TXT_PUBLICATIONS & "</option><optgroup label=""" & TXT_HEADINGS & """>"),"</select>","</optgroup></select>")
	Call closePubListRst()

End Sub

Sub getGeneralHeadingOptionList(intPBID)
	bHaveGeneralHeadings = False
	strGeneralHeadingUI = vbNullString
	Call openGenHeadingListRst(intPBID, Null, Nz(g_bCanSeeNonPublicPub,True), False)
	With rsListGenHeading
		If Not .EOF Then
			bHaveGeneralHeadings = True
			While Not .EOF
				strGeneralHeadingUI = strGeneralHeadingUI & vbCrLf & _
					"<option value=" & AttrQs(.Fields("GH_ID")) & ">" & Server.HTMLEncode(.Fields("GeneralHeading")) & "</option>"
				.MoveNext
			Wend
		End If
	End With
	Call closeGenHeadingListRst()
End Sub

Sub makePublicationUI()
	If bHavePubsWithGeneralHeadings Then
%>
		<%=strPublicationDropDown%><br>
<%
	End If
%>
	<div id="publication_search_selection">
	<span class="SmallNote"><%=TXT_HOLD_CTRL%></span>


		<span class="SmallNote"> & TXT_HOLD_CTRL & </span> 
		<div class="row"> 
			<div class="col-sm-6"> 
				<div class="panel"> 
					<div class="panel-body"><h4><%=TXT_INCLUDE_PUBLICATIONS%></h4> 
						<div class="radio"><label for="PBType_N"><input type="radio" name="PBType" id="PBType_N" value="N"> <%=TXT_HAS_NONE%></label></div> 
						<div class="radio"><label for="PBType_A"><input type="radio" name="PBType" id="PBType_A" value="A"> <%=TXT_HAS_ANY%></label></div> 
						<div class="radio"><label for="PBType_AF"><input type="radio" name="PBType" id="PBType_AF" value="AF" checked> <%=TXT_HAS_ALL_FROM%></label></div> 
						<div class="radio"><label for="PBType_F"><input type="radio" name="PBType" id="PBType_F" value="F" checked> <%=TXT_HAS_ANY_FROM%></label></div> 
						<select name="PBID" id="PBID" class="form-control"  multiple> 
							<%=strPublicationSearchUI%>
						</select> 
					</div> 
				</div> 
			</div> 
			<div class="col-sm-6"> 
				<div class="panel"> 
					<div class="panel-body"><h4><%=TXT_EXCLUDE_PUBLICATIONS%></h4> 
						<select name="PBIDx" id="PBIDx" class="form-control" multiple> 
							<%=strPublicationSearchUI%>
						</select> 
					</div> 
				</div> 
			</div> 
		</div>
	</div>
<%
	If bHavePubsWithGeneralHeadings Then
%>
	<div class="NotVisible" id="general_heading_search_selection">
<%
	Call makeGeneralHeadingUI()
%>
	</div>
<%
	End If
	
End Sub

Sub makeGeneralHeadingUI()
%>
	<span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
	<table class="NoBorder cell-padding-2"><tr>
		<td><table class="BasicBorder cell-padding-3">
			<tr><th class="FieldLabelCenterClr"><%=TXT_INCLUDE_HEADINGS%></th></tr>
			<tr><td><input type="radio" name="GHType" value="N"> <%=TXT_HAS_NONE%>
			<br><input type="radio" name="GHType" value="A"> <%=TXT_HAS_ANY%>
			<br><input type="radio" name="GHType" value="AF" checked> <%=TXT_HAS_ALL_FROM%>
			<br><input type="radio" name="GHType" value="F" checked> <%=TXT_HAS_ANY_FROM%>
			<br><div id="GHID_IE_Bugfix"><select name="GHID" id="GHID" multiple>
			<%=strGeneralHeadingUI%>
			</select></div></td></tr>
		</table></td>
		<td>&nbsp;&nbsp;</td>
		<td><table class="BasicBorder cell-padding-3">
			<tr><th class="FieldLabelCenterClr"><%=TXT_EXCLUDE_HEADINGS%></th></tr>
			<tr><td><div id="GHIDx_IE_Bugfix"><select name="GHIDx" id="GHIDx" multiple>
			<%=strGeneralHeadingUI%>
			</select></div></td></tr>
		</table></td>
	</tr></table>
<%
End Sub

%>
