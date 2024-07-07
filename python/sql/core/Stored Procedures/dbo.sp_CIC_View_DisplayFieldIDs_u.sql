SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_DisplayFieldIDs_u]
	@ViewType int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@IdList varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@ViewFieldObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @ViewFieldObjectName = @ViewObjectName + ' - ' + @FieldObjectName

DECLARE @DisplayFields TABLE (
	DisplayFieldID int NULL,
	FieldID int NOT NULL,
	DisplayFieldGroupID int NULL
)

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- View given ?
END ELSE IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.CIC_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.CIC_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
END ELSE BEGIN
	INSERT INTO @DisplayFields
		SELECT fd2.DisplayFieldID, fo.FieldID, fg.DisplayFieldGroupID
		FROM dbo.fn_GBL_ParseIntIDPairList(@IdList,',','~') fl
		INNER JOIN dbo.GBL_FieldOption fo
			ON fl.LeftID=fo.FieldID
		LEFT JOIN dbo.CIC_View_DisplayFieldGroup fg
			ON fl.RightID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
		LEFT JOIN (SELECT fd.FieldID, fd.DisplayFieldID
				FROM dbo.CIC_View_DisplayField fd
				INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
					ON fd.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType) fd2
			ON fo.FieldID=fd2.FieldID

	DELETE fd
		FROM dbo.CIC_View_DisplayField fd
		INNER JOIN @DisplayFields fl
			ON fd.DisplayFieldID=fl.DisplayFieldID AND  fl.DisplayFieldGroupID IS NULL

	DELETE FROM @DisplayFields WHERE DisplayFieldGroupID IS NULL

	UPDATE fd
		SET DisplayFieldGroupID=fl.DisplayFieldGroupID
		FROM dbo.CIC_View_DisplayField fd
		INNER JOIN @DisplayFields fl
			ON fd.DisplayFieldID=fl.DisplayFieldID
		WHERE fd.DisplayFieldGroupID<>fl.DisplayFieldGroupID

	DELETE FROM @DisplayFields WHERE DisplayFieldID IS NOT NULL

	INSERT INTO dbo.CIC_View_DisplayField (FieldID,DisplayFieldGroupID)
	SELECT FieldID, DisplayFieldGroupID FROM @DisplayFields

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewFieldObjectName, @ErrMsg
	IF @Error = 0 BEGIN
		UPDATE dbo.CIC_View
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
		WHERE ViewType=@ViewType
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_DisplayFieldIDs_u] TO [cioc_login_role]
GO
