SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_i_CopyLang]
	@MODIFIED_BY varchar(50),
	@VNUM varchar(10),
	@NewLangID smallint,
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

DECLARE	@OpportunityObjectName nvarchar(60),
		@RecordNumberName nvarchar(60)

SET @OpportunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record')
SET @RecordNumberName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #')

DECLARE	@MODIFIED_DATE datetime
SET @MODIFIED_DATE = GETDATE()

/* Identify errors that will prevent the record from being updated */
-- Record Number provided ?
IF @VNUM IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RecordNumberName, @OpportunityObjectName)
-- Copy Record exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@@LANGID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VNUM, @OpportunityObjectName)
-- Copy To Record exists ?
END ELSE IF EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@NewLangID) BEGIN
	SET @Error = 6 -- Value exists
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, (SELECT LanguageName FROM STP_Language WHERE LangID=@NewLangID), @OpportunityObjectName)
END ELSE BEGIN
	INSERT INTO VOL_Opportunity_Description (
		VNUM,
		LangID,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		NON_PUBLIC,
		POSITION_TITLE,
		ACCESSIBILITY_NOTES,
		ADDITIONAL_REQUIREMENTS,
		BENEFITS,
		CLIENTS,
		COMMITMENT_LENGTH_NOTES,
		COST,
		DUTIES,
		INTERACTION_LEVEL_NOTES,
		LOCATION,
		MORE_INFO_URL,
		NUM_NEEDED_NOTES,
		PROGRAM,
		PUBLIC_COMMENTS,
		SCH_M_Time,
		SCH_TU_Time,
		SCH_W_Time,
		SCH_TH_Time,
		SCH_F_Time,
		SCH_ST_Time,
		SCH_SN_Time,
		SCHEDULE_NOTES,
		SEASONS_NOTES,
		SKILLS_NOTES,
		SOURCE_PUBLICATION,
		SOURCE_PUBLICATION_DATE,
		SOURCE_NAME,
		SOURCE_TITLE,
		SOURCE_ORG,
		SOURCE_PHONE,
		SOURCE_FAX,
		SOURCE_EMAIL,
		TRAINING_NOTES,
		TRANSPORTATION_NOTES
	)
	SELECT 	VNUM,
			@NewLangID,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			1,
			POSITION_TITLE,
			ACCESSIBILITY_NOTES,
			ADDITIONAL_REQUIREMENTS,
			BENEFITS,
			CLIENTS,
			COMMITMENT_LENGTH_NOTES,
			COST,
			DUTIES,
			INTERACTION_LEVEL_NOTES,
			LOCATION,
			MORE_INFO_URL,
			NUM_NEEDED_NOTES,
			PROGRAM,
			PUBLIC_COMMENTS,
			SCH_M_Time,
			SCH_TU_Time,
			SCH_W_Time,
			SCH_TH_Time,
			SCH_F_Time,
			SCH_ST_Time,
			SCH_SN_Time,
			SCHEDULE_NOTES,
			SEASONS_NOTES,
			SKILLS_NOTES,
			SOURCE_PUBLICATION,
			SOURCE_PUBLICATION_DATE,
			SOURCE_NAME,
			SOURCE_TITLE,
			SOURCE_ORG,
			SOURCE_PHONE,
			SOURCE_FAX,
			SOURCE_EMAIL,
			TRAINING_NOTES,
			TRANSPORTATION_NOTES
		FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@@LANGID

	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	IF @Error=0 BEGIN

	INSERT INTO VOL_OP_AC_Notes (
		OP_AC_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_AC_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_AC_Notes n1
		INNER JOIN VOL_OP_AC n2
			ON n1.OP_AC_ID=n2.OP_AC_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_AC_Notes WHERE OP_AC_ID=n1.OP_AC_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	
	INSERT INTO VOL_OP_CL_Notes (
		OP_CL_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_CL_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_CL_Notes n1
		INNER JOIN VOL_OP_CL n2
			ON n1.OP_CL_ID=n2.OP_CL_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_CL_Notes WHERE OP_CL_ID=n1.OP_CL_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	
	INSERT INTO VOL_OP_IL_Notes (
		OP_IL_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_IL_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_IL_Notes n1
		INNER JOIN VOL_OP_IL n2
			ON n1.OP_IL_ID=n2.OP_IL_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_IL_Notes WHERE OP_IL_ID=n1.OP_IL_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	INSERT INTO VOL_OP_SB_Notes (
		OP_SB_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_SB_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_SB_Notes n1
		INNER JOIN VOL_OP_SB n2
			ON n1.OP_SB_ID=n2.OP_SB_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_SB_Notes WHERE OP_SB_ID=n1.OP_SB_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	
	INSERT INTO VOL_OP_SM (
		VNUM,
		LangID,
		SM_ID,
		URL
	)
	SELECT	VNUM,
			@NewLangID,
			SM_ID,
			URL
		FROM VOL_OP_SM s1
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_SM WHERE VNUM=s1.VNUM AND LangID=@NewLangID AND SM_ID=s1.SM_ID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	
	INSERT INTO VOL_OP_SSN_Notes (
		OP_SSN_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_SSN_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_SSN_Notes n1
		INNER JOIN VOL_OP_SSN n2
			ON n1.OP_SSN_ID=n2.OP_SSN_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_SSN_Notes WHERE OP_SSN_ID=n1.OP_SSN_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	
	INSERT INTO VOL_OP_TRN_Notes (
		OP_TRN_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_TRN_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_TRN_Notes n1
		INNER JOIN VOL_OP_TRN n2
			ON n1.OP_TRN_ID=n2.OP_TRN_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_TRN_Notes WHERE OP_TRN_ID=n1.OP_TRN_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg


	INSERT INTO VOL_OP_TRP_Notes (
		OP_TRP_ID,
		LangID,
		Notes
	)
	SELECT	n1.OP_TRP_ID,
			@NewLangID,
			Notes
		FROM VOL_OP_TRP_Notes n1
		INNER JOIN VOL_OP_TRP n2
			ON n1.OP_TRP_ID=n2.OP_TRP_ID
		WHERE VNUM=@VNUM AND LangID=@@LANGID
			AND NOT EXISTS(SELECT * FROM VOL_OP_TRP_Notes WHERE OP_TRP_ID=n1.OP_TRP_ID AND LangID=@NewLangID)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	INSERT INTO VOL_OP_EXTRA_EMAIL (
		FieldName,
		VNUM,
		[LangID],
		[Value]
	)
	SELECT	FieldName,
		VNUM,
		@NewLangID,
		[Value]
		FROM VOL_OP_EXTRA_EMAIL
		WHERE VNUM=@VNUM AND LangID=@@LANGID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	INSERT INTO VOL_OP_EXTRA_TEXT (
		FieldName,
		VNUM,
		[LangID],
		[Value]
	)
	SELECT	FieldName,
		VNUM,
		@NewLangID,
		[Value]
		FROM VOL_OP_EXTRA_TEXT
		WHERE VNUM=@VNUM AND LangID=@@LANGID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	INSERT INTO VOL_OP_EXTRA_WWW (
		FieldName,
		VNUM,
		[LangID],
		[Value]
	)
	SELECT	FieldName,
		VNUM,
		@NewLangID,
		[Value]
		FROM VOL_OP_EXTRA_WWW
		WHERE VNUM=@VNUM AND LangID=@@LANGID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg


	INSERT INTO GBL_Contact (
		VolContactType,
		VolOPDID,
		VolVNUM,
		LangID,
		CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		NAME_HONORIFIC,
		NAME_FIRST,
		NAME_LAST,
		NAME_SUFFIX,
		TITLE,
		ORG,
		EMAIL,
		FAX_NOTE,
		FAX_NO,
		FAX_EXT,
		FAX_CALLFIRST,
		PHONE_1_TYPE,
		PHONE_1_NOTE,
		PHONE_1_NO,
		PHONE_1_EXT,
		PHONE_1_OPTION,
		PHONE_2_TYPE,
		PHONE_2_NOTE,
		PHONE_2_NO,
		PHONE_2_EXT,
		PHONE_2_OPTION,
		PHONE_3_TYPE,
		PHONE_3_NOTE,
		PHONE_3_NO,
		PHONE_3_EXT,
		PHONE_3_OPTION
	)
	SELECT
		VolContactType,
		vod.OPD_ID,
		VolVNUM,
		@NewLangID,
		@MODIFIED_DATE, @MODIFIED_BY, @MODIFIED_DATE, @MODIFIED_BY,
		NAME_HONORIFIC,
		NAME_FIRST,
		NAME_LAST,
		NAME_SUFFIX,
		TITLE,
		ORG,
		EMAIL,
		FAX_NOTE,
		FAX_NO,
		FAX_EXT,
		FAX_CALLFIRST,
		PHONE_1_TYPE,
		PHONE_1_NOTE,
		PHONE_1_NO,
		PHONE_1_EXT,
		PHONE_1_OPTION,
		PHONE_2_TYPE,
		PHONE_2_NOTE,
		PHONE_2_NO,
		PHONE_2_EXT,
		PHONE_2_OPTION,
		PHONE_3_TYPE,
		PHONE_3_NOTE,
		PHONE_3_NO,
		PHONE_3_EXT,
		PHONE_3_OPTION
		FROM GBL_Contact rn
		INNER JOIN VOL_Opportunity_Description vod
			ON rn.VolVNUM=vod.VNUM AND vod.LangID=@NewLangID
		WHERE VolVNUM=@VNUM AND rn.LangID=@@LANGID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg
	
	INSERT INTO GBL_RecordNote (
		VolNoteType,
		VolOPDID,
		VolVNUM,
		LangID,
		CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY,
		CANCELLED_DATE, CANCELLED_BY, CancelError,
		NoteTypeID,
		Value
	)
	SELECT
		VolNoteType,
		vod.OPD_ID,
		VolVNUM,
		@NewLangID,
		rn.CREATED_DATE, rn.CREATED_BY, rn.MODIFIED_DATE, rn.MODIFIED_BY,
		CANCELLED_DATE, CANCELLED_BY, CancelError,
		NoteTypeID,
		Value
		FROM GBL_RecordNote rn
		INNER JOIN VOL_Opportunity_Description vod
			ON rn.VolVNUM=vod.VNUM AND vod.LangID=@NewLangID
		WHERE VolVNUM=@VNUM AND rn.LangID=@@LANGID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OpportunityObjectName, @ErrMsg

	END
	
	IF @Error = 0 BEGIN
		EXEC sp_VOL_Opportunity_History_i @MODIFIED_BY, @MODIFIED_DATE, @VNUM, NULL, 0, @NewLangID
	END
	
END

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_i_CopyLang] TO [cioc_login_role]
GO
