SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_Fld_FindReplace_u]
	@PFLD_RP_ID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Domain tinyint,
	@PFLD_ID [int],
	@RunOrder [tinyint],
	@LookFor [nvarchar](500),
	@ReplaceWith [nvarchar](500),
	@RegEx [bit],
	@MatchCase [bit],
	@MatchAll [bit],
	@LangIDs varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@CommandObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @CommandObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Command')

DECLARE @ProfileID	int
SELECT @ProfileID=ProfileID
	FROM GBL_PrintProfile_Fld pf
WHERE (@PFLD_RP_ID IS NULL AND pf.PFLD_ID=@PFLD_ID)
	OR EXISTS(SELECT * FROM GBL_PrintProfile_Fld_FindReplace fr WHERE pf.PFLD_ID=fr.PFLD_ID AND PFLD_RP_ID=@PFLD_RP_ID)

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @ProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Command ID exists ?
END ELSE IF @PFLD_RP_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile_Fld_FindReplace WHERE PFLD_RP_ID=@PFLD_RP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PFLD_RP_ID AS varchar(20)), @CommandObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=@Domain) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar(20)), @ProfileObjectName)
-- Profile belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Run Order given ?
END ELSE IF @RunOrder IS NULL BEGIN
	SET @Error = 10
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, 'RunOrder', @ProfileObjectName)
-- Look For given ?
END ELSE IF @LookFor IS NULL OR @LookFor = '' BEGIN
	SET @Error = 10
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, 'LookFor', @ProfileObjectName)
END

IF @Error = 0 BEGIN
	IF @PFLD_RP_ID IS NOT NULL BEGIN
		UPDATE GBL_PrintProfile_Fld_FindReplace SET
			RunOrder	= @RunOrder,
			LookFor		= @LookFor,
			ReplaceWith	= @ReplaceWith,
			RegEx		= @RegEx,
			MatchCase	= @MatchCase,
			MatchAll	= @MatchAll
		WHERE PFLD_RP_ID=@PFLD_RP_ID
	END ELSE BEGIN
		INSERT INTO GBL_PrintProfile_Fld_FindReplace (
			PFLD_ID,
			RunOrder,
			LookFor,
			ReplaceWith,
			RegEx,
			MatchCase,
			MatchAll
		) VALUES (
			@PFLD_ID,
			@RunOrder,
			@LookFor,
			@ReplaceWith,
			@RegEx,
			@MatchCase,
			@MatchAll
		)
		SET @PFLD_RP_ID = SCOPE_IDENTITY()
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommandObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		MERGE INTO GBL_PrintProfile_Fld_FindReplace_Lang pfrl
		USING dbo.fn_GBL_ParseIntIDList(@LangIDs, ',') nt
			ON pfrl.PFLD_RP_ID=@PFLD_RP_ID AND nt.ItemID=pfrl.LangID
		WHEN NOT MATCHED BY TARGET AND EXISTS(SELECT * FROM STP_Language WHERE nt.ItemID=LangID AND Active=1) THEN
			INSERT (PFLD_RP_ID, LangID) VALUES (@PFLD_RP_ID, nt.ItemID)
		WHEN NOT MATCHED BY SOURCE AND pfrl.PFLD_RP_ID=@PFLD_RP_ID THEN
			DELETE
			;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommandObjectName, @ErrMsg
	END
	
	IF @Error = 0 BEGIN
		UPDATE GBL_PrintProfile
		SET MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY
		WHERE ProfileID=@ProfileID
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Fld_FindReplace_u] TO [cioc_login_role]
GO
