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
Dim	strIDList, _
	strActionType, _
	strCType, _
	intID, _
	intSynchID, _
	intPBID, _
	intIGID, _
	strHistoryProcName, _
	bError

strCType = Request("CType")
strActionType = Request("ActionType")
strIDList = Replace(Request("IDList")," ",vbNullString)
intID = Request("ActionID")
If strCType="GH" And Not user_bLimitedViewCIC Then
	intSynchID = Request("SynchID")
	If Not IsIDType(intSynchID) Then
		intSynchID = Null
	End If
End If

Select Case ps_intDbArea
	Case DM_CIC
		If Not (user_bCanDoBulkOpsCIC Or (user_bLimitedViewCIC And user_intCanUpdatePubs <> UPDATE_NONE And strCType="GH")) Then
			Call securityFailure()
		End If
		intPBID = Request("PBID")
		strHistoryProcName = "dbo.sp_GBL_BaseTable_History_i_Field"
	Case DM_VOL
		If Not user_bCanDoBulkOpsVOL Then
			Call securityFailure()
		End If
		intIGID = Request("IGID")
		strHistoryProcName = "dbo.sp_VOL_Opportunity_History_i_Field"
	Case Else
		Call securityFailure()
End Select

Dim cmdHistory
Set cmdHistory = Server.CreateObject("ADODB.Command")
		
With cmdHistory
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strHistoryProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDBTimeStamp, adParamInput, , Now())
	.Parameters.Append .CreateParameter("@IDList", adLongVarChar, adParamInput, -1, strIDList)
	.Parameters.Append .CreateParameter("@FieldName", adLongVarChar, adParamInput, -1)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
	.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
End With

Call makePageHeader(TXT_ADD_REMOVE, TXT_ADD_REMOVE, True, True, True, True)

