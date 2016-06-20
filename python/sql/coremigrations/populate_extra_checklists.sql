DECLARE @FieldName varchar(100)

SET @FieldName = 'EXTRA_CHECKLIST_A'
IF EXISTS(SELECT * FROM dbo.CIC_BT_EXCA) BEGIN
	INSERT INTO dbo.CIC_ExtraCheckList
	        ( FieldName ,
	          CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          Code ,
	          DisplayOrder
	        )
	SELECT @FieldName,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		ISNULL(Code,'TMPCD' + CAST(EXCA_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraCheckListA
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXCA_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraCheckList_Name
	        ( EXC_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXC_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraCheckListA_Name t1n
	INNER JOIN dbo.CIC_ExtraCheckListA t1
		ON t1.EXCA_ID = t1n.EXCA_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCA_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_Name WHERE EXC_ID=exd.EXC_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraCheckList_InactiveByMember
	        ( EXC_ID, MemberID )
	SELECT exd.EXC_ID, t1i.MemberID
	FROM dbo.CIC_ExtraCheckListA_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraCheckListA t1
		ON t1.EXCA_ID = t1i.EXCA_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCA_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_InactiveByMember WHERE EXC_ID=exd.EXC_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXC
	        ( NUM, EXC_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXC_ID, exd.FieldName
	FROM dbo.CIC_BT_EXCA bt
	INNER JOIN dbo.CIC_ExtraCheckListA t1
		ON t1.EXCA_ID = bt.EXCA_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCA_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXC WHERE NUM=bt.NUM AND EXC_ID=exd.EXC_ID)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_CHECKLIST_B'
IF EXISTS(SELECT * FROM dbo.CIC_BT_EXCB) BEGIN
	INSERT INTO dbo.CIC_ExtraCheckList
	        ( FieldName ,
	          CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          Code ,
	          DisplayOrder
	        )
	SELECT @FieldName,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		ISNULL(Code,'TMPCD' + CAST(EXCB_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraCheckListB
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXCB_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraCheckList_Name
	        ( EXC_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXC_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraCheckListB_Name t1n
	INNER JOIN dbo.CIC_ExtraCheckListB t1
		ON t1.EXCB_ID = t1n.EXCB_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCB_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_Name WHERE EXC_ID=exd.EXC_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraCheckList_InactiveByMember
	        ( EXC_ID, MemberID )
	SELECT exd.EXC_ID, t1i.MemberID
	FROM dbo.CIC_ExtraCheckListB_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraCheckListB t1
		ON t1.EXCB_ID = t1i.EXCB_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCB_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_InactiveByMember WHERE EXC_ID=exd.EXC_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXC
	        ( NUM, EXC_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXC_ID, exd.FieldName
	FROM dbo.CIC_BT_EXCB bt
	INNER JOIN dbo.CIC_ExtraCheckListB t1
		ON t1.EXCB_ID = bt.EXCB_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCB_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXC WHERE NUM=bt.NUM AND EXC_ID=exd.EXC_ID)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_CHECKLIST_C'
IF EXISTS(SELECT * FROM dbo.CIC_BT_EXCC) BEGIN
	INSERT INTO dbo.CIC_ExtraCheckList
	        ( FieldName ,
	          CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          Code ,
	          DisplayOrder
	        )
	SELECT @FieldName,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		ISNULL(Code,'TMPCD' + CAST(EXCC_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraCheckListC
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXCC_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraCheckList_Name
	        ( EXC_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXC_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraCheckListC_Name t1n
	INNER JOIN dbo.CIC_ExtraCheckListC t1
		ON t1.EXCC_ID = t1n.EXCC_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCC_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_Name WHERE EXC_ID=exd.EXC_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraCheckList_InactiveByMember
	        ( EXC_ID, MemberID )
	SELECT exd.EXC_ID, t1i.MemberID
	FROM dbo.CIC_ExtraCheckListC_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraCheckListC t1
		ON t1.EXCC_ID = t1i.EXCC_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCC_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_InactiveByMember WHERE EXC_ID=exd.EXC_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXC
	        ( NUM, EXC_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXC_ID, exd.FieldName
	FROM dbo.CIC_BT_EXCC bt
	INNER JOIN dbo.CIC_ExtraCheckListC t1
		ON t1.EXCC_ID = bt.EXCC_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCC_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXC WHERE NUM=bt.NUM AND EXC_ID=exd.EXC_ID)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_CHECKLIST_D'
IF EXISTS(SELECT * FROM dbo.CIC_BT_EXCD) BEGIN
	INSERT INTO dbo.CIC_ExtraCheckList
	        ( FieldName ,
	          CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          Code ,
	          DisplayOrder
	        )
	SELECT @FieldName,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		ISNULL(Code,'TMPCD' + CAST(EXCD_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraCheckListD
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXCD_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraCheckList_Name
	        ( EXC_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXC_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraCheckListD_Name t1n
	INNER JOIN dbo.CIC_ExtraCheckListD t1
		ON t1.EXCD_ID = t1n.EXCD_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCD_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_Name WHERE EXC_ID=exd.EXC_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraCheckList_InactiveByMember
	        ( EXC_ID, MemberID )
	SELECT exd.EXC_ID, t1i.MemberID
	FROM dbo.CIC_ExtraCheckListD_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraCheckListD t1
		ON t1.EXCD_ID = t1i.EXCD_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCD_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_InactiveByMember WHERE EXC_ID=exd.EXC_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXC
	        ( NUM, EXC_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXC_ID, exd.FieldName
	FROM dbo.CIC_BT_EXCD bt
	INNER JOIN dbo.CIC_ExtraCheckListD t1
		ON t1.EXCD_ID = bt.EXCD_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCD_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXC WHERE NUM=bt.NUM AND EXC_ID=exd.EXC_ID)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_CHECKLIST_E'
IF EXISTS(SELECT * FROM dbo.CIC_BT_EXCE) BEGIN
	INSERT INTO dbo.CIC_ExtraCheckList
	        ( FieldName ,
	          CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          Code ,
	          DisplayOrder
	        )
	SELECT @FieldName,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		ISNULL(Code,'TMPCD' + CAST(EXCE_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraCheckListE
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXCE_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraCheckList_Name
	        ( EXC_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXC_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraCheckListE_Name t1n
	INNER JOIN dbo.CIC_ExtraCheckListE t1
		ON t1.EXCE_ID = t1n.EXCE_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCE_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_Name WHERE EXC_ID=exd.EXC_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraCheckList_InactiveByMember
	        ( EXC_ID, MemberID )
	SELECT exd.EXC_ID, t1i.MemberID
	FROM dbo.CIC_ExtraCheckListE_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraCheckListE t1
		ON t1.EXCE_ID = t1i.EXCE_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCE_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_InactiveByMember WHERE EXC_ID=exd.EXC_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXC
	        ( NUM, EXC_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXC_ID, exd.FieldName
	FROM dbo.CIC_BT_EXCE bt
	INNER JOIN dbo.CIC_ExtraCheckListE t1
		ON t1.EXCE_ID = bt.EXCE_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCE_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXC WHERE NUM=bt.NUM AND EXC_ID=exd.EXC_ID)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_CHECKLIST_F'
IF EXISTS(SELECT * FROM dbo.CIC_BT_EXCF) BEGIN
	INSERT INTO dbo.CIC_ExtraCheckList
	        ( FieldName ,
	          CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          Code ,
	          DisplayOrder
	        )
	SELECT @FieldName,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		ISNULL(Code,'TMPCD' + CAST(EXCF_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraCheckListF
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXCF_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraCheckList_Name
	        ( EXC_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXC_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraCheckListF_Name t1n
	INNER JOIN dbo.CIC_ExtraCheckListF t1
		ON t1.EXCF_ID = t1n.EXCF_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCF_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_Name WHERE EXC_ID=exd.EXC_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraCheckList_InactiveByMember
	        ( EXC_ID, MemberID )
	SELECT exd.EXC_ID, t1i.MemberID
	FROM dbo.CIC_ExtraCheckListF_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraCheckListF t1
		ON t1.EXCF_ID = t1i.EXCF_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCF_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraCheckList_InactiveByMember WHERE EXC_ID=exd.EXC_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXC
	        ( NUM, EXC_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXC_ID, exd.FieldName
	FROM dbo.CIC_BT_EXCF bt
	INNER JOIN dbo.CIC_ExtraCheckListF t1
		ON t1.EXCF_ID = bt.EXCF_ID
	INNER JOIN dbo.CIC_ExtraCheckList exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXCF_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXC WHERE NUM=bt.NUM AND EXC_ID=exd.EXC_ID)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END
