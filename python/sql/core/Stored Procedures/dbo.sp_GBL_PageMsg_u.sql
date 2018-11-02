SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PageMsg_u]
	@PageMsgID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@UseCIC bit,
	@UseVOL bit,
	@MsgTitle varchar(50),
	@LangID smallint,
	@VisiblePrintMode bit,
	@LoginOnly bit,
	@DisplayOrder tinyint,
	@PageMsg nvarchar(max),
	@CICViewList varchar(max),
	@VOLViewList varchar(max),
	@PageList varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 11-Sep-2011
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@PageMessageObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @PageMessageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Page Message')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

SET @MsgTitle = RTRIM(LTRIM(@MsgTitle))
IF @MsgTitle = '' SET @MsgTitle = NULL
SET @PageMsg = RTRIM(LTRIM(@PageMsg))
IF @PageMsg = '' SET @PageMsg = NULL

DECLARE @ViewIDs TABLE (
	ViewType int NOT NULL,
	Domain tinyint NOT NULL
)

DECLARE @PageNames TABLE (
	PageName varchar(255) COLLATE Latin1_General_100_CS_AS NOT NULL PRIMARY KEY
)

/* Update CIC View data */
IF @UseCIC=1 BEGIN
	INSERT INTO @ViewIDs 
	SELECT tm.ItemID, 1 
		FROM fn_GBL_ParseIntIDList(@CICViewList, ',') tm
		INNER JOIN CIC_View vw
			ON vw.ViewType = tm.ItemID
				AND vw.MemberID=@MemberID
				AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
END

/* Update CIC View data */
IF @UseVOL=1 BEGIN
	INSERT INTO @ViewIDs
	SELECT tm.ItemID, 2
		FROM fn_GBL_ParseIntIDList(@VOLViewList, ',') tm
		INNER JOIN VOL_View vw
			ON vw.ViewType = tm.ItemID
				AND vw.MemberID=@MemberID
				AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
END

IF @PageList IS NOT NULL BEGIN
	INSERT INTO @PageNames
	SELECT tm.* 
		FROM fn_GBL_ParseVarCharIDList(@PageList, ',') tm
		INNER JOIN GBL_PageInfo pg
			ON tm.ItemID = pg.PageName COLLATE Latin1_General_100_CI_AI
				AND NoPageMsg=0
				AND (
					(@UseCIC=1 AND pg.CIC=1)
					OR (@UseVOL=1 AND pg.VOL=1)
				)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @PageMessageObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- PageMsg ID exists ?