If Nl(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf ps_intDbArea = DM_VOL And Not IsVNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf ps_intDbArea = DM_CIC And Not IsNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf Nl(intID) And Nl(intSynchID) And strActionType<>"DXXX" Then
	bError = True
	Call handleError(TXT_NO_CODE_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf Not ( _
		(IsIDList(intID) And (strCType <> "SBJ" Or IsIDType(intID))) _
		Or reEquals(strCType,"(TX)|(NC)",True,False,False,False) _
		Or Not Nl(intSynchID) Or strActionType="DXXX" _
		) Then
	bError = True
	Call handleError(TXT_INVALID_CODE & intID, _
	vbNullString, _
	vbNullString)
ElseIf strCType="NC" And Not (IsNAICSType(intID) Or strActionType="DXXX") Then
	bError = True
	Call handleError(TXT_INVALID_CODE & intID, _
	vbNullString, _
	vbNullString)
ElseIf strCType="TX" And Not (IsLinkedTaxCodeList(intID) Or strActionType="DXXX") Then
	bError = True
	Call handleError(TXT_INVALID_CODE & intID, _
	vbNullString, _
	vbNullString)
ElseIf strCType="GH" And (Nl(intPBID) Or Not IsIDType(intPBID)) Then
	bError = True
	Call handleError(TXT_NO_CODE_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf strActionType="DXXX" And Not Request("Confirmed")="on" Then
	bError = True
	Call handleError(TXT_NO_DELETE_CONFIRMATION, _
		vbNullString, _
		vbNullString)
End If

'For NAICS and Taxonomy, where the user manually inputs the Code,
'look up the name of the given Code and validate that it exists and is Active.
If Not bError And (strCType = "NC" Or strCType = "TX") And strActionType<>"DXXX" Then
	Dim aCode, _
		indCode, _
		strCode, _
		strQCode, _
		strCodeCon, _
		strCodeName, _
		strSelectFrom, _
		cmdCodeLookup, _
		rsCodeLookup

	'NAICS Code
	If strCType="NC" Then
		strCode = intID
		strQCode = Qs(strCode,SQUOTE)
		strCodeName = "Classification"
		strSelectFrom = "NAICS ct " & _
			" INNER JOIN NAICS_Description ctd " & _
			"	ON ct.Code=ctd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ctd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"

	'Taxonomy Code
	Else
		strCode = Replace(Replace(UCase(intID),",","~")," ",vbNullString)
		aCode = Split(strCode,"~")
		If Not IsArray(aCode) Then
			ReDim aCode(-1)
			strQCode = NULL
		Else
			strQCode = SQUOTE & Join(aCode,"','") & SQUOTE
		End If
		strCodeName = "ISNULL(AltTerm,Term)"
		strSelectFrom = "TAX_Term ct " & _
			" INNER JOIN TAX_Term_Description ctd " & _
			"	ON ct.Code=ctd.Code AND LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE ctd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) "
	End If

	'SQL to retrieve Classification information for the Code
	strSelectFrom = "SELECT CASE WHEN ctd.LangID=@@LANGID THEN " & strCodeName & _
			" ELSE '[' + " & strCodeName & " + ']' END " & _
			" AS CodeName" & _
			IIf(strCType = "TX",", Active, ct.Code",vbNullString) & _
			" FROM " & strSelectFrom & _
			" WHERE ct.Code IN (" & strQCode & ")"
	
	'Retrieve Classification information
	Set cmdCodeLookup = Server.CreateObject("ADODB.Command")
	With cmdCodeLookup
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandText = strSelectFrom
		.CommandTimeout = 0
	End With
	Set rsCodeLookup = Server.CreateObject("ADODB.Recordset")
	With rsCodeLookup
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdCodeLookup
		'If the Code was a valid entry
		If Not .EOF Then
			If strCType = "TX" Then
				If (UBound(aCode) + 1) > .RecordCount Then
					bError = True
					Call handleError(TXT_INVALID_CODE & intID, _
						vbNullString, _
						vbNullString)
				End If
				strCodeName = vbNullString
				While Not .EOF
					'If the Code is Inactive, print an error
					If Not .Fields("Active") Then
						bError = True
						Call handleError(TXT_INACTIVE_CODE & strCode & " (" & strCodeName & ")", _
							vbNullString, _
							vbNullString)
					Else
						strCodeName = StringIf(Not Nl(strCodeName),strCodeName & " ~ ") & .Fields("Code") & " (" & .Fields("CodeName") & ")"
					End If
					.MoveNext
				Wend
			Else
				strCodeName = .Fields("CodeName")
			End If
		'The Code is not valid, print an error
		Else
			bError = True
			Call handleError(TXT_INVALID_CODE & intID, _
				vbNullString, _
				vbNullString)
		End If
	End With
End If

If Not bError Then

	Dim strUserInsert
	strUserInsert = QsN(user_strMod)

	Dim cmdAddRemove, _
		rsAddRemove, _
		intNumAffected
	
	Dim strBasicNUMSQL, _
		strBasicVNUMSQL, _
		strBasicModSQL, _
		strPubModSQL, _
		strBasicCICCheckSQL, _
		strBasicCCRCheckSQL

	If ps_intDbArea = DM_VOL Then
		strBasicVNUMSQL = "SET NOCOUNT ON" & vbCrLf & _
					"DECLARE @tmpVNUMs TABLE(VNUM varchar(10) PRIMARY KEY NOT NULL)" & vbCrLf & _
					"DECLARE @AffectedVNUMs TABLE(VNUM varchar(10) NOT NULL)" & vbCrLf & _
					"INSERT INTO @tmpVNUMs SELECT DISTINCT tm.*" & vbCrLf & _
					"	FROM dbo.fn_GBL_ParseVarCharIDList(" & QsNl(strIDList) & ",',') tm" & vbCrLf & _
					"	INNER JOIN VOL_Opportunity vo ON tm.ItemID=vo.VNUM COLLATE Latin1_General_100_CI_AI" & vbCrLf & _
					"	WHERE dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) <> 0" & vbCrLf & _
					"SET NOCOUNT OFF"

		strBasicModSQL = "SET NOCOUNT ON" & vbCrLf & _
						"UPDATE vod SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert & " FROM VOL_Opportunity_Description vod INNER JOIN @AffectedVNUMs tm ON vod.VNUM=tm.VNUM" & vbCrLf & _
						"SET NOCOUNT OFF"
	End If

	If ps_intDbArea = DM_CIC And (strCType <> "GH" Or Nl(intSynchID)) Then
		strBasicNUMSQL = "SET NOCOUNT ON" & vbCrLf & _
						"DECLARE @tmpNUMs TABLE(NUM varchar(8) COLLATE Latin1_General_100_CI_AI PRIMARY KEY NOT NULL)" & vbCrLf & _
						"DECLARE @AffectedNUMs TABLE(NUM varchar(8) COLLATE Latin1_General_100_CI_AI NOT NULL)" & vbCrLf & _
						"INSERT INTO @tmpNUMs SELECT DISTINCT tm.*" & vbCrLf & _
						"	FROM dbo.fn_GBL_ParseVarCharIDList(" & QsNl(strIDList) & ",',') tm" & vbCrLf & _
						"	INNER JOIN GBL_BaseTable bt ON tm.ItemID = bt.NUM COLLATE Latin1_General_100_CI_AI" & vbCrLf & _
						StringIf(strCType<>"PB" AND strCType<>"GH","	WHERE dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0" & vbCrLf) & _
						"SET NOCOUNT OFF"
	
		strBasicModSQL = "SET NOCOUNT ON" & vbCrLf & _
						"UPDATE btd SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert & " FROM GBL_BaseTable_Description btd INNER JOIN @AffectedNUMs tm ON btd.NUM=tm.NUM" & vbCrLf & _
						"SET NOCOUNT OFF"
		
		strPubModSQL = "SET NOCOUNT ON" & vbCrLf & _
						"UPDATE pb SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert & " FROM CIC_BT_PB pb INNER JOIN @AffectedNUMs tm ON pb.NUM=tm.NUM" & vbCrLf & _
						"SET NOCOUNT OFF"
	
		strBasicCICCheckSQL = "SET NOCOUNT ON" & vbCrLf & _
							"INSERT INTO CIC_BaseTable (NUM,CREATED_DATE,CREATED_BY,MODIFIED_DATE,MODIFIED_BY)" & vbCrLf & _
							"	SELECT tm.NUM,GETDATE()," & strUserInsert & ",GETDATE()," & strUserInsert & vbCrLf & _
							"	FROM @tmpNUMs tm" & vbCrLf & _
							"	WHERE NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.NUM=tm.NUM)" & vbCrLf & _
							"SET NOCOUNT OFF"
	
		strBasicCCRCheckSQL = "SET NOCOUNT ON" & vbCrLf & _
							"INSERT INTO CCR_BaseTable (NUM,CREATED_DATE,CREATED_BY,MODIFIED_DATE,MODIFIED_BY)" & vbCrLf & _
							"	SELECT tm.NUM,GETDATE()," & strUserInsert & ",GETDATE()," & strUserInsert & vbCrLf & _
							"	FROM @tmpNUMs tm" & vbCrLf & _
							"	WHERE NOT EXISTS(SELECT * FROM CCR_BaseTable ccbt WHERE ccbt.NUM=tm.NUM)" & vbCrLf & _
							"SET NOCOUNT OFF"
	End If

	Set cmdAddRemove = Server.CreateObject("ADODB.Command")
	With cmdAddRemove
		.ActiveConnection = getCurrentAdminCnn()
		If strCType = "GH" And Not Nl(intSynchID) Then
			.CommandType = adCmdStoredProc
		Else
			.CommandType = adCmdText
		End If
		Select Case ps_intDbArea
			Case DM_CIC
				Select Case strCType
					'###################
					' Distribution Code
					'###################
					Case "DST"
						Select Case strActionType
							Case "A"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM CIC_Distribution dst WHERE dst.DST_ID IN (" & intID & ")) BEGIN" & vbCrLf & _
									strBasicCICCheckSQL & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	INSERT INTO CIC_BT_DST (DST_ID,NUM)" & vbCrLf & _
									"		OUTPUT INSERTED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	SELECT DST_ID, tm.NUM" & vbCrLf & _
									"		FROM @tmpNUMs tm, (SELECT DST_ID FROM CIC_Distribution WHERE DST_ID IN (" & intID & ")) dst" & vbCrLf & _
									"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_DST pr WHERE pr.DST_ID=dst.DST_ID AND pr.NUM=tm.NUM)" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
							Case "D"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM CIC_Distribution WHERE DST_ID IN (" & intID & ")) BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	DELETE FROM pr" & vbCrLf & _
									"		OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	FROM CIC_BT_DST pr" & vbCrLf & _
									"	INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"	WHERE pr.DST_ID IN (" & intID & ")" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
							Case "DXXX"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM pr" & vbCrLf & _
									"	OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"FROM CIC_BT_DST pr" & vbCrLf & _
									"INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
						End Select
						cmdHistory.Parameters("@FieldName").Value = "DISTRIBUTION"

					'###################
					' NAICS Code
					'###################
					Case "NC"
						If strActionType<>"DXXX" Then
%>
<p class="Info"><%=TXT_CODE & TXT_COLON%><%=intID%> (<%=strCodeName%>)</p>
<%
						End If
						Select Case strActionType
							Case "A"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM NAICS nc WHERE nc.Code=" & strQCode & ") BEGIN" & vbCrLf & _
									strBasicCICCheckSQL & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	INSERT INTO CIC_BT_NC (Code,NUM)" & vbCrLf & _
									"		OUTPUT INSERTED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	SELECT " & intID & " AS Code, tm.NUM" & vbCrLf & _
									"		FROM @tmpNUMs tm" & vbCrLf & _
									"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_NC nc WHERE nc.Code=" & strQCode & " AND nc.NUM=tm.NUM)" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
							Case "D"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM NAICS WHERE Code=" & strQCode & ") BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	DELETE FROM pr" & vbCrLf & _
									"		OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	FROM CIC_BT_NC pr" & vbCrLf & _
									"	INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"	WHERE pr.Code=" & strQCode & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
							Case "DXXX"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM pr" & vbCrLf & _
									"	OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"FROM CIC_BT_NC pr" & vbCrLf & _
									"INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
						End Select
						cmdHistory.Parameters("@FieldName").Value = "NAICS"

					'###################
					' Publication Code
					'###################
					Case "PB"
						Select Case strActionType
							Case "A"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID IN (" & intID & ")" & _
										IIf(Not g_bCanSeeNonPublicPub," AND pb.NonPublic=0", _
											StringIf(Nl(g_bCanSeeNonPublicPub), _
												" AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=" & g_intViewTypeCIC & " AND qlp.PB_ID=pb.PB_ID)")) & _
										") BEGIN" & vbCrLf & _
									strBasicCICCheckSQL & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	INSERT INTO CIC_BT_PB (PB_ID,NUM,CREATED_DATE,CREATED_BY,MODIFIED_DATE,MODIFIED_BY)" & vbCrLf & _
									"		OUTPUT INSERTED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	SELECT PB_ID,tm.NUM,GETDATE(), " & strUserInsert & ",GETDATE(), " & strUserInsert & vbCrLf & _
									"		FROM @tmpNUMs tm, (SELECT PB_ID FROM CIC_Publication pb1 WHERE PB_ID IN (" & intID & ")" & _
											IIf(Not g_bCanSeeNonPublicPub," AND pb1.NonPublic=0", _
												StringIf(Nl(g_bCanSeeNonPublicPub), _
													" AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=" & g_intViewTypeCIC & " AND qlp.PB_ID=pb1.PB_ID)")) & _
											") pb" & vbCrLf & _
									"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_PB pr WHERE pr.PB_ID=pb.PB_ID AND pr.NUM=tm.NUM)" & vbCrLf & _
									"		AND dbo.fn_CIC_CanUpdatePub(tm.NUM,PB_ID," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs"
							Case "D"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID IN (" & intID & ")" & _
										IIf(Not g_bCanSeeNonPublicPub," AND pb.NonPublic=0", _
											StringIf(Nl(g_bCanSeeNonPublicPub), _
												" AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=" & g_intViewTypeCIC & " AND qlp.PB_ID=pb.PB_ID)")) & _
										") BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	DELETE FROM pr" & vbCrLf & _
									"		OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	FROM CIC_BT_PB pr" & vbCrLf & _
									"	INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"	WHERE pr.PB_ID IN (" & intID & ") AND EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=pr.PB_ID" & _
											IIf(Not g_bCanSeeNonPublicPub," AND pb.NonPublic=0", _
												StringIf(Nl(g_bCanSeeNonPublicPub), _
													" AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=" & g_intViewTypeCIC & " AND qlp.PB_ID=pb.PB_ID)")) & _
											")" & vbCrLf & _
									"		AND dbo.fn_CIC_CanUpdatePub(tm.NUM,pr.PB_ID," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs"
							Case "DXXX"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM pr" & vbCrLf & _
									"	OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"FROM CIC_BT_PB pr" & vbCrLf & _
									"INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"WHERE EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=pr.PB_ID" & _
										IIf(Not g_bCanSeeNonPublicPub," AND pb.NonPublic=0", _
											StringIf(Nl(g_bCanSeeNonPublicPub), _
												" AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=" & g_intViewTypeCIC & " AND qlp.PB_ID=pb.PB_ID)")) & _
										")" & vbCrLf & _
									"		AND dbo.fn_CIC_CanUpdatePub(tm.NUM,pr.PB_ID," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs"
						End Select

					'###################
					' Subject Term
					'###################
					Case "SBJ"
						Select Case strActionType
							Case "A"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM THS_Subject WHERE Subj_ID=" & intID & ") BEGIN" & vbCrLf & _
									strBasicCICCheckSQL & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	INSERT INTO CIC_BT_SBJ (Subj_ID,NUM)" & vbCrLf & _
									"		OUTPUT INSERTED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	SELECT " & intID & " AS Subj_ID, tm.NUM" & vbCrLf & _
									"		FROM @tmpNUMs tm" & vbCrLf & _
									"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_SBJ sj WHERE sj.Subj_ID=" & intID & " AND sj.NUM=tm.NUM)" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"EXEC sp_CIC_SRCH_u" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
							Case "D"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM THS_Subject WHERE Subj_ID=" & intID & ") BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	DELETE FROM pr" & vbCrLf & _
									"		OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"	FROM CIC_BT_SBJ pr" & vbCrLf & _
									"	INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"	WHERE pr.Subj_ID=" & intID & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"EXEC sp_CIC_SRCH_u" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
							Case "DXXX"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM pr" & vbCrLf & _
									"	OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"FROM CIC_BT_SBJ pr" & vbCrLf & _
									"INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"EXEC sp_CIC_SRCH_u" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									strBasicModSQL
						End Select
						cmdHistory.Parameters("@FieldName").Value = "SUBJECTS"

					'###################
					'Taxonomy Term
					'###################
					Case "TX"
						If strActionType<>"DXXX" Then
