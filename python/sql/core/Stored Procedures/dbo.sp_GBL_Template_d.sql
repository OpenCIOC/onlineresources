SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_d]
	@Template_ID [int] OUTPUT,
	@MemberID int,
	@AgencyCode [char](3),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@DesignTemplateObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @DesignTemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Design Template')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Template given ?
END ELSE IF @Template_ID IS NULL BEGIN
	SET @Error = 10 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DesignTemplateObjectName, NULL)
-- Template exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Template_ID AS varchar), @DesignTemplateObjectName)
-- Not a System Template ?
END ELSE IF EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID AND SystemTemplate=1) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('System Template'), NULL)
-- Template belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DesignTemplateObjectName, NULL)
-- In use by a View ?
END ELSE IF EXISTS(SELECT * FROM CIC_View WHERE Template=@Template_ID OR PrintTemplate=@Template_ID) 
		OR EXISTS(SELECT * FROM VOL_View WHERE Template=@Template_ID OR PrintTemplate=@Template_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DesignTemplateObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
-- In use by a Member ?
END ELSE IF EXISTS(SELECT * FROM STP_Member WHERE DefaultTemplate=@Template_ID OR DefaultPrintTemplate=@Template_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DesignTemplateObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('General Setup Options'))
END

IF @Error = 0 BEGIN
	DELETE FROM GBL_Template
	WHERE Template_ID=@Template_ID
		
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_d] TO [cioc_login_role]
GO
