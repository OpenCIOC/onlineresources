SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_i]
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@ProfileName [varchar](50),
	@Domain [tinyint],
	@ProfileID [int] OUTPUT,
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 08-Jun-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE @MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@NameObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

DECLARE	@CopyProfileID	int
SET @ProfileName = RTRIM(LTRIM(@ProfileName))

SET @CopyProfileID = @ProfileID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile name given ?
END ELSE IF @ProfileName IS NULL OR @ProfileName = '' BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Copy Profile exists ?
END ELSE IF @CopyProfileID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@CopyProfileID AND Domain=@Domain) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CopyProfileID AS varchar), @ProfileObjectName)
-- Copy Profile belongs to Member ?
END ELSE IF @CopyProfileID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@CopyProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Name is not already in use ?
END ELSE IF EXISTS (SELECT * FROM GBL_PrintProfile pp INNER JOIN GBL_PrintProfile_Description ppd ON pp.ProfileID=ppd.ProfileID WHERE Domain=@Domain AND ProfileName = @ProfileName AND (@CopyProfileID IS NOT NULL OR LangID=@@LANGID)) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileName, @NameObjectName)
END ELSE BEGIN
	IF @CopyProfileID IS NOT NULL BEGIN
		INSERT INTO GBL_PrintProfile (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Domain,
			StyleSheet,
			TableClass,
			MsgBeforeRecord,
			[Public],
			Separator,
			PageBreak
		) SELECT 
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@Domain,
			StyleSheet,
			TableClass,
			MsgBeforeRecord,
			[Public],
			Separator,
			PageBreak
		FROM GBL_PrintProfile
		WHERE ProfileID=@ProfileID
		SELECT @ProfileID = SCOPE_IDENTITY()
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
		
		IF @Error = 0 BEGIN
			INSERT INTO GBL_PrintProfile_Description (
				ProfileID,
				LangID,
				MemberID_Cache,
				ProfileName,
				PageTitle,
				Header,
				Footer,
				DefaultMsg
			)
			SELECT
				@ProfileID,
				LangID,
				@MemberID,
				@ProfileName,
				PageTitle,
				Header,
				Footer,
				DefaultMsg
			FROM GBL_PrintProfile_Description 
				WHERE ProfileID=@CopyProfileID
			
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
		END
		
	END ELSE BEGIN
		INSERT INTO GBL_PrintProfile (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Domain
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@Domain
		)
		SELECT @ProfileID = SCOPE_IDENTITY()
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
		
		IF @Error = 0 BEGIN
			INSERT INTO GBL_PrintProfile_Description 
			(ProfileID, LangID, MemberID_Cache, ProfileName) VALUES (@ProfileID, @@LANGID, @MemberID, @ProfileName)
			
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
		END
		
	END
	IF @Error=0 AND @CopyProfileID IS NOT NULL BEGIN
		DECLARE @IDMap TABLE (
			Old int NOT NULL,
			New int NOT NULL
		)
		MERGE INTO GBL_PrintProfile_Fld dst
		USING GBL_PrintProfile_Fld src
			ON 1=0
		WHEN NOT MATCHED BY TARGET AND src.ProfileID=@CopyProfileID THEN
			INSERT (
				ProfileID,
				GBLFieldID,
				VOLFieldID,
				FieldTypeID,
				HeadingLevel,
				LabelStyle,
				ContentStyle,
				Separator,
				DisplayOrder
			) VALUES (
				@ProfileID,
				src.GBLFieldID,
				src.VOLFieldID,
				src.FieldTypeID,
				src.HeadingLevel,
				src.LabelStyle,
				src.ContentStyle,
				src.Separator,
				src.DisplayOrder			
			)
		OUTPUT src.PFLD_ID, INSERTED.PFLD_ID INTO @IDMap
			;
			
		INSERT INTO GBL_PrintProfile_Fld_Description
		SELECT map.New, LangID, Label, Prefix, Suffix, ContentIfEmpty
			FROM GBL_PrintProfile_Fld_Description pfld
			INNER JOIN @IDMap map
				ON map.Old=pfld.PFLD_ID
			
		DECLARE @FRIDMap TABLE (
			Old int NOT NULL,
			New int NOT NULL
		)
		
		MERGE INTO GBL_PrintProfile_Fld_FindReplace dst
		USING (SELECT map.New, fr.*
				FROM GBL_PrintProfile_Fld_FindReplace fr
				INNER JOIN @IDMap map
					ON fr.PFLD_ID=map.Old) src
			ON 1=0
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (PFLD_ID, LookFor, ReplaceWith, RunOrder, RegEx, MatchCase, MatchAll)
				VALUES (src.New, src.LookFor, src.ReplaceWith, src.RunOrder, src.RegEx, src.MatchCase, src.MatchAll)
				
		OUTPUT src.PFLD_RP_ID, INSERTED.PFLD_RP_ID INTO @FRIDMap
			;
			
		INSERT INTO GBL_PrintProfile_Fld_FindReplace_Lang
		SELECT map.New, LangID
			FROM GBL_PrintProfile_Fld_FindReplace_Lang lng
			INNER JOIN @FRIDMap map
				ON map.Old=lng.PFLD_RP_ID

	END
END

RETURN @Error

SET NOCOUNT OFF


GO
