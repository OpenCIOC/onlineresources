SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StreetType_i]
	@MODIFIED_BY varchar(50),
	@StreetType nvarchar(20),
	@LangID smallint,
	@AfterName bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 23-Dec-2011
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@StreetTypeObjectName nvarchar(100), 
		@LanguageObjectName nvarchar(100)

SET @StreetTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Street Type')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

SET @StreetType = RTRIM(LTRIM(@StreetType))
IF @StreetType = '' SET @StreetType = NULL

IF @StreetType IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @StreetTypeObjectName, @StreetTypeObjectName)
END ELSE IF EXISTS (SELECT * FROM GBL_StreetType WHERE StreetType = @StreetType AND LangID=@LangID AND AfterName = @AfterName) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @StreetType, @StreetTypeObjectName)
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @StreetTypeObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM STP_Language WHERE [LangID]=@LangID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), @LanguageObjectName)
END ELSE BEGIN
	INSERT GBL_StreetType (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		StreetType,
		LangID,
		AfterName
	)
	VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@StreetType,
		@LangID,
		@AfterName
	)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @StreetTypeObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_i] TO [cioc_login_role]
GO
