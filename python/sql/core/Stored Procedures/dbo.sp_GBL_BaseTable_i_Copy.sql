
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_i_Copy]
	@MemberID [int],
	@MODIFIED_BY varchar(50),
	@NUM varchar(8),
	@ViewType int,
	@AutoNUM bit,
	@NewNUM varchar(8) OUTPUT,
	@Owner char(3),
	@Org1 nvarchar(200),
	@Org2 nvarchar(200),
	@Org3 nvarchar(200),
	@Org4 nvarchar(200),
	@Org5 nvarchar(200),
	@LocationName nvarchar(200),
	@ServiceName1 nvarchar(200),
	@ServiceName2 nvarchar(200),
	@RecordType int,
	@FieldList varchar(max),
	@CopyPubs bit,
	@CopyTaxonomy bit,
	@CopyOnlyCurrentLang bit,
	@MakeNonPublic bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 30-Nov-2015
	Action: TESTING REQUIRED
	Notes: Should come back and parameterize all dynamically generated SQL
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@OrganizationObjectName nvarchar(100),
		@RecordNumberName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @OrganizationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @RecordNumberName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #')

DECLARE @CanSeeNonPublicPub bit,
		@LimitedView bit,
		@AddToPub int

SELECT @CanSeeNonPublicPub=CanSeeNonPublicPub, @LimitedView=LimitedView, @AddToPub=PB_ID
	FROM CIC_View WHERE ViewType=@ViewType

SET @NUM = RTRIM(LTRIM(@NUM))
SET @NewNUM = RTRIM(LTRIM(@NewNUM))

DECLARE @CheckNUM bit, 
		@BT_ID int, 
		@NEW_BT_ID int,
		@MODIFIED_DATE datetime,
		@BaseTableFieldList varchar(max),
		@SQL nvarchar(max),
		@ParamList nvarchar(max)

DECLARE @CopyFields TABLE (
	FieldName varchar(100) COLLATE Latin1_General_100_CI_AI NOT NULL,
	FieldType varchar(3) COLLATE Latin1_General_100_CI_AI NOT NULL,
	ExtraFieldType char(1) NULL,
	EquivalentSource bit NOT NULL,
	UpdateFieldList varchar(max) COLLATE Latin1_General_100_CI_AI NULL
)

SET @MODIFIED_DATE = GETDATE()

EXEC @CheckNUM = sp_GBL_UCheck_NUM NULL, @NewNUM OUTPUT, NULL, @Owner

SET @Org1 = RTRIM(LTRIM(@Org1))
IF @Org1 = '' SET @Org1 = NULL
SET @Org2 = RTRIM(LTRIM(@Org2))
IF @Org2 = '' SET @Org2 = NULL
SET @Org3 = RTRIM(LTRIM(@Org3))
IF @Org3 = '' SET @Org3 = NULL
SET @Org4 = RTRIM(LTRIM(@Org4))
IF @Org4 = '' SET @Org4 = NULL
SET @Org5 = RTRIM(LTRIM(@Org5))
IF @Org5 = '' SET @Org5 = NULL
SET @LocationName = RTRIM(LTRIM(@LocationName))
IF @LocationName = '' SET @LocationName = NULL
SET @ServiceName1 = RTRIM(LTRIM(@ServiceName1))
IF @ServiceName1 = '' SET @ServiceName1 = NULL
SET @ServiceName2 = RTRIM(LTRIM(@ServiceName2))
IF @ServiceName2 = '' SET @ServiceName2 = NULL

