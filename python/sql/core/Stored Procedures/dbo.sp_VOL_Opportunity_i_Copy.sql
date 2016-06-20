
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_i_Copy]
	@MemberID [int],
	@MODIFIED_BY varchar(50),
	@VNUM varchar(10),
	@AutoVNUM bit,
	@NewVNUM varchar(10) OUTPUT,
	@Owner char(3),
	@POSITION_TITLE nvarchar(150),
	@FieldList varchar(max),
	@AddToSet int,
	@CopyOnlyCurrentLang bit,
	@MakeNonPublic bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@OpportunityObjectName nvarchar(100),
		@RecordNumberName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @OpportunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record')
SET @RecordNumberName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #')

SET @VNUM = RTRIM(LTRIM(@VNUM))
SET @NewVNUM = RTRIM(LTRIM(@NewVNUM))

DECLARE @CheckVNUM bit, 
		@NEW__ID int,
		@MODIFIED_DATE datetime,
		@BaseTableFieldList varchar(max),
		@SQL nvarchar(max),
		@ParamList nvarchar(max)

DECLARE @CopyFields TABLE (
	FieldName varchar(100) COLLATE Latin1_General_100_CI_AI NOT NULL,
	ExtraFieldType char(1) NULL,
	EquivalentSource bit NOT NULL,
	UpdateFieldList varchar(max) COLLATE Latin1_General_100_CI_AI NULL
)

SET @MODIFIED_DATE = GETDATE()

EXEC @CheckVNUM = sp_VOL_UCheck_VNUM NULL, @NewVNUM OUTPUT, @Owner

SET @POSITION_TITLE = RTRIM(LTRIM(@POSITION_TITLE))
IF @POSITION_TITLE = '' SET @POSITION_TITLE = NULL

