SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SearchTips_u]
	@SearchTipsID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@LangID smallint,
	@Domain tinyint,
	@PageTitle nvarchar(50),
	@PageText nvarchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@SearchTipsObjectName nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SearchTipsObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Search Tips')

SET @PageTitle = RTRIM(LTRIM(@PageTitle))
IF @PageTitle = '' SET @PageTitle = NULL
SET @PageText = RTRIM(LTRIM(@PageText))
IF @PageText = '' SET @PageText = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Search Tips exists ?
END ELSE IF @SearchTipsID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_SearchTips WHERE SearchTipsID=@SearchTipsID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SearchTipsID AS varchar), @SearchTipsObjectName)
-- Search Tips belongs to Member ?
END ELSE IF @SearchTipsID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_SearchTips WHERE SearchTipsID=@SearchTipsID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Page Title given ?
END ELSE IF @PageTitle IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'), @SearchTipsObjectName)
-- Page Title is unique ?
END ELSE IF EXISTS (SELECT * FROM GBL_SearchTips WHERE (@SearchTipsID IS NULL OR SearchTipsID<>@SearchTipsID) AND PageTitle=@PageTitle AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PageTitle, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'))
-- Language given ?
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'), @SearchTipsObjectName)
-- Language exists ?
END ELSE IF @LangID IS NOT NULL AND NOT EXISTS (SELECT * FROM STP_Language WHERE LangID = @LangID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'))
END

IF @Error = 0 BEGIN
	IF @SearchTipsID IS NOT NULL BEGIN
		UPDATE GBL_SearchTips
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			PageTitle		= @PageTitle,
			PageText		= @PageText
		WHERE (SearchTipsID = @SearchTipsID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SearchTipsObjectName, @ErrMsg
	END ELSE BEGIN
		INSERT INTO GBL_SearchTips (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			LangID,
			Domain,
			PageTitle,
			PageText
		) 
 		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@LangID,
			@Domain,
			@PageTitle,
			@PageText
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SearchTipsObjectName, @ErrMsg
		SET @SearchTipsID = SCOPE_IDENTITY()
	END
END

RETURN @Error



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SearchTips_u] TO [cioc_login_role]
GO