%>
<p class="Info"><%=TXT_CODE & TXT_COLON%><%=strCodeName%></p>
<%
						End If

						'Keep track of records affected
						If strActionType<>"DXXX" Then
							strCodeCon = vbNullString
							strSQL = strBasicNUMSQL & vbCrLf & "IF ("
							For Each indCode in aCode
								strSQL = strSQL & strCodeCon & "EXISTS(SELECT * FROM TAX_Term tm WHERE tm.Code=" & QsNl(indCode) & ")"
								strCodeCon = AND_CON
							Next
							strSQL = strSQL & ") BEGIN" & vbCrLf & _
									strBasicCICCheckSQL & vbCrLf & _
									"DECLARE @LinkID int" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf
						End If
						Select Case strActionType
							Case "A"
								Dim aNUMList, indNUM, strSQL
								aNUMList = Split(strIDList,",")
								'Before inserting the Term, we first have to add the link;
								'therefore, each record requires its own SQL so we can get the ID of the link.
								strSQL = strSQL & _
										"DELETE tm FROM @tmpNUMs tm" & vbCrLf & _
										"	WHERE EXISTS(SELECT * FROM CIC_BT_TAX tl" & vbCrLf & _
										"		WHERE tl.NUM=tm.NUM" & vbCrLf
								For Each indCode in aCode
									strSQL = strSQL & _
										"			AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code=" & QsNl(indCode) & ")" & vbCrLf
								Next
								strSQL = strSQL & _
										"			AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code NOT IN (" & strQCode & ")))"
								For Each indNUM in aNUMList
									strSQL = strSQL & vbCrLf & _
										"IF EXISTS(SELECT * FROM @tmpNUMs WHERE NUM=" & QsNl(indNUM) & ") BEGIN" & vbCrLf & _
										"	INSERT INTO CIC_BT_TAX (NUM) VALUES (" & QsNl(indNUM) & ")" & vbCrLf & _
										"	UPDATE cbt SET TAX_MODIFIED_DATE=GETDATE(),TAX_MODIFIED_BY=" & strUserInsert & vbCrLf & _
										"		FROM CIC_BaseTable cbt INNER JOIN @tmpNUMs tm ON cbt.NUM=tm.NUM" & vbCrLf & _
										"		WHERE cbt.NUM=" & QsNl(indNUM) & vbCrLf & _
										"	SET @LinkID=SCOPE_IDENTITY()" & vbCrLf
									For Each indCode in aCode
										strSQL = strSQL & _
										"	INSERT INTO CIC_BT_TAX_TM (BT_TAX_ID,Code) VALUES (@LinkID," & QsNl(indCode) & ")" & vbCrLf
									Next
									strSQL = strSQL & _
										"END"
								Next
								strSQL = strSQL & vbCrLf & "EXEC sp_CIC_SRCH_TAX_u NULL" & vbCrLf & _
										"EXEC sp_CIC_SRCH_PubTax_u NULL, NULL" vbCrLf & _
										"SET NOCOUNT OFF"
							Case "D"
								Select Case Request("LinkOption")
									'Delete the link if it contains *only* the Term in question
									Case "I"
										strSQL = strSQL & vbCrLf & _
											"SET NOCOUNT ON" & vbCrLf & _
											"DELETE tm FROM @tmpNUMs tm" & vbCrLf & _
											"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_TAX tl" & vbCrLf & _
											"		WHERE tl.NUM=tm.NUM" & vbCrLf
										For Each indCode in aCode
											strSQL = strSQL & _
											"			AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code=" & QsNl(indCode) & ")" & vbCrLf
										Next
										strSQL = strSQL & _
											"		AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt2 WHERE tlt2.BT_TAX_ID=tl.BT_TAX_ID AND tlt2.Code NOT IN (" & strQCode & ")))" & vbCrLf & _
											"UPDATE cbt SET TAX_MODIFIED_DATE=GETDATE(),TAX_MODIFIED_BY=" & strUserInsert & vbCrLf & _
											"	FROM CIC_BaseTable cbt INNER JOIN @tmpNUMs tm ON cbt.NUM=tm.NUM" & vbCrLf & _
											"DELETE tl FROM CIC_BT_TAX tl" & vbCrLf & _
											"	INNER JOIN @tmpNUMs tm ON tl.NUM=tm.NUM" & vbCrLf
											strCodeCon = "WHERE "
											For Each indCode in aCode
												strSQL = strSQL & _
												"	" & strCodeCon & "EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code=" & QsNl(indCode) & ")" & vbCrLf
												strCodeCon = AND_CON
											Next
											strSQL = strSQL & _
											"		AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code NOT IN (" & strQCode & "))" & vbCrLf & _
											"EXEC sp_CIC_SRCH_TAX_u NULL" & vbCrLf & _
											"EXEC sp_CIC_SRCH_PubTax_u NULL, NULL" vbCrLf & _
											"SET NOCOUNT OFF"
									'Delete the Term from the link, even if there are other Terms.
									'If this is the only Term, the link will be automatically deleted by Triggers.
									Case "T"
										strSQL = strSQL & vbCrLf & _
											"SET NOCOUNT ON" & vbCrLf & _
											"DELETE tm FROM @tmpNUMs tm" & vbCrLf & _
											"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_TAX tl" & vbCrLf & _
											"		WHERE tl.NUM=tm.NUM" & vbCrLf
										For Each indCode in aCode
											strSQL = strSQL & _
											"			AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code=" & QsNl(indCode) & ")" & vbCrLf
										Next
										strSQL = strSQL & _
											"	)" & vbCrLf & _
											"UPDATE cbt SET TAX_MODIFIED_DATE=GETDATE(),TAX_MODIFIED_BY=" & strUserInsert & vbCrLf & _
											"	FROM CIC_BaseTable cbt INNER JOIN @tmpNUMs tm ON cbt.NUM=tm.NUM" & vbCrLf & _
											"DELETE tlt FROM CIC_BT_TAX_TM tlt" & vbCrLf & _
											"	INNER JOIN CIC_BT_TAX tl ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
											"	INNER JOIN @tmpNUMs tm ON tl.NUM=tm.NUM" & vbCrLf & _
											"	WHERE tlt.Code IN (" & strQCode & ")" & vbCrLf
											For Each indCode in aCode
												strSQL = strSQL & _
												"	AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt2 WHERE tlt2.BT_TAX_ID=tl.BT_TAX_ID AND tlt2.Code=" & QsNl(indCode) & ")" & vbCrLf
											Next
											strSQL = strSQL & _
											"EXEC sp_CIC_SRCH_TAX_u NULL" & vbCrLf & _
											"EXEC sp_CIC_SRCH_PubTax_u NULL, NULL" vbCrLf & _
											"SET NOCOUNT OFF"
									'Delete any link containing the Term in its entirety (including other terms linked with this Term)
									Case "L"
										strSQL = strSQL & vbCrLf & _
											"SET NOCOUNT ON" & vbCrLf & _
											"DELETE tm FROM @tmpNUMs tm" & vbCrLf & _
											"	WHERE NOT EXISTS(SELECT * FROM CIC_BT_TAX tl" & vbCrLf & _
											"		WHERE tl.NUM=tm.NUM" & vbCrLf
										For Each indCode in aCode
											strSQL = strSQL & _
											"			AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code=" & QsNl(indCode) & ")" & vbCrLf
										Next
										strSQL = strSQL & _
											"	)" & vbCrLf & _
											"UPDATE cbt SET TAX_MODIFIED_DATE=GETDATE(),TAX_MODIFIED_BY=" & strUserInsert & vbCrLf & _
											"	FROM CIC_BaseTable cbt INNER JOIN @tmpNUMs tm ON cbt.NUM=tm.NUM" & vbCrLf & _
											"DELETE tl FROM CIC_BT_TAX tl" & vbCrLf & _
											"	INNER JOIN @tmpNUMs tm ON tl.NUM=tm.NUM" & vbCrLf
											strCodeCon = "WHERE "
											For Each indCode in aCode
												strSQL = strSQL & _
												"	" & strCodeCon & "EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code=" & QsNl(indCode) & ")" & vbCrLf
												strCodeCon = AND_CON
											Next
											strSQL = strSQL & _
											"EXEC sp_CIC_SRCH_TAX_u NULL" & vbCrLf & _
											"EXEC sp_CIC_SRCH_PubTax_u NULL, NULL" vbCrLf & _
											"SET NOCOUNT OFF"
								End Select
							Case "DXXX"
								.CommandText = strBasicNUMSQL & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM pr" & vbCrLf & _
									"	OUTPUT DELETED.NUM INTO @AffectedNUMs" & vbCrLf & _
									"FROM CIC_BT_TAX pr" & vbCrLf & _
									"INNER JOIN @tmpNUMs tm ON pr.NUM=tm.NUM" & vbCrLf & _
									"EXEC sp_CIC_SRCH_u" & vbCrLf & _
									"DELETE FROM @tmpNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM @AffectedNUMs" & vbCrLf & _
									"UPDATE cbt SET TAX_MODIFIED_DATE=GETDATE(),TAX_MODIFIED_BY=" & strUserInsert & vbCrLf & _
									"	FROM CIC_BaseTable cbt INNER JOIN @AffectedNUMs tm ON cbt.NUM=tm.NUM"
						End Select
						'Return the count of records affected as a recordset.
						If strActionType<>"DXXX" Then
							strSQL = strSQL & vbCrLf & "END" & vbCrLf & _
								"DELETE FROM @tmpNUMs"
							.CommandText = strSQL
						End If
						
						cmdHistory.Parameters("@FieldName").Value = "TAXONOMY"

					'###################
					' General Heading
					'###################

					Case "GH"
						If Not Nl(intSynchID) Then
							.CommandText = "dbo.sp_CIC_NUMSetGHIDs_Copy"
							.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarchar, adParamInput, 50, user_strMod)
							.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
							.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
							.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
							.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
							.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
							.Parameters.Append .CreateParameter("@SynchPBID", adInteger, adParamInput, 4, intSynchID)
							.Parameters.Append .CreateParameter("@RecordsAffected", adInteger, adParamOutput, 4)
						Else
							Select Case strActionType
								Case "A"
									.CommandText = "DECLARE @AffectedBTPBIDs TABLE(BT_PB_ID int)" & vbCrLf & _
										strBasicNUMSQL & vbCrLf & _
										"IF EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.Used=1 AND gh.GH_ID IN (" & intID & ") AND PB_ID=" & intPBID & ") BEGIN" & vbCrLf & _
										strBasicCICCheckSQL & vbCrLf & _
										"	SET NOCOUNT ON" & vbCrLf & _
										"	INSERT INTO CIC_BT_PB_GH (GH_ID,BT_PB_ID,NUM_Cache,CREATED_DATE,CREATED_BY,MODIFIED_DATE,MODIFIED_BY)" & vbCrLf & _
										"		OUTPUT INSERTED.BT_PB_ID INTO @AffectedBTPBIDs" & vbCrLf & _
										"	SELECT gh.GH_ID,BT_PB_ID,pb.NUM,GETDATE()," & strUserInsert & ",GETDATE()," & strUserInsert & vbCrLf & _
										"		FROM (SELECT GH_ID FROM CIC_GeneralHeading WHERE Used=1 AND GH_ID IN (" & intID & ") AND PB_ID=" & intPBID & ") gh, @tmpNUMs tm" & vbCrLf & _
										"		INNER JOIN CIC_BT_PB pb ON tm.NUM=pb.NUM" & vbCrLf & _
										"	WHERE pb.PB_ID=" & intPBID & vbCrLf & _
										"		AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH pr WHERE pr.GH_ID IN (" & intID & ") AND pr.BT_PB_ID=pb.BT_PB_ID)" & vbCrLf & _
										"		AND dbo.fn_CIC_CanUpdatePub(pb.NUM,pb.PB_ID," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0" & vbCrLf & _	
										"	SET NOCOUNT OFF" & vbCrLf & _
										"END" & vbCrLf & _
										"SET NOCOUNT ON" & vbCrLf & _
										"DELETE FROM @tmpNUMs" & vbCrLf & _
										"SET NOCOUNT OFF" & vbCrLf & _
										"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM CIC_BT_PB pr INNER JOIN @AffectedBTPBIDs af ON pr.BT_PB_ID=af.BT_PB_ID" & vbCrLf & _
										strPubModSQL
								Case "D"
									.CommandText = "DECLARE @AffectedBTPBIDs TABLE(BT_PB_ID int)" & vbCrLf & _
										strBasicNUMSQL & vbCrLf & _
										"IF EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.GH_ID IN (" & intID & ") AND PB_ID=" & intPBID & ") BEGIN" & vbCrLf & _
										strBasicCICCheckSQL & vbCrLf & _
										"	SET NOCOUNT ON" & vbCrLf & _
										"	DELETE prgh" & vbCrLf & _
										"		OUTPUT DELETED.BT_PB_ID INTO @AffectedBTPBIDs" & vbCrLf & _
										"	FROM CIC_BT_PB_GH prgh" & vbCrLf & _
										"	INNER JOIN CIC_GeneralHeading gh ON gh.GH_ID=prgh.GH_ID AND gh.Used=1" & vbCrLf & _
										"	INNER JOIN @tmpNUMs tm ON prgh.NUM_Cache=tm.NUM" & vbCrLf & _
										"	WHERE gh.GH_ID IN (" & intID & ")" & vbCrLf & _
										"		AND dbo.fn_CIC_CanUpdatePub(tm.NUM,gh.PB_ID," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0" & vbCrLf & _
										"	SET NOCOUNT OFF" & vbCrLf & _
										"END" & vbCrLf & _
										"SET NOCOUNT ON" & vbCrLf & _
										"DELETE FROM @tmpNUMs" & vbCrLf & _
										"SET NOCOUNT OFF" & vbCrLf & _
										"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM CIC_BT_PB pr INNER JOIN @AffectedBTPBIDs af ON pr.BT_PB_ID=af.BT_PB_ID" & vbCrLf & _
										strPubModSQL
								Case "DXXX"
									.CommandText = "DECLARE @AffectedBTPBIDs TABLE(BT_PB_ID int)" & vbCrLf & _
										strBasicNUMSQL & vbCrLf & _
										"IF EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE PB_ID=" & intPBID & ") BEGIN" & vbCrLf & _
										strBasicCICCheckSQL & vbCrLf & _
										"	SET NOCOUNT ON" & vbCrLf & _
										"	DELETE prgh" & vbCrLf & _
										"		OUTPUT DELETED.BT_PB_ID INTO @AffectedBTPBIDs" & vbCrLf & _
										"	FROM CIC_BT_PB_GH prgh" & vbCrLf & _
										"	INNER JOIN CIC_GeneralHeading gh ON gh.GH_ID=prgh.GH_ID AND gh.Used=1" & vbCrLf & _
										"	INNER JOIN @tmpNUMs tm ON prgh.NUM_Cache=tm.NUM" & vbCrLf & _
										"	WHERE gh.PB_ID=" & intPBID & vbCrLf & _
										"	SET NOCOUNT OFF" & vbCrLf & _
										"END" & vbCrLf & _
										"SET NOCOUNT ON" & vbCrLf & _
										"DELETE FROM @tmpNUMs" & vbCrLf & _
										"SET NOCOUNT OFF" & vbCrLf & _
										"INSERT INTO @tmpNUMs SELECT DISTINCT NUM FROM CIC_BT_PB pr INNER JOIN @AffectedBTPBIDs af ON pr.BT_PB_ID=af.BT_PB_ID" & vbCrLf & _
										strPubModSQL
							End Select
							
						End If

					'###################
					' Unknown Action
					'###################
					Case Else
						bError = True
						Call handleError(TXT_NO_ACTION, _
							vbNullString, _
							vbNullString)
				End Select
			Case DM_VOL
				Select Case strCType
					'###################
					' Specific Area of Interest
					'###################
					Case "AI"
						Select Case strActionType
							Case "A"
								.CommandText = strBasicVNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM VOL_Interest ai WHERE AI_ID IN (" & intID & ") AND EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai.AI_ID" & StringIf(Not Nl(intIGID), " AND IG_ID IN (" & intIGID & ")") & ")) BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	INSERT INTO VOL_OP_AI (VNUM, AI_ID)" & vbCrLf & _
									"		OUTPUT INSERTED.VNUM INTO @AffectedVNUMs" & vbCrLf & _
									"	SELECT tm.VNUM, ai.AI_ID" & vbCrLf & _
									"		FROM (SELECT AI_ID FROM VOL_Interest ai1 WHERE AI_ID IN (" & intID & ") AND EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai1.AI_ID" & StringIf(Not Nl(intIGID), " AND IG_ID IN (" & intIGID & ")") & ")) ai, @tmpVNUMs tm" & vbCrLf & _
									"		WHERE NOT EXISTS(SELECT * FROM VOL_OP_AI pr WHERE pr.AI_ID=ai.AI_ID AND pr.VNUM=tm.VNUM)" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpVNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpVNUMs SELECT DISTINCT VNUM FROM @AffectedVNUMs" & vbCrLf & _
									strBasicModSQL
							Case "D"
								.CommandText = strBasicVNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM VOL_Interest ai WHERE AI_ID IN (" & intID & ") AND EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai.AI_ID" & StringIf(Not Nl(intIGID), " AND IG_ID IN (" & intIGID & ")") & ")) BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	DELETE FROM pr" & vbCrLf & _
									"		OUTPUT DELETED.VNUM INTO @AffectedVNUMs" & vbCrLf & _
									"	FROM VOL_OP_AI pr" & vbCrLf & _
									"	INNER JOIN @tmpVNUMs tm ON pr.VNUM=tm.VNUM" & vbCrLf & _
									"	WHERE pr.AI_ID IN (" & intID & ") AND EXISTS(SELECT * FROM VOL_Interest ai1 WHERE AI_ID=pr.AI_ID AND EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai1.AI_ID" & StringIf(Not Nl(intIGID), " AND IG_ID IN (" & intIGID & ")") & "))" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpVNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpVNUMs SELECT DISTINCT VNUM FROM @AffectedVNUMs" & vbCrLf & _
									strBasicModSQL
							Case "DXXX"
								.CommandText = strBasicVNUMSQL & vbCrLf & _
									"IF EXISTS(SELECT * FROM VOL_Interest ai WHERE EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai.AI_ID" & StringIf(Not Nl(intIGID), " AND IG_ID IN (" & intIGID & ")") & ")) BEGIN" & vbCrLf & _
									"	SET NOCOUNT ON" & vbCrLf & _
									"	DELETE FROM pr" & vbCrLf & _
									"		OUTPUT DELETED.VNUM INTO @AffectedVNUMs" & vbCrLf & _
									"	FROM VOL_OP_AI pr" & vbCrLf & _
									"	INNER JOIN @tmpVNUMs tm ON pr.VNUM=tm.VNUM" & vbCrLf & _
									"	WHERE EXISTS(SELECT * FROM VOL_Interest ai1 WHERE AI_ID=pr.AI_ID AND EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai1.AI_ID" & StringIf(Not Nl(intIGID), " AND IG_ID IN (" & intIGID & ")") & "))" & vbCrLf & _
									"	SET NOCOUNT OFF" & vbCrLf & _
									"END" & vbCrLf & _
									"SET NOCOUNT ON" & vbCrLf & _
									"DELETE FROM @tmpVNUMs" & vbCrLf & _
									"SET NOCOUNT OFF" & vbCrLf & _
									"INSERT INTO @tmpVNUMs SELECT DISTINCT VNUM FROM @AffectedVNUMs" & vbCrLf & _
									strBasicModSQL
						End Select
					'###################
					' Unknown Action
					'###################
					Case Else
						bError = True
						Call handleError(TXT_NO_ACTION, _
							vbNullString, _
							vbNullString)
				End Select
			Case Else
				bError = True
				Call handleError(TXT_NO_ACTION, _
					vbNullString, _
					vbNullString)
		End Select
		.CommandTimeout = 0

		'Response.Write("<pre>" & .CommandText & "</pre>")
		'Response.Flush()
		
		If strCType = "GH" And Not Nl(intSynchID) Then
			Set rsAddRemove = cmdAddRemove.Execute
			Set rsAddRemove = rsAddRemove.NextRecordset
			intNumAffected = cmdAddRemove.Parameters("@RecordsAffected").Value
			Set rsAddRemove = Nothing
		Else
			.Execute intNumAffected
		End If

	End With
	Set cmdAddRemove = Nothing
End If
%>
<%
If Err.Number <> 0 Then
	Response.Write(TXT_ERROR & Err.Description)
ElseIf Not bError Then
	If ps_intDbArea = DM_CIC And intNumAffected > 0 Then
		If Not Nl(cmdHistory.Parameters("@FieldName").Value) Then
			cmdHistory.Execute
		End If
	End If

	If strActionType="A" Then
%>
<p><%=TXT_CODE_ADDED_TO%> <strong><%=intNumAffected%></strong> <%=TXT_RECORDS%></p>
<p><%=TXT_CODE_ALREADY_IN%></p>
<%
	Else
%>
<p><%=TXT_CODE_REMOVED_FROM%> <strong><%=intNumAffected%></strong> <%=TXT_RECORDS%></p>
<p><%=TXT_CODE_NOT_IN%></p>
<%
	End If
	If IsArray(aGetSearchArray) Then
		If UBound(aGetSearchArray) >= 0 Then
%>
<p><a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a> *</p>
<p><span class="SmallNote">* <%=TXT_NOTE_PREVIOUS_SEARCH%></span></p>
<%
		End If
	End If
%>

<%
End If

Call makePageFooter(True)
%>
