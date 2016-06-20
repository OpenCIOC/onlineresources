SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_i_Lang]
	@ViewType [int],
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@AgencyCode [char](3),
	@LangID smallint,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action:	NO ACTION REQUIRED
*/


DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')



-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- Language given ?
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ViewObjectName)
-- Language is active ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Language WHERE LangID=@LangID AND Active=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), @LanguageObjectName)
-- Language already in record ?
END ELSE IF EXISTS(SELECT * FROM CIC_View_Description WHERE ViewType=@ViewType AND LangID=@LangID) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), @LanguageObjectName)
END ELSE BEGIN

	INSERT INTO CIC_View_Description (
		ViewType, LangID, CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE, ViewName
		)
	SELECT TOP 1 @ViewType, @LangID, @MODIFIED_BY, GETDATE(), @MODIFIED_BY, GETDATE(), ViewName
		FROM CIC_View_Description
	WHERE @ViewType=ViewType
	ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

END

RETURN @Error

SET NOCOUNT OFF













GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_i_Lang] TO [cioc_login_role]
GO
