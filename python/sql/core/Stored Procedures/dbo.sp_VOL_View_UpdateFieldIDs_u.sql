SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_UpdateFieldIDs_u]
	@ViewType int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@IdList varchar(MAX),
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


DECLARE @UpdateFields TABLE (
	UpdateFieldID int NULL,
	FieldID int NOT NULL,
	DisplayFieldGroupID int NULL,
	IS_SELECTED bit NOT NULL
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
END ELSE IF NOT EXISTS (SELECT * FROM dbo.VOL_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.VOL_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.VOL_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
END ELSE BEGIN
	INSERT INTO @UpdateFields
		SELECT ff2.UpdateFieldID, fo.FieldID, fg.DisplayFieldGroupID, CASE WHEN fg.DisplayFieldGroupID IS NOT	NULL OR fl.RightID = -1 THEN 1 ELSE 0 END
		FROM dbo.fn_GBL_ParseIntIDPairList(@IdList,',','~') fl
		INNER JOIN dbo.VOL_FieldOption fo
			ON fl.LeftID=fo.FieldID
		LEFT JOIN dbo.VOL_View_DisplayFieldGroup fg
			ON fl.RightID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
		LEFT JOIN (SELECT ff.FieldID, ff.UpdateFieldID
				FROM dbo.VOL_View_UpdateField ff
				WHERE ff.ViewType=@ViewType) ff2
			ON fo.FieldID=ff2.FieldID

	DELETE ff
		FROM dbo.VOL_View_UpdateField ff
	WHERE ff.ViewType=@ViewType
		AND NOT EXISTS(SELECT * FROM @UpdateFields fl WHERE ff.UpdateFieldID=fl.UpdateFieldID AND fl.IS_SELECTED = 1)

	DELETE FROM @UpdateFields WHERE IS_SELECTED = 0

	UPDATE ff
		SET DisplayFieldGroupID=fl.DisplayFieldGroupID
		FROM dbo.VOL_View_UpdateField ff
		INNER JOIN @UpdateFields fl
			ON ff.UpdateFieldID=fl.UpdateFieldID
		WHERE ff.DisplayFieldGroupID<>fl.DisplayFieldGroupID OR ff.DisplayFieldGroupID IS NULL

	DELETE FROM @UpdateFields WHERE UpdateFieldID IS NOT NULL

	INSERT INTO dbo.VOL_View_UpdateField (FieldID,ViewType,DisplayFieldGroupID)
	SELECT FieldID, @ViewType, DisplayFieldGroupID FROM @UpdateFields

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewFieldObjectName, @ErrMsg
	IF @Error = 0 BEGIN
		UPDATE dbo.VOL_View
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
		WHERE ViewType=@ViewType
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_UpdateFieldIDs_u] TO [cioc_login_role]
GO
