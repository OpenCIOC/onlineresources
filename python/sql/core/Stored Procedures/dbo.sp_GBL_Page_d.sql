SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_Page_d] (
	@MemberID [int],
	@AgencyCode char(3),
	@DM tinyint,
	@PageID int,
	@ErrMsg nvarchar(500) OUTPUT
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: CL
	Checked on: 04-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@PageObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @PageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Page')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @PageObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Page ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Page WHERE PageID=@PageID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PageID AS varchar(20)), @PageObjectName)
-- Page belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Page WHERE PageID=@PageID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Page belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Page WHERE PageID=@PageID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PageObjectName, NULL)
END ELSE BEGIN

DELETE 
FROM GBL_Page
WHERE PageID=@PageID AND MemberID=@MemberID AND DM=@DM AND (Owner IS NULL OR Owner=@AgencyCode)

END



RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Page_d] TO [cioc_login_role]
GO
