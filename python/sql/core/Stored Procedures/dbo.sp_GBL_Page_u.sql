SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Page_u]
	@PageID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@DM tinyint,
	@AgencyCode char(3),
	@Culture varchar(5),
	@Slug varchar(50),
	@Title nvarchar(200),
	@Owner char(3),
	@PageContent nvarchar(MAX),
	@ViewList varchar(MAX),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: CL
	Checked on: 08-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@PageObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @PageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Page')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

SET @Slug = RTRIM(LTRIM(@Slug))
SET @Title = RTRIM(LTRIM(@Title))
SET @PageContent = RTRIM(LTRIM(@PageContent))

DECLARE @ViewIDs table (
	ViewType int NOT NULL
)

IF @DM=1 BEGIN
	INSERT INTO @ViewIDs 
	SELECT tm.ItemID
		FROM fn_GBL_ParseIntIDList(@ViewList, ',') tm
		INNER JOIN CIC_View vw
			ON vw.ViewType = tm.ItemID
				AND (vw.MemberID IS NULL OR vw.MemberID=@MemberID)
				AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
END ELSE BEGIN
	INSERT INTO @ViewIDs 
	SELECT tm.ItemID
		FROM fn_GBL_ParseIntIDList(@ViewList, ',') tm
		INNER JOIN VOL_View vw
			ON vw.ViewType = tm.ItemID
				AND (vw.MemberID IS NULL OR vw.MemberID=@MemberID)
				AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
END


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @PageObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Page ID exists ?
END ELSE IF @PageID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Page WHERE PageID=@PageID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PageID AS varchar(20)), @PageObjectName)
-- Page belongs to Member ?
END ELSE IF @PageID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Page WHERE PageID=@PageID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Message slug given ?
END ELSE IF @Slug IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Slug'), @PageObjectName)
-- Message title given ?
END ELSE IF @Title IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'), @PageObjectName)
-- Message content given ?
END ELSE IF @PageContent IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PageObjectName, @PageObjectName)
-- Message title already exists ?
END ELSE IF EXISTS (SELECT * FROM GBL_Page WHERE (@PageID IS NULL OR PageID<>@PageID) AND Slug=@Slug AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Slug, cioc_shared.dbo.fn_SHR_STP_ObjectName('Slug'))
-- At Least one View chosen ?
END ELSE IF NOT EXISTS(SELECT * FROM @ViewIDs) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'), @PageObjectName)
-- Language given ?
END ELSE IF @PageID IS NULL AND @Culture IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @PageObjectName)
-- Language exists and is active ?
END ELSE IF @PageID IS NULL AND NOT EXISTS (SELECT * FROM STP_Language WHERE Culture=@Culture AND Active=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Culture AS varchar), @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @PageID IS NOT NULL BEGIN
		UPDATE GBL_Page
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			Slug				= @Slug,
			Title				= @Title,
			PageContent			= @PageContent,
			Owner				= @Owner
		WHERE (PageID = @PageID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
	END ELSE BEGIN
		INSERT INTO GBL_Page (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			DM,
			LangID,
			Owner,
			Slug,
			Title,
			PageContent
		) 
 		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@DM,
			(SELECT LangID FROM STP_Language WHERE Culture=@Culture),
			@Owner,
			@Slug,
			@Title,
			@PageContent
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
		SET @PageID = SCOPE_IDENTITY()
	END
	
	IF @Error = 0  BEGIN
		/* Update CIC View data */
		IF @DM=1 BEGIN	
			DELETE FROM CIC_Page_View
				WHERE (
					PageID = @PageID
					AND NOT EXISTS(SELECT * FROM @ViewIDs tm WHERE tm.ViewType=CIC_Page_View.ViewType)
					AND NOT EXISTS(SELECT * FROM CIC_View vw WHERE vw.ViewType=CIC_Page_View.ViewType AND (ISNULL(vw.Owner,@AgencyCode)<>@AgencyCode))
				)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
			
			INSERT INTO CIC_Page_View (ViewType, PageID)
				SELECT tm.ViewType AS ViewType, @PageID AS PageID
					FROM @ViewIDs tm
				WHERE NOT EXISTS(SELECT * FROM CIC_Page_View WHERE ViewType=tm.ViewType AND PageID=@PageID)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
		END ELSE BEGIN
			DELETE FROM VOL_Page_View
				WHERE (
					PageID = @PageID
					AND NOT EXISTS(SELECT * FROM @ViewIDs tm WHERE tm.ViewType=VOL_Page_View.ViewType)
					AND NOT EXISTS(SELECT * FROM VOL_View vw WHERE vw.ViewType=VOL_Page_View.ViewType AND (ISNULL(vw.Owner,@AgencyCode)<>@AgencyCode))
				)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
			
			INSERT INTO VOL_Page_View (ViewType, PageID)
				SELECT tm.ViewType AS ViewType, @PageID AS PageID
					FROM @ViewIDs tm
				WHERE NOT EXISTS(SELECT * FROM VOL_Page_View WHERE ViewType=tm.ViewType AND PageID=@PageID)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg

		END

	END
END

RETURN @Error






GO
GRANT CONTROL ON  [dbo].[sp_GBL_Page_u] TO [cioc_login_role]
GO
