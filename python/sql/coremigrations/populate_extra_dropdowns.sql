DECLARE @FieldName varchar(100)

SET @FieldName = 'EXTRA_DROPDOWN_A'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_A IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDA_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownA
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDA_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownA_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownA t1
		ON t1.EXDA_ID = t1n.EXDA_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDA_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownA_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownA t1
		ON t1.EXDA_ID = t1i.EXDA_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDA_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownA t1
		ON t1.EXDA_ID = bt.EXTRA_DROPDOWN_A
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDA_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_B'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_B IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDB_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownB
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDB_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownB_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownB t1
		ON t1.EXDB_ID = t1n.EXDB_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDB_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownB_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownB t1
		ON t1.EXDB_ID = t1i.EXDB_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDB_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownB t1
		ON t1.EXDB_ID = bt.EXTRA_DROPDOWN_B
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDB_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_C'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_C IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDC_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownC
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDC_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownC_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownC t1
		ON t1.EXDC_ID = t1n.EXDC_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDC_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownC_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownC t1
		ON t1.EXDC_ID = t1i.EXDC_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDC_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownC t1
		ON t1.EXDC_ID = bt.EXTRA_DROPDOWN_C
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDC_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_D'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_D IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDD_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownD
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDD_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownD_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownD t1
		ON t1.EXDD_ID = t1n.EXDD_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDD_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownD_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownD t1
		ON t1.EXDD_ID = t1i.EXDD_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDD_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownD t1
		ON t1.EXDD_ID = bt.EXTRA_DROPDOWN_D
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDD_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_E'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_E IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDE_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownE
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDE_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownE_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownE t1
		ON t1.EXDE_ID = t1n.EXDE_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDE_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownE_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownE t1
		ON t1.EXDE_ID = t1i.EXDE_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDE_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownE t1
		ON t1.EXDE_ID = bt.EXTRA_DROPDOWN_E
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDE_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_F'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_F IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDF_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownF
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDF_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownF_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownF t1
		ON t1.EXDF_ID = t1n.EXDF_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDF_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownF_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownF t1
		ON t1.EXDF_ID = t1i.EXDF_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDF_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownF t1
		ON t1.EXDF_ID = bt.EXTRA_DROPDOWN_F
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDF_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_G'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_G IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDG_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownG
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDG_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownG_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownG t1
		ON t1.EXDG_ID = t1n.EXDG_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDG_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownG_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownG t1
		ON t1.EXDG_ID = t1i.EXDG_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDG_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownG t1
		ON t1.EXDG_ID = bt.EXTRA_DROPDOWN_G
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDG_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END

SET @FieldName = 'EXTRA_DROPDOWN_H'
IF EXISTS(SELECT * FROM dbo.CIC_BaseTable WHERE EXTRA_DROPDOWN_H IS NOT NULL) BEGIN
	INSERT INTO dbo.CIC_ExtraDropDown
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
		ISNULL(Code,'TMPCD' + CAST(EXDH_ID AS varchar)),
		DisplayOrder
	FROM dbo.CIC_ExtraDropDownH
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown WHERE FieldName=@FieldName AND Code=ISNULL(Code,'TMPCD' + CAST(EXDH_ID AS varchar)))
	
	INSERT INTO dbo.CIC_ExtraDropDown_Name
	        ( EXD_ID, LangID, FieldName_Cache, Name )
	SELECT exd.EXD_ID, t1n.LangID, exd.FieldName, t1n.Name
	FROM dbo.CIC_ExtraDropDownH_Name t1n
	INNER JOIN dbo.CIC_ExtraDropDownH t1
		ON t1.EXDH_ID = t1n.EXDH_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDH_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID AND LangID=t1n.LangID)
	
	INSERT INTO dbo.CIC_ExtraDropDown_InactiveByMember
	        ( EXD_ID, MemberID )
	SELECT exd.EXD_ID, t1i.MemberID
	FROM dbo.CIC_ExtraDropDownH_InactiveByMember t1i
	INNER JOIN dbo.CIC_ExtraDropDownH t1
		ON t1.EXDH_ID = t1i.EXDH_ID
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(t1.EXDH_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=t1i.MemberID)
	
	INSERT INTO dbo.CIC_BT_EXD
	        ( NUM, EXD_ID, FieldName_Cache )
	SELECT bt.NUM, exd.EXD_ID, exd.FieldName
	FROM dbo.CIC_BaseTable bt
	INNER JOIN dbo.CIC_ExtraDropDownH t1
		ON t1.EXDH_ID = bt.EXTRA_DROPDOWN_H
	INNER JOIN dbo.CIC_ExtraDropDown exd
		ON exd.Code=ISNULL(t1.Code,'TMPCD' + CAST(EXDH_ID AS varchar)) AND FieldName=@FieldName
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_EXD WHERE NUM=bt.NUM and FieldName_Cache=@FieldName)

END ELSE BEGIN
	DELETE FROM dbo.GBL_FieldOption WHERE FieldName=@FieldName
END