/* Identify errors that will prevent the record from being updated */
-- Record Number provided ?
IF @VNUM IS NULL OR @VNUM = '' OR @NewVNUM IS NULL OR @NewVNUM = '' BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RecordNumberName, @OpportunityObjectName)
-- Record Number already in use ?
END ELSE IF @CheckVNUM = 1 BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NewVNUM, @RecordNumberName)
-- Copy Record exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VNUM, @OpportunityObjectName)
END ELSE BEGIN

	INSERT INTO @CopyFields
	SELECT DISTINCT
		FieldName,
		ExtraFieldType,
		EquivalentSource,
		CASE
			WHEN FieldName IN ('CONTACT','INTERNAL_MEMO','SOCIAL_MEDIA') THEN NULL
			WHEN FormFieldType <> 'f' THEN FieldName
			ELSE CASE WHEN EquivalentSource=0 THEN REPLACE(UpdateFieldList,'vo.','') ELSE REPLACE(UpdateFieldList,'vod.','') END
		END AS UpdateFieldList
	FROM VOL_FieldOption fo
	WHERE CanUseUpdate=1
		AND EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@FieldList,',') tm WHERE tm.ItemID=fo.FieldName COLLATE Latin1_General_100_CI_AI)
		AND FieldName NOT IN ('VNUM','RECORD_OWNER','NUM','POSITION_TITLE','NON_PUBLIC')
	ORDER BY FieldName

	SET @FieldList = NULL

	SELECT @FieldList = COALESCE(@FieldList + ',','') + FieldName
		FROM @CopyFields

	DECLARE @FieldName varchar(100),
			@OldFieldList varchar(max),
			@NewFieldList varchar(max),
			@NewFieldListD varchar(max)

	DECLARE Lang_Cursor CURSOR STATIC FOR
	SELECT FieldName, UpdateFieldList FROM @CopyFields cf WHERE UpdateFieldList LIKE 'vo.%' AND EquivalentSource=1

	OPEN Lang_Cursor

	FETCH NEXT FROM Lang_Cursor INTO @FieldName, @OldFieldList
		WHILE @@FETCH_STATUS = 0 BEGIN

		SET @NewFieldList = NULL
		SET @NewFieldListD = NULL

		SELECT @NewFieldList = COALESCE(@NewFieldList + ',','') + REPLACE(ItemID,'vo.','') FROM dbo.fn_GBL_ParseVarCharIDList(@OldFieldList,',') WHERE ItemID LIKE 'vo.%'
		SELECT @NewFieldListD = COALESCE(@NewFieldListD + ',','') + ItemID FROM dbo.fn_GBL_ParseVarCharIDList(@OldFieldList,',') WHERE ItemID NOT LIKE 'vo.%'

		UPDATE @CopyFields SET UpdateFieldList=@NewFieldListD WHERE FieldName=@FieldName

		INSERT INTO @CopyFields
			SELECT FieldName, ExtraFieldType, 0, @NewFieldList
		FROM @CopyFields WHERE FieldName=@FieldName

		FETCH NEXT FROM Lang_Cursor INTO @FieldName, @OldFieldList
	END

	CLOSE Lang_Cursor

	DEALLOCATE Lang_Cursor

	/* VOL_Opportunity */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE EquivalentSource=0 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL
	
	SET @ParamList = N'@MemberID int, @VNUM varchar(10), @NewVNUM varchar(10), @MODIFIED_DATE datetime, @MODIFIED_BY varchar(50), @Owner char(3)'

	SET @SQL = 'INSERT INTO VOL_Opportunity (MemberID, VNUM, NUM, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, RECORD_OWNER
		' + CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	)
	SELECT @MemberID, @NewVNUM, NUM, @MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY, ISNULL(@Owner,RECORD_OWNER)
	' + CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	FROM VOL_Opportunity WHERE VNUM=@VNUM'
		
	EXEC sp_executeSQL @SQL, @ParamList, @MemberID=@MemberID, @VNUM=@VNUM, @NewVNUM=@NewVNUM, @MODIFIED_DATE=@MODIFIED_DATE, @MODIFIED_BY=@MODIFIED_BY, @Owner=@Owner

	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	/* VOL_Opportunity_Description */
	SET @BaseTableFieldList = NULL

	SELECT @BaseTableFieldList = COALESCE(@BaseTableFieldList + ',','') + UpdateFieldList
	FROM @CopyFields WHERE EquivalentSource=1 AND UpdateFieldList IS NOT NULL AND ExtraFieldType IS NULL

	SET @SQL = 'INSERT INTO VOL_Opportunity_Description (VNUM, LangID, NON_PUBLIC, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		POSITION_TITLE'
		+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	)
	SELECT ''' + CAST(@NewVNUM AS varchar) + ''',LangID,' + CAST(@MakeNonPublic AS varchar) + ',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''',''' + CONVERT(varchar(23), @MODIFIED_DATE, 126) + ''',''' + @MODIFIED_BY + ''''
		+ ',''' + REPLACE(@POSITION_TITLE,'''','''''') + ''''
		+ CASE WHEN @BaseTableFieldList IS NULL THEN '' ELSE ',' + @BaseTableFieldList END + '
	FROM VOL_Opportunity_Description WHERE VNUM=''' + @VNUM + '''' + CASE WHEN @CopyOnlyCurrentLang=0 THEN '' ELSE ' AND LangID=@@LANGID' END
	
	EXEC(@SQL)
	
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	INSERT INTO GBL_Contact(
		CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		VolContactType, VolOPDID, VolVNUM, LangID, 
		NAME_HONORIFIC, NAME_FIRST, NAME_LAST, NAME_SUFFIX,
		TITLE, ORG, EMAIL,
		FAX_NOTE, FAX_NO, FAX_EXT, FAX_CALLFIRST,
		PHONE_1_TYPE, PHONE_1_NOTE, PHONE_1_NO, PHONE_1_EXT, PHONE_1_OPTION,
		PHONE_2_TYPE, PHONE_2_NOTE, PHONE_2_NO, PHONE_2_EXT, PHONE_2_OPTION,
		PHONE_3_TYPE, PHONE_3_NOTE, PHONE_3_NO, PHONE_3_EXT, PHONE_3_OPTION
	) SELECT
		@MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY,
		cf.FieldName, vod.OPD_ID, @NewVNUM, c.LangID,
		NAME_HONORIFIC, NAME_FIRST, NAME_LAST, NAME_SUFFIX,
		TITLE, ORG, EMAIL,
		FAX_NOTE, FAX_NO, FAX_EXT, FAX_CALLFIRST,
		PHONE_1_TYPE, PHONE_1_NOTE, PHONE_1_NO, PHONE_1_EXT, PHONE_1_OPTION,
		PHONE_2_TYPE, PHONE_2_NOTE, PHONE_2_NO, PHONE_2_EXT, PHONE_2_OPTION,
		PHONE_3_TYPE, PHONE_3_NOTE, PHONE_3_NO, PHONE_3_EXT, PHONE_3_OPTION
	FROM GBL_Contact c
	INNER JOIN @CopyFields cf
		ON c.VolContactType=cf.FieldName
	INNER JOIN VOL_Opportunity_Description vod
		ON vod.VNUM=@NewVNUM AND c.LangID=vod.LangID
	WHERE c.VolVNUM=@VNUM AND (@CopyOnlyCurrentLang=0 OR c.LangID=@@LANGID)
	
	INSERT INTO GBL_RecordNote(
		CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		VolNoteType, VolOPDID, VolVNUM, LangID,
		CANCELLED_DATE, CANCELLED_BY, CancelError,
		NoteTypeID,
		Value
	) SELECT
		@MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY,
		cf.FieldName, vod.OPD_ID, @NewVNUM, c.LangID,
		CANCELLED_DATE, CANCELLED_BY, CancelError,
		NoteTypeID,
		Value
	FROM GBL_RecordNote c
	INNER JOIN @CopyFields cf
		ON c.VolNoteType=cf.FieldName
	INNER JOIN VOL_Opportunity_Description vod
		ON vod.VNUM=@NewVNUM AND c.LangID=vod.LangID
	WHERE c.VolVNUM=@VNUM AND (@CopyOnlyCurrentLang=0 OR c.LangID=@@LANGID)

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='ACCESSIBILITY') BEGIN
		INSERT INTO VOL_OP_AC (
			VNUM,
			AC_ID
		)
		SELECT	@NewVNUM,
				AC_ID
			FROM VOL_OP_AC WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_AC_Notes (
			OP_AC_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_AC_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_AC ck1
			INNER JOIN VOL_OP_AC ck2
				ON ck2.VNUM=@VNUM AND ck1.AC_ID=ck2.AC_ID
			INNER JOIN VOL_OP_AC_Notes ck3
				ON ck2.OP_AC_ID=ck3.OP_AC_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='INTERESTS') BEGIN
		INSERT INTO VOL_OP_AI (
			VNUM,
			AI_ID
		)
		SELECT	@NewVNUM,
				AI_ID
			FROM VOL_OP_AI WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='COMMITMENT_LENGTH') BEGIN
		INSERT INTO VOL_OP_CL (
			VNUM,
			CL_ID
		)
		SELECT	@NewVNUM,
				CL_ID
			FROM VOL_OP_CL WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_CL_Notes (
			OP_CL_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_CL_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_CL ck1
			INNER JOIN VOL_OP_CL ck2
				ON ck2.VNUM=@VNUM AND ck1.CL_ID=ck2.CL_ID
			INNER JOIN VOL_OP_CL_Notes ck3
				ON ck2.OP_CL_ID=ck3.OP_CL_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='NUM_NEEDED') BEGIN
		INSERT INTO VOL_OP_CM (
			VNUM,
			CM_ID,
			NUM_NEEDED
		)
		SELECT	@NewVNUM,
				CM_ID,
				NUM_NEEDED
			FROM VOL_OP_CM WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='INTERACTION_LEVEL') BEGIN
		INSERT INTO VOL_OP_IL (
			VNUM,
			IL_ID
		)
		SELECT	@NewVNUM,
				IL_ID
			FROM VOL_OP_IL WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_IL_Notes (
			OP_IL_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_IL_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_IL ck1
			INNER JOIN VOL_OP_IL ck2
				ON ck2.VNUM=@VNUM AND ck1.IL_ID=ck2.IL_ID
			INNER JOIN VOL_OP_IL_Notes ck3
				ON ck2.OP_IL_ID=ck3.OP_IL_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SUITABILITY') BEGIN
		INSERT INTO VOL_OP_SB (
			VNUM,
			SB_ID
		)
		SELECT	@NewVNUM,
				SB_ID
			FROM VOL_OP_SB WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_SB_Notes (
			OP_SB_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_SB_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_SB ck1
			INNER JOIN VOL_OP_SB ck2
				ON ck2.VNUM=@VNUM AND ck1.SB_ID=ck2.SB_ID
			INNER JOIN VOL_OP_SB_Notes ck3
				ON ck2.OP_SB_ID=ck3.OP_SB_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SOCIAL_MEDIA') BEGIN
		INSERT INTO VOL_OP_SM(
			VNUM,
			SM_ID,
			LangID,
			URL
		)
		SELECT	@NewVNUM,
				SM_ID,
				LangID,
				URL
			FROM VOL_OP_SM WHERE VNUM=@VNUM
				AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='SEASONS') BEGIN
		INSERT INTO VOL_OP_SSN (
			VNUM,
			SSN_ID
		)
		SELECT	@NewVNUM,
				SSN_ID
			FROM VOL_OP_SSN WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_SSN_Notes (
			OP_SSN_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_SSN_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_SSN ck1
			INNER JOIN VOL_OP_SSN ck2
				ON ck2.VNUM=@VNUM AND ck1.SSN_ID=ck2.SSN_ID
			INNER JOIN VOL_OP_SSN_Notes ck3
				ON ck2.OP_SSN_ID=ck3.OP_SSN_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='TRAINING') BEGIN
		INSERT INTO VOL_OP_TRN (
			VNUM,
			TRN_ID
		)
		SELECT	@NewVNUM,
				TRN_ID
			FROM VOL_OP_TRN WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_TRN_Notes (
			OP_TRN_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_TRN_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_TRN ck1
			INNER JOIN VOL_OP_TRN ck2
				ON ck2.VNUM=@VNUM AND ck1.TRN_ID=ck2.TRN_ID
			INNER JOIN VOL_OP_TRN_Notes ck3
				ON ck2.OP_TRN_ID=ck3.OP_TRN_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName='TRANSPORTATION') BEGIN
		INSERT INTO VOL_OP_TRP (
			VNUM,
			TRP_ID
		)
		SELECT	@NewVNUM,
				TRP_ID
			FROM VOL_OP_TRP WHERE VNUM=@VNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

		INSERT INTO VOL_OP_TRP_Notes (
			OP_TRP_ID,
			LangID,
			Notes
		)
		SELECT	ck1.OP_TRP_ID,
				ck3.LangID,
				ck3.Notes
			FROM VOL_OP_TRP ck1
			INNER JOIN VOL_OP_TRP ck2
				ON ck2.VNUM=@VNUM AND ck1.TRP_ID=ck2.TRP_ID
			INNER JOIN VOL_OP_TRP_Notes ck3
				ON ck2.OP_TRP_ID=ck3.OP_TRP_ID AND (@CopyOnlyCurrentLang=0 OR LangID=@@LANGID)
			WHERE ck1.VNUM=@NewVNUM
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END

	INSERT INTO VOL_OP_EXTRA_DATE (FieldName, VNUM, [Value])
	SELECT cf.FieldName, @NewVNUM, [Value]
	FROM VOL_OP_EXTRA_DATE e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.VNUM=@VNUM

	INSERT INTO VOL_OP_EXTRA_EMAIL (FieldName, VNUM, [LangID], [Value])
	SELECT cf.FieldName, @NewVNUM, [LangID], [Value]
	FROM VOL_OP_EXTRA_EMAIL e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.VNUM=@VNUM AND (@CopyOnlyCurrentLang=0 OR [LangID]=@@LANGID)

	INSERT INTO VOL_OP_EXTRA_RADIO (FieldName, VNUM, [Value])
	SELECT cf.FieldName, @NewVNUM, [Value]
	FROM VOL_OP_EXTRA_RADIO e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.VNUM=@VNUM

	INSERT INTO VOL_OP_EXTRA_TEXT (FieldName, VNUM, [LangID], [Value])
	SELECT cf.FieldName, @NewVNUM, [LangID], [Value]
	FROM VOL_OP_EXTRA_TEXT e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.VNUM=@VNUM AND (@CopyOnlyCurrentLang=0 OR [LangID]=@@LANGID)

	INSERT INTO VOL_OP_EXTRA_WWW (FieldName, VNUM, [LangID], [Value])
	SELECT cf.FieldName, @NewVNUM, [LangID], [Value]
	FROM VOL_OP_EXTRA_WWW e
	INNER JOIN @CopyFields cf
		ON e.FieldName=cf.FieldName
	WHERE e.VNUM=@VNUM AND (@CopyOnlyCurrentLang=0 OR [LangID]=@@LANGID)

	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName LIKE 'EXTRA_CHECKLIST_%') BEGIN
		INSERT INTO VOL_OP_EXC (
			FieldName_Cache,
			VNUM,
			EXC_ID
		)
		SELECT	FieldName_Cache,
				@NewVNUM,
				EXC_ID
			FROM VOL_OP_EXC exc
			INNER JOIN @CopyFields cf
				ON exc.FieldName_Cache=cf.FieldName
			WHERE VNUM=@VNUM
			
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM @CopyFields WHERE FieldName LIKE 'EXTRA_DROPDOWN_%') BEGIN
		INSERT INTO VOL_OP_EXD (
			FieldName_Cache,
			VNUM,
			EXD_ID
		)
		SELECT	FieldName_Cache,
				@NewVNUM,
				EXD_ID
			FROM VOL_OP_EXD exd
			INNER JOIN @CopyFields cf
				ON exd.FieldName_Cache=cf.FieldName
			WHERE VNUM=@VNUM
			
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END
	
	IF EXISTS(SELECT * FROM VOL_CommunitySet WHERE CommunitySetID=@AddToSet) 
			AND NOT EXISTS(SELECT * FROM VOL_OP_CommunitySet WHERE VNUM=@NewVNUM AND CommunitySetID=@AddToSet) BEGIN
		INSERT INTO VOL_OP_CommunitySet (
			VNUM,
			CommunitySetID
		) VALUES (
			@NewVNUM,
			@AddToSet
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	END

	Set @FieldList = 'VNUM,NUM,RECORD_OWNER,NON_PUBLIC,COMMUNITY_SETS' + CASE WHEN @FieldList IS NULL THEN '' ELSE ',' + @FieldList END

	IF @Error = 0 BEGIN
		EXEC sp_VOL_Opportunity_History_i @MODIFIED_BY, @MODIFIED_DATE, @NewVNUM, @FieldList, 1, NULL
	END

END

RETURN @Error

SET NOCOUNT OFF







GO



GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_i_Copy] TO [cioc_login_role]
GO