END ELSE IF @PageMsgID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_PageMsg WHERE PageMsgID=@PageMsgID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PageMsgID AS varchar(20)), @PageMessageObjectName)
-- PageMsg belongs to Member ?
END ELSE IF @PageMsgID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PageMsg WHERE PageMsgID=@PageMsgID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Message title given ?
END ELSE IF @MsgTitle IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'), @PageMessageObjectName)
-- Message content given ?
END ELSE IF @PageMsg IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PageMessageObjectName, @PageMessageObjectName)
-- Message title already exists ?
END ELSE IF EXISTS (SELECT * FROM GBL_PageMsg WHERE (@PageMsgID IS NULL OR PageMsgID<>@PageMsgID) AND MsgTitle=@MsgTitle AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MsgTitle, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'))
-- At Least one page chosen ?
END ELSE IF NOT EXISTS(SELECT * FROM @PageNames) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Page'), @PageMessageObjectName)
-- At Least one View chosen ?
END ELSE IF NOT EXISTS(SELECT * FROM @ViewIDs) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'), @PageMessageObjectName)
-- Language given ?
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @PageMessageObjectName)
-- Language exists and is active ?
END ELSE IF NOT EXISTS (SELECT * FROM STP_Language WHERE LangID=@LangID AND Active=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @PageMsgID IS NOT NULL BEGIN
		UPDATE GBL_PageMsg
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			MsgTitle			= @MsgTitle,
			LangID				= @LangID,
			VisiblePrintMode	= ISNULL(@VisiblePrintMode, VisiblePrintMode),
			LoginOnly			= ISNULL(@LoginOnly, LoginOnly),
			DisplayOrder		= ISNULL(@DisplayOrder, DisplayOrder),
			PageMsg				= @PageMsg
		WHERE (PageMsgID = @PageMsgID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
	END ELSE BEGIN
		INSERT INTO GBL_PageMsg (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			MsgTitle,
			LangID,
			VisiblePrintMode,
			LoginOnly,
			DisplayOrder,
			PageMsg
		) 
 		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@MsgTitle,
			@LangID,
			ISNULL(@VisiblePrintMode,1),
			ISNULL(@LoginOnly,0),
			ISNULL(@DisplayOrder,0),
			@PageMsg
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
		SET @PageMsgID = SCOPE_IDENTITY()
	END
	
	IF @Error = 0  BEGIN
		/* Update CIC View data */
		IF @UseCIC=1 BEGIN	
			DELETE FROM CIC_View_PageMsg
				WHERE (
					PageMsgID = @PageMsgID
					AND NOT EXISTS(SELECT * FROM @ViewIDs tm WHERE tm.Domain=1 AND tm.ViewType=CIC_View_PageMsg.ViewType)
					AND NOT EXISTS(SELECT * FROM CIC_View vw WHERE vw.ViewType=CIC_View_PageMsg.ViewType AND (ISNULL(vw.Owner,@AgencyCode)<>@AgencyCode))
				)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
			
			INSERT INTO CIC_View_PageMsg
				SELECT tm.ViewType AS ViewType, @PageMsgID AS PageMsgID
					FROM @ViewIDs tm
				WHERE tm.Domain=1 AND NOT EXISTS(SELECT * FROM CIC_View_PageMsg WHERE ViewType=tm.ViewType AND PageMsgID=@PageMsgID)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
		END

		/* Update VOL View data */
		IF @UseVOL=1 BEGIN		
			DELETE FROM VOL_View_PageMsg
				WHERE (
					PageMsgID = @PageMsgID
					AND NOT EXISTS(SELECT * FROM @ViewIDs tm WHERE tm.Domain=2 AND tm.ViewType=VOL_View_PageMsg.ViewType)
					AND NOT EXISTS(SELECT * FROM VOL_View vw WHERE vw.ViewType=VOL_View_PageMsg.ViewType AND (ISNULL(vw.Owner,@AgencyCode)<>@AgencyCode))
				)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
			
			INSERT INTO VOL_View_PageMsg
				SELECT tm.ViewType AS ViewType, @PageMsgID AS PageMsgID
					FROM @ViewIDs tm
				WHERE tm.Domain=2 AND NOT EXISTS(SELECT * FROM VOL_View_PageMsg WHERE ViewType=tm.ViewType AND PageMsgID=@PageMsgID)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
		END

		/* Update Page data */
		DELETE FROM GBL_PageMsg_PageInfo
			WHERE PageMsgID = @PageMsgID
				AND NOT EXISTS(SELECT * FROM @PageNames tm WHERE tm.PageName=GBL_PageMsg_PageInfo.PageName)
				AND EXISTS(SELECT * FROM GBL_PageInfo pg WHERE pg.PageName=GBL_PageMsg_PageInfo.PageName AND ((@UseCIC=1 AND pg.CIC=1) OR (@UseVOL=1 AND VOL=1)))
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
		
		INSERT INTO GBL_PageMsg_PageInfo
			SELECT tm.PageName AS PageName, @PageMsgID AS PageMsgID
				FROM @PageNames tm
			WHERE NOT EXISTS(SELECT * FROM GBL_PageMsg_PageInfo WHERE PageName=tm.PageName AND PageMsgID=@PageMsgID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageMessageObjectName, @ErrMsg
		
		DELETE FROM @PageNames
	END
END

RETURN @Error





GO


GRANT CONTROL ON  [dbo].[sp_GBL_PageMsg_u] TO [cioc_login_role]
GO
