
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_Community_u]
	@ViewType int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@CM_ID int,
	@Community nvarchar(200),
	@DisplayOrder int,
	@IsNew bit,
	@ErrMsg nvarchar(500) OUTPUT
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
		@CommunityObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@ViewCommunityObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @ViewCommunityObjectName = @CommunityObjectName + cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + @ViewObjectName

SET @Community = NULLIF(LTRIM(RTRIM(@Community)), '')

IF @IsNew=1 BEGIN
	IF @Community IS NULL BEGIN
		SET @Error = 10 -- Required field
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, @ViewCommunityObjectName)
	END ELSE BEGIN
		IF @CM_ID IS NULL BEGIN
			SELECT TOP 1 @CM_ID=CM_ID FROM GBL_Community_Name WHERE [Name]=@Community ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID
		END 
		IF @CM_ID IS NULL BEGIN
			SET @Error = 21 -- No Such Value
			SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Community, @CommunityObjectName)
		END ELSE IF EXISTS(SELECT * FROM CIC_View_Community WHERE CM_ID=@CM_ID AND ViewType=@ViewType) BEGIN
			SET @Error = 6 -- Value in Use
			SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Community, @ViewCommunityObjectName)
		END
	END
END ELSE BEGIN
	SET @Community = NULL
	IF NOT EXISTS (SELECT * FROM CIC_View_Community WHERE CM_ID=@CM_ID AND ViewType=@ViewType) BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @ViewCommunityObjectName)
	END
END

IF @Error = 0 BEGIN
	-- Member ID given ?
	IF @MemberID IS NULL BEGIN
		SET @Error = 2 -- No ID Given
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
	-- Member ID exists ?
	END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	-- View given ?
	END ELSE IF @ViewType IS NULL BEGIN
		SET @Error = 2 -- No ID Given
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
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
	-- Display Order given ?
	END ELSE IF @DisplayOrder IS NULL BEGIN
		SET @Error = 10 -- Required field
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Display Order'), @ViewCommunityObjectName)
	END ELSE BEGIN
		IF @Community IS NULL BEGIN
			UPDATE CIC_View_Community
				SET  	DisplayOrder = @DisplayOrder
			WHERE (CM_ID=@CM_ID AND ViewType=@ViewType)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewCommunityObjectName, @ErrMsg
		END ELSE BEGIN
			INSERT INTO CIC_View_Community (
				ViewType,
				CM_ID,
				DisplayOrder
			)
			VALUES (
				@ViewType,
				@CM_ID,
				@DisplayOrder
			)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewCommunityObjectName, @ErrMsg
		END
		
		IF @Error = 0 BEGIN
			UPDATE CIC_View
				SET MODIFIED_DATE	= GETDATE(),
					MODIFIED_BY		= @MODIFIED_BY
			WHERE ViewType=@ViewType
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewCommunityObjectName, @ErrMsg
		END
	END
END

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_Community_u] TO [cioc_login_role]
GO