/* Identify errors that will prevent the record from being updated */
-- Record Number provided ?
IF @NUM IS NULL OR @NUM = '' OR @NewNUM IS NULL OR @NewNUM = '' BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RecordNumberName, @OrganizationObjectName)
-- Record Number already in use ?
END ELSE IF @CheckNUM = 1 BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NewNUM, @RecordNumberName)
-- Copy Record exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @OrganizationObjectName)
END ELSE BEGIN

	INSERT INTO @CopyFields
	SELECT DISTINCT
		FieldName,
		FieldType,
		ExtraFieldType,
		EquivalentSource,
		CASE
			WHEN FieldName IN ('CONTACT_1','CONTACT_2','EXEC_1','EXEC_2','VOLCONTACT','EXTRA_CONTACT_A','INTERNAL_MEMO','LOCATION_SERVICES','NAICS','SERVICE_LOCATIONS','SOCIAL_MEDIA') THEN NULL
			WHEN FormFieldType <> 'f' OR FieldName IN ('LOCATED_IN_CM','ORG_NUM') THEN FieldName
			ELSE UpdateFieldList
		END AS UpdateFieldList
	FROM GBL_FieldOption fo
	WHERE CanUseUpdate=1
		AND EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@FieldList,',') tm WHERE tm.ItemID=fo.FieldName COLLATE Latin1_General_100_CI_AI)
		AND FieldName NOT LIKE 'ORG_LEVEL_[1-5]'
		AND FieldName NOT IN ('NUM','RECORD_OWNER','NON_PUBLIC','MAIN_ADDRESS', 'LOCATION_NAME', 'SERVICE_NAME_LEVEL_1', 'SERVICE_NAME_LEVEL_2')
		AND PB_ID IS NULL
	ORDER BY FieldName

	IF @RecordType IS NOT NULL BEGIN
		IF NOT EXISTS(SELECT * FROM CIC_RecordType WHERE RT_ID=@RecordType) BEGIN
			SET @RecordType = NULL
		END ELSE BEGIN
			DELETE FROM @CopyFields WHERE FieldName='RECORD_TYPE'
		END
	END

	SET @FieldList = NULL

	SELECT @FieldList = COALESCE(@FieldList + ',','') + FieldName
		FROM @CopyFields

	DECLARE @FieldName varchar(100),
			@OldFieldList varchar(max),
			@NewFieldList varchar(max),
			@NewFieldListD varchar(max)

	DECLARE Lang_Cursor CURSOR STATIC FOR
	SELECT FieldName, UpdateFieldList FROM @CopyFields cf WHERE UpdateFieldList LIKE '%bt.%' AND EquivalentSource=1

	OPEN Lang_Cursor

	FETCH NEXT FROM Lang_Cursor INTO @FieldName, @OldFieldList
		WHILE @@FETCH_STATUS = 0 BEGIN

		SET @NewFieldList = NULL
		SET @NewFieldListD = NULL

		SELECT @NewFieldList = COALESCE(@NewFieldList + ',','') + REPLACE(REPLACE(REPLACE(ItemID,'ccbt.',''),'cbt.',''),'bt.','') FROM dbo.fn_GBL_ParseVarCharIDList(@OldFieldList,',') WHERE ItemID LIKE '%bt.%'
		SELECT @NewFieldListD = COALESCE(@NewFieldListD + ',','') + ItemID FROM dbo.fn_GBL_ParseVarCharIDList(@OldFieldList,',') WHERE ItemID NOT LIKE '%bt.%'

		UPDATE @CopyFields SET UpdateFieldList=@NewFieldListD WHERE FieldName=@FieldName

		INSERT INTO @CopyFields
		SELECT FieldName, FieldType, ExtraFieldType, 0, @NewFieldList
		FROM @CopyFields WHERE FieldName=@FieldName

		FETCH NEXT FROM Lang_Cursor INTO @FieldName, @OldFieldList
	END

	CLOSE Lang_Cursor

	DEALLOCATE Lang_Cursor

	/* GBL_BaseTable */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE FieldType='GBL' AND EquivalentSource=0 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	SET @ParamList = N'@MemberID int, @NUM varchar(8), @NewNUM varchar(8), @MODIFIED_DATE datetime, @MODIFIED_BY varchar(50), @Owner char(3)'

	SET @SQL = 'INSERT INTO GBL_BaseTable (MemberID, NUM, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, RECORD_OWNER
		' + CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	)
	SELECT @MemberID, @NewNUM, @MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY, ISNULL(@Owner,RECORD_OWNER)
	' + CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	FROM GBL_BaseTable WHERE NUM=@NUM'

	EXEC sp_executesql @SQL, @ParamList, @MemberID=@MemberID, @NUM=@NUM, @NewNUM=@NewNUM, @MODIFIED_DATE=@MODIFIED_DATE, @MODIFIED_BY=@MODIFIED_BY, @Owner=@Owner

	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

	/* GBL_BaseTable_Description */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE FieldType='GBL' AND EquivalentSource=1 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	SET @SQL = 'INSERT INTO GBL_BaseTable_Description (NUM, LangID, NON_PUBLIC, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		ORG_LEVEL_1, ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2'
		+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	)
	SELECT ''' + @NewNUM + ''',LangID,' + CAST(@MakeNonPublic AS varchar) + ',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''''
	+ ',' + CASE WHEN @Org1='[COPY]' THEN 'ORG_LEVEL_1' WHEN @Org1 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@Org1,'''','''''') + '''' END
	+ ',' + CASE WHEN @Org2='[COPY]' THEN 'ORG_LEVEL_2' WHEN @Org2 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@Org2,'''','''''') + '''' END
	+ ',' + CASE WHEN @Org3='[COPY]' THEN 'ORG_LEVEL_3' WHEN @Org3 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@Org3,'''','''''') + '''' END
	+ ',' + CASE WHEN @Org4='[COPY]' THEN 'ORG_LEVEL_4' WHEN @Org4 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@Org4,'''','''''') + '''' END
	+ ',' + CASE WHEN @Org5='[COPY]' THEN 'ORG_LEVEL_5' WHEN @Org5 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@Org5,'''','''''') + '''' END
	+ ',' + CASE WHEN @LocationName='[COPY]' THEN 'LOCATION_NAME' WHEN @LocationName IS NULL THEN 'NULL' ELSE '''' + REPLACE(@LocationName,'''','''''') + '''' END
	+ ',' + CASE WHEN @ServiceName1='[COPY]' THEN 'SERVICE_NAME_LEVEL_1' WHEN @ServiceName1 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@ServiceName1,'''','''''') + '''' END
	+ ',' + CASE WHEN @ServiceName2='[COPY]' THEN 'SERVICE_NAME_LEVEL_2' WHEN @ServiceName2 IS NULL THEN 'NULL' ELSE '''' + REPLACE(@ServiceName2,'''','''''') + '''' END
		+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	FROM GBL_BaseTable_Description WHERE NUM=''' + @NUM + '''' + CASE WHEN @CopyOnlyCurrentLang=0 THEN '' ELSE ' AND LangID=@@LANGID' END
	
	EXEC(@SQL)
	
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

	/* CIC_BaseTable */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE FieldType='CIC' AND EquivalentSource=0 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	IF @BaseTableFieldList IS NOT NULL OR EXISTS(SELECT * FROM @CopyFields WHERE FieldType='CIC') OR @CopyPubs=1 OR @CopyTaxonomy=1 Or @AddToPub IS NOT NULL OR @RecordType IS NOT NULL OR EXISTS(SELECT * FROM CIC_View_AutoAddPub WHERE ViewType=@ViewType) BEGIN
		SET @SQL = 'INSERT INTO CIC_BaseTable (NUM, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY'
			+ CASE WHEN @RecordType IS NULL THEN '' ELSE ',RECORD_TYPE' END
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		)
		SELECT ''' + @NewNUM + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''''
			+ CASE WHEN @RecordType IS NULL THEN '' ELSE ',' + CAST(@RecordType AS varchar) END
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		FROM CIC_BaseTable WHERE NUM=''' + @NUM + ''''
		
		EXEC(@SQL)

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	/* CIC_BaseTable_Description */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE FieldType='CIC' AND EquivalentSource=1 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	IF @BaseTableFieldList IS NOT NULL OR EXISTS(SELECT * FROM @CopyFields WHERE FieldType='CIC') OR @CopyTaxonomy=1 BEGIN
		SET @SQL = 'INSERT INTO CIC_BaseTable_Description (NUM, LangID, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY'
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		)
		SELECT ''' + @NewNUM + ''',LangID,''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''''
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		FROM CIC_BaseTable_Description WHERE NUM=''' + @NUM + '''' + CASE WHEN @CopyOnlyCurrentLang=0 THEN '' ELSE ' AND LangID=@@LANGID' END
		
		EXEC(@SQL)

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	/* CCR_BaseTable */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE FieldType='CCR' AND EquivalentSource=0 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	IF @BaseTableFieldList IS NOT NULL OR EXISTS(SELECT * FROM @CopyFields WHERE FieldType='CCR') BEGIN
		SET @SQL = 'INSERT INTO CCR_BaseTable (NUM, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY'
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		)
		SELECT ''' + @NewNUM + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''''
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		FROM CCR_BaseTable WHERE NUM=''' + @NUM + ''''
		
		EXEC(@SQL)

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	/* CIC_BaseTable_Description */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE FieldType='CCR' AND EquivalentSource=1 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	IF @BaseTableFieldList IS NOT NULL OR EXISTS(SELECT * FROM @CopyFields WHERE FieldType='CCR') BEGIN
		SET @SQL = 'INSERT INTO CCR_BaseTable_Description (NUM, LangID, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY'
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		)
		SELECT ''' + @NewNUM + ''',LangID,''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''''
			+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
		FROM CCR_BaseTable_Description WHERE NUM=''' + @NUM + '''' + CASE WHEN @CopyOnlyCurrentLang=0 THEN '' ELSE ' AND LangID=@@LANGID' END
		
		SELECT @SQL As SQL
		EXEC(@SQL)

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	INSERT INTO GBL_Contact(
		CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		GblContactType, GblNUM, LangID, 
		NAME_HONORIFIC, NAME_FIRST, NAME_LAST, NAME_SUFFIX,
		TITLE, ORG, EMAIL,
		FAX_NOTE, FAX_NO, FAX_EXT, FAX_CALLFIRST,
		PHONE_1_TYPE, PHONE_1_NOTE, PHONE_1_NO, PHONE_1_EXT, PHONE_1_OPTION,
		PHONE_2_TYPE, PHONE_2_NOTE, PHONE_2_NO, PHONE_2_EXT, PHONE_2_OPTION,
		PHONE_3_TYPE, PHONE_3_NOTE, PHONE_3_NO, PHONE_3_EXT, PHONE_3_OPTION
	) SELECT
		@MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY,
		cf.FieldName, @NewNUM, LangID,
		NAME_HONORIFIC, NAME_FIRST, NAME_LAST, NAME_SUFFIX,
		TITLE, ORG, EMAIL,
		FAX_NOTE, FAX_NO, FAX_EXT, FAX_CALLFIRST,
		PHONE_1_TYPE, PHONE_1_NOTE, PHONE_1_NO, PHONE_1_EXT, PHONE_1_OPTION,
		PHONE_2_TYPE, PHONE_2_NOTE, PHONE_2_NO, PHONE_2_EXT, PHONE_2_OPTION,
		PHONE_3_TYPE, PHONE_3_NOTE, PHONE_3_NO, PHONE_3_EXT, PHONE_3_OPTION
	FROM GBL_Contact c
	INNER JOIN @CopyFields cf
		ON c.GblContactType=cf.FieldName
	WHERE c.GblNUM=@NUM AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
	
	INSERT INTO GBL_RecordNote(
		CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		GblNoteType, GblNUM, LangID,
		CANCELLED_DATE, CANCELLED_BY, CancelError,
		NoteTypeID,
		Value
	) SELECT
		@MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY,
		cf.FieldName, @NewNUM, LangID,
		CANCELLED_DATE, CANCELLED_BY, CancelError,
		NoteTypeID,
		Value
	FROM GBL_RecordNote c
	INNER JOIN @CopyFields cf
		ON c.GblNoteType=cf.FieldName
	WHERE c.GblNUM=@NUM AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName IN ('SCHOOL_ESCORT','SCHOOLS_IN_AREA')) BEGIN
		INSERT INTO CCR_BT_SCH (
			NUM,
			SCH_ID,
			Escort,
			InArea
		)
		SELECT	@NewNUM,
				SCH_ID,
				Escort,
				InArea
			FROM CCR_BT_SCH WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO CCR_BT_SCH_Notes (
			BT_SCH_ID,
			LangID,
			EscortNotes,
			InAreaNotes
		)
		SELECT	ck1.BT_SCH_ID,
				ck3.LangID,
				ck3.EscortNotes,
				ck3.InAreaNotes
			FROM CCR_BT_SCH ck1
			INNER JOIN CCR_BT_SCH ck2
				ON ck2.NUM=@NUM AND ck1.SCH_ID=ck2.SCH_ID
			INNER JOIN CCR_BT_SCH_Notes ck3
				ON ck2.BT_SCH_ID=ck3.BT_SCH_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='TYPE_OF_CARE') BEGIN
		INSERT INTO CCR_BT_TOC (
			NUM,
			TOC_ID
		)
		SELECT	@NewNUM,
				TOC_ID
			FROM CCR_BT_TOC WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO CCR_BT_TOC_Notes (
			BT_TOC_ID,
			LangID,
			Notes
		)
		SELECT	ck1.BT_TOC_ID,
				ck3.LangID,
				ck3.Notes
			FROM CCR_BT_TOC ck1
			INNER JOIN CCR_BT_TOC ck2
				ON ck2.NUM=@NUM AND ck1.TOC_ID=ck2.TOC_ID
			INNER JOIN CCR_BT_TOC_Notes ck3
				ON ck2.BT_TOC_ID=ck3.BT_TOC_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='BUS_ROUTES') BEGIN
		INSERT INTO CIC_BT_BR (
			NUM,
			BR_ID
		)
		SELECT	@NewNUM,
				BR_ID
			FROM CIC_BT_BR WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='AREAS_SERVED') BEGIN
		INSERT INTO CIC_BT_CM (
			NUM,
			CM_ID
		)
		SELECT	@NewNUM,
				CM_ID
			FROM CIC_BT_CM WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO CIC_BT_CM_Notes (
			BT_CM_ID,
			LangID,
			Notes
		)
		SELECT	ck1.BT_CM_ID,
				ck3.LangID,
				ck3.Notes
			FROM CIC_BT_CM ck1
			INNER JOIN CIC_BT_CM ck2
				ON ck2.NUM=@NUM AND ck1.CM_ID=ck2.CM_ID
			INNER JOIN CIC_BT_CM_Notes ck3
				ON ck2.BT_CM_ID=ck3.BT_CM_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='DISTRIBUTION') BEGIN
		INSERT INTO CIC_BT_DST (
			NUM,
			DST_ID
		)
		SELECT	@NewNUM,
				DST_ID
			FROM CIC_BT_DST WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	INSERT INTO CIC_BT_EXTRA_DATE (FieldName, NUM, [Value])
	SELECT cf.FieldName, @NewNUM, [Value]
	FROM CIC_BT_EXTRA_DATE e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.NUM=@NUM

	INSERT INTO CIC_BT_EXTRA_EMAIL (FieldName, NUM, [LangID], [Value])
	SELECT cf.FieldName, @NewNUM, [LangID], [Value]
	FROM CIC_BT_EXTRA_EMAIL e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR [LangID]=@@LANGID)

	INSERT INTO CIC_BT_EXTRA_RADIO (FieldName, NUM, [Value])
	SELECT cf.FieldName, @NewNUM, [Value]
	FROM CIC_BT_EXTRA_RADIO e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.NUM=@NUM

	INSERT INTO CIC_BT_EXTRA_TEXT (FieldName, NUM, [LangID], [Value])
	SELECT cf.FieldName, @NewNUM, [LangID], [Value]
	FROM CIC_BT_EXTRA_TEXT e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR [LangID]=@@LANGID)

	INSERT INTO CIC_BT_EXTRA_WWW (FieldName, NUM, [LangID], [Value])
	SELECT cf.FieldName, @NewNUM, [LangID], [Value]
	FROM CIC_BT_EXTRA_WWW e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR [LangID]=@@LANGID)

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName LIKE 'EXTRA_CHECKLIST_%') BEGIN
		INSERT INTO CIC_BT_EXC (
			FieldName_Cache,
			NUM,
			EXC_ID
		)
		SELECT	FieldName_Cache,
				@NewNUM,
				EXC_ID
			FROM CIC_BT_EXC exc
			INNER JOIN @CopyFields cf
				ON exc.FieldName_Cache=cf.FieldName
			WHERE NUM=@NUM
			
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName LIKE 'EXTRA_DROPDOWN_%') BEGIN
		INSERT INTO CIC_BT_EXD (
			FieldName_Cache,
			NUM,
			EXD_ID
		)
		SELECT	FieldName_Cache,
				@NewNUM,
				EXD_ID
			FROM CIC_BT_EXD exd
			INNER JOIN @CopyFields cf
				ON exd.FieldName_Cache=cf.FieldName
			WHERE NUM=@NUM
			
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='FUNDING') BEGIN
		INSERT INTO CIC_BT_FD (
			NUM,
			FD_ID
		)
		SELECT	@NewNUM,
				FD_ID
			FROM CIC_BT_FD WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO CIC_BT_FD_Notes (
			BT_FD_ID,
			LangID,
			Notes
		)
		SELECT	ck1.BT_FD_ID,
				ck3.LangID,
				ck3.Notes
			FROM CIC_BT_FD ck1
			INNER JOIN CIC_BT_FD ck2
				ON ck2.NUM=@NUM AND ck1.FD_ID=ck2.FD_ID
			INNER JOIN CIC_BT_FD_Notes ck3
				ON ck2.BT_FD_ID=ck3.BT_FD_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='FEES') BEGIN
		INSERT INTO CIC_BT_FT (
			NUM,
			FT_ID
		)
		SELECT	@NewNUM,
				FT_ID
			FROM CIC_BT_FT WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO CIC_BT_FT_Notes (
			BT_FT_ID,
			LangID,
			Notes
		)
		SELECT	ck1.BT_FT_ID,
				ck3.LangID,
				ck3.Notes
			FROM CIC_BT_FT ck1
			INNER JOIN CIC_BT_FT ck2
				ON ck2.NUM=@NUM AND ck1.FT_ID=ck2.FT_ID
			INNER JOIN CIC_BT_FT_Notes ck3
				ON ck2.BT_FT_ID=ck3.BT_FT_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='LANGUAGES') BEGIN
		INSERT INTO CIC_BT_LN (
			NUM,
			LN_ID
		)
		SELECT	@NewNUM,
				LN_ID
			FROM CIC_BT_LN WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO CIC_BT_LN_Notes (
			BT_LN_ID,
			LangID,
			Notes
		)
		SELECT	ck1.BT_LN_ID,
				ck3.LangID,
				ck3.Notes
			FROM CIC_BT_LN ck1
			INNER JOIN CIC_BT_LN ck2
				ON ck2.NUM=@NUM AND ck1.LN_ID=ck2.LN_ID
			INNER JOIN CIC_BT_LN_Notes ck3
				ON ck2.BT_LN_ID=ck3.BT_LN_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO dbo.CIC_BT_LN_LND
		        ( BT_LN_ID, LND_ID )
		SELECT	ck1.BT_LN_ID,
				ck3.LND_ID
			FROM CIC_BT_LN ck1
			INNER JOIN CIC_BT_LN ck2
				ON ck2.NUM=@NUM AND ck1.LN_ID=ck2.LN_ID
			INNER JOIN CIC_BT_LN_LND ck3
				ON ck2.BT_LN_ID=ck3.BT_LN_ID
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='LOCATION_SERVICES') BEGIN
		INSERT INTO GBL_BT_LOCATION_SERVICE (
			LOCATION_NUM,
			SERVICE_NUM
		)
		SELECT	@NewNUM,
				SERVICE_NUM
			FROM GBL_BT_LOCATION_SERVICE WHERE LOCATION_NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='MEMBERSHIP') BEGIN
		INSERT INTO CIC_BT_MT (
			NUM,
			MT_ID
		)
		SELECT	@NewNUM,
				MT_ID
			FROM CIC_BT_MT WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='NAICS') BEGIN
		INSERT INTO CIC_BT_NC (
			NUM,
			Code
		)
		SELECT	@NewNUM,
				Code
			FROM CIC_BT_NC WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='OTHER_ADDRESSES') BEGIN
		INSERT INTO CIC_BT_OTHERADDRESS (
			NUM,
			LangID,
			TITLE,
			SITE_CODE,
			CARE_OF,
			BOX_TYPE,
			PO_BOX,
			BUILDING,
			STREET_NUMBER,
			STREET,
			STREET_TYPE,
			STREET_TYPE_AFTER,
			STREET_DIR,
			SUFFIX,
			CITY,
			PROVINCE,
			COUNTRY,
			POSTAL_CODE,
			MAP_LINK
		)
		SELECT	@NewNUM,
				oa.LangID,
				TITLE,
				SITE_CODE,
				CARE_OF,
				BOX_TYPE,
				PO_BOX,
				BUILDING,
				STREET_NUMBER,
				STREET,
				STREET_TYPE,
				STREET_TYPE_AFTER,
				STREET_DIR,
				SUFFIX,
				CITY,
				PROVINCE,
				COUNTRY,
				POSTAL_CODE,
				MAP_LINK
			FROM CIC_BT_OTHERADDRESS oa
			INNER JOIN GBL_BaseTable_Description btd
				ON btd.NUM=@NewNUM AND oa.LangID=btd.LangID
			WHERE oa.NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR oa.LangID=@@LANGID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='ORG_LOCATION_SERVICE') BEGIN
		INSERT INTO GBL_BT_OLS (
			NUM,
			OLS_ID
		)
		SELECT	@NewNUM,
				OLS_ID
			FROM GBL_BT_OLS WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF @CopyPubs = 1 BEGIN
		DECLARE PublicationCursor CURSOR LOCAL FOR
			SELECT BT_PB_ID
				FROM CIC_BT_PB pr
			WHERE NUM=@NUM
			AND EXISTS(SELECT * FROM CIC_Publication pb
				WHERE pb.PB_ID=pr.PB_ID
					AND (
						pb.MemberID=@MemberID
						OR (pb.MemberID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=pb.PB_ID AND pbi.MemberID=@MemberID))
					)
					AND (
						@LimitedView=1
						OR @CanSeeNonPublicPub=1
						OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=0)
						OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=pb.PB_ID))
					)
				)
		OPEN PublicationCursor
		FETCH NEXT FROM PublicationCursor INTO @BT_ID
		WHILE @@FETCH_STATUS = 0 BEGIN
			INSERT INTO CIC_BT_PB (
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY,
				NUM,
				PB_ID
			)
			SELECT	@MODIFIED_DATE,
					@MODIFIED_BY,
					@MODIFIED_DATE,
					@MODIFIED_BY,
					@NewNUM,
					PB_ID
				FROM CIC_BT_PB
					WHERE BT_PB_ID=@BT_ID
			SET @NEW_BT_ID = SCOPE_IDENTITY()

			INSERT INTO CIC_BT_PB_Description (
				BT_PB_ID,
				LangID,
				Description
			)
			SELECT	@NEW_BT_ID,
					LangID,
					Description
				FROM CIC_BT_PB_Description
					WHERE BT_PB_ID=@BT_ID

			INSERT INTO CIC_BT_PB_GH (
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY,
				BT_PB_ID,
				GH_ID,
				NUM_Cache
			)
			SELECT	@MODIFIED_DATE,
					@MODIFIED_BY,
					@MODIFIED_DATE,
					@MODIFIED_BY,
					@NEW_BT_ID,
					GH_ID,
					@NewNUM
				FROM CIC_BT_PB_GH
					WHERE BT_PB_ID=@BT_ID

			FETCH NEXT FROM PublicationCursor INTO @BT_ID
		END
		CLOSE PublicationCursor
		DEALLOCATE PublicationCursor
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SERVICE_LEVEL') BEGIN
		INSERT INTO CIC_BT_SL (
			NUM,
			SL_ID
		)
		SELECT	@NewNUM,
				SL_ID
			FROM CIC_BT_SL WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SERVICE_LOCATIONS') BEGIN
		INSERT INTO GBL_BT_LOCATION_SERVICE (
			LOCATION_NUM,
			SERVICE_NUM
		)
		SELECT	LOCATION_NUM,
				@NewNUM
			FROM GBL_BT_LOCATION_SERVICE WHERE SERVICE_NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SUBJECTS') BEGIN
		INSERT INTO CIC_BT_SBJ (
			NUM,
			Subj_ID
		)
		SELECT	@NewNUM,
				Subj_ID
			FROM CIC_BT_SBJ WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF @CopyTaxonomy = 1 BEGIN
		DECLARE TaxTermCursor CURSOR LOCAL FOR
			SELECT BT_TAX_ID FROM CIC_BT_TAX WHERE NUM=@NUM
		OPEN TaxTermCursor
		FETCH NEXT FROM TaxTermCursor INTO @BT_ID
		WHILE @@FETCH_STATUS = 0 BEGIN
			INSERT INTO CIC_BT_TAX (
				NUM
			)
			VALUES (
				@NewNUM
			)
			SET @NEW_BT_ID = SCOPE_IDENTITY()
			INSERT INTO CIC_BT_TAX_TM (
				BT_TAX_ID,
				Code
			)
			SELECT	@NEW_BT_ID,
					Code
				FROM CIC_BT_TAX_TM
					WHERE BT_TAX_ID=@BT_ID

			FETCH NEXT FROM TaxTermCursor INTO @BT_ID
		END
		CLOSE TaxTermCursor
		DEALLOCATE TaxTermCursor
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='VACANCY_INFO') BEGIN
		DECLARE VacancyCursor CURSOR LOCAL FOR
			SELECT BT_VUT_ID FROM CIC_BT_VUT WHERE NUM=@NUM
		OPEN VacancyCursor
		FETCH NEXT FROM VacancyCursor INTO @BT_ID
		WHILE @@FETCH_STATUS = 0 BEGIN
			INSERT INTO CIC_BT_VUT (
				NUM,
				VUT_ID,
				Capacity,
				FundedCapacity,
				Vacancy,
				HoursPerDay,
				DaysPerWeek,
				WeeksPerYear,
				FullTimeEquivalent,
				WaitList,
				WaitListDate,
				MODIFIED_DATE

			)
			SELECT	@NewNUM,
					VUT_ID,
					Capacity,
					FundedCapacity,
					Vacancy,
					HoursPerDay,
					DaysPerWeek,
					WeeksPerYear,
					FullTimeEquivalent,
					WaitList,
					WaitListDate,
					MODIFIED_DATE
				FROM CIC_BT_VUT WHERE BT_VUT_ID=@BT_ID
			SET @NEW_BT_ID = SCOPE_IDENTITY()

			INSERT INTO CIC_BT_VUT_Notes (
				BT_VUT_ID,
				LangID,
				ServiceTitle,
				Notes
			)
			SELECT	@NEW_BT_ID,
					LangID,
					ServiceTitle,
					Notes
				FROM CIC_BT_VUT_Notes
					WHERE BT_VUT_ID=@BT_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)

			INSERT INTO CIC_BT_VUT_TP (
				BT_VUT_ID,
				VTP_ID
			)
			SELECT	@NEW_BT_ID,
					VTP_ID
				FROM CIC_BT_VUT_TP
					WHERE BT_VUT_ID=@BT_ID

			FETCH NEXT FROM VacancyCursor INTO @BT_ID
		END
		CLOSE VacancyCursor
		DEALLOCATE VacancyCursor
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='ACTIVITY_INFO') BEGIN
		DECLARE ActivityCursor CURSOR LOCAL FOR
			SELECT BT_ACT_ID FROM CIC_BT_ACT WHERE NUM=@NUM
		OPEN ActivityCursor
		FETCH NEXT FROM ActivityCursor INTO @BT_ID
		WHILE @@FETCH_STATUS = 0 BEGIN
			INSERT INTO CIC_BT_ACT (
				NUM,
				MODIFIED_DATE,
				ASTAT_ID
			)
			SELECT	@NewNUM,
					MODIFIED_DATE,
					ASTAT_ID
				FROM CIC_BT_ACT WHERE BT_ACT_ID=@BT_ID
			SET @NEW_BT_ID = SCOPE_IDENTITY()

			INSERT INTO CIC_BT_ACT_Notes (
				BT_ACT_ID,
				[LangID],
				ActivityName,
				ActivityDescription,
				Notes
			)
			SELECT	@NEW_BT_ID,
					[LangID],
					ActivityName,
					ActivityDescription,
					Notes
				FROM CIC_BT_ACT_Notes
					WHERE BT_ACT_ID=@BT_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)

			FETCH NEXT FROM ActivityCursor INTO @BT_ID
		END
		CLOSE ActivityCursor
		DEALLOCATE ActivityCursor
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='ACCESSIBILITY') BEGIN
		INSERT INTO GBL_BT_AC (
			NUM,
			AC_ID
		)
		SELECT	@NewNUM,
				AC_ID
			FROM GBL_BT_AC WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg

		INSERT INTO GBL_BT_AC_Notes (
			BT_AC_ID,
			LangID,
			Notes
		)
		SELECT	ck1.BT_AC_ID,
				ck3.LangID,
				ck3.Notes
			FROM GBL_BT_AC ck1
			INNER JOIN GBL_BT_AC ck2
				ON ck2.NUM=@NUM AND ck1.AC_ID=ck2.AC_ID
			INNER JOIN GBL_BT_AC_Notes ck3
				ON ck2.BT_AC_ID=ck3.BT_AC_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.NUM=@NewNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='ALT_ORG') BEGIN
		INSERT INTO GBL_BT_ALTORG (
			NUM,
			LangID,
			ALT_ORG,
			PUBLISH
		)
		SELECT	@NewNUM,
				LangID,
				ALT_ORG,
				PUBLISH
			FROM GBL_BT_ALTORG WHERE NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='BILLING_ADDRESSES') BEGIN
		INSERT INTO GBL_BT_BILLINGADDRESS (
			NUM,
			LangID,
			ADDRTYPE,
			SITE_CODE,
			LINE_1,
			LINE_2,
			LINE_3,
			LINE_4,
			CITY,
			PROVINCE,
			COUNTRY,
			POSTAL_CODE
		)
		SELECT	@NewNUM,
				ba.LangID,
				ADDRTYPE,
				SITE_CODE,
				LINE_1,
				LINE_2,
				LINE_3,
				LINE_4,
				CITY,
				PROVINCE,
				COUNTRY,
				POSTAL_CODE
			FROM GBL_BT_BILLINGADDRESS ba
			INNER JOIN GBL_BaseTable_Description btd
				ON btd.NUM=@NewNUM AND ba.LangID=btd.LangID
			WHERE ba.NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR ba.LangID=@@LANGID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='FORMER_ORG') BEGIN
		INSERT INTO GBL_BT_FORMERORG (
			NUM,
			LangID,
			FORMER_ORG,
			DATE_OF_CHANGE,
			PUBLISH
		)
		SELECT	@NewNUM,
				LangID,
				FORMER_ORG,
				DATE_OF_CHANGE,
				PUBLISH
			FROM GBL_BT_FORMERORG WHERE NUM=@NUM AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='MAP_LINK') BEGIN
		INSERT INTO GBL_BT_MAP (
			NUM,
			MAP_ID
		)
		SELECT	@NewNUM,
				MAP_ID
			FROM GBL_BT_MAP WHERE NUM=@NUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SOCIAL_MEDIA') BEGIN
		INSERT INTO GBL_BT_SM(
			NUM,
			SM_ID,
			LangID,
			Protocol,
			URL
		)
		SELECT	@NewNUM,
				SM_ID,
				LangID,
				Protocol,
				URL
			FROM GBL_BT_SM WHERE NUM=@NUM
				AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM CIC_Publication WHERE PB_ID=@AddToPub) 
			AND NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=@NewNUM AND PB_ID=@AddToPub) BEGIN
		INSERT INTO CIC_BT_PB (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			NUM,
			PB_ID
		) VALUES (
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@NewNUM,
			@AddToPub
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END
	
	INSERT INTO CIC_BT_PB (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		NUM,
		PB_ID
	)
	SELECT
		@MODIFIED_DATE,
		@MODIFIED_BY,
		@MODIFIED_DATE,
		@MODIFIED_BY,
		@NewNUM,
		aap.PB_ID
	FROM CIC_View_AutoAddPub aap
	LEFT JOIN CIC_BT_PB btpb
		ON aap.PB_ID=btpb.PB_ID AND btpb.NUM=@NewNUM
	WHERE aap.ViewType=@ViewType AND btpb.PB_ID IS NULL

	Set @FieldList = 'NUM,RECORD_OWNER,NON_PUBLIC,ORG_LEVEL_1,ORG_LEVEL_2,ORG_LEVEL_3,ORG_LEVEL_4,ORG_LEVEL_5' + CASE WHEN @FieldList IS NULL THEN '' ELSE ',' + @FieldList END

	IF @Error = 0 BEGIN
		EXEC sp_CIC_SRCH_u
		EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @NewNUM, @FieldList, 1, NULL
	END

END

RETURN @Error

SET NOCOUNT OFF










GO




GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_i_Copy] TO [cioc_login_role]
GO
