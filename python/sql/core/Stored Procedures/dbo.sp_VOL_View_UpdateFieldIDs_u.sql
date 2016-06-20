SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_UpdateFieldIDs_u]
	@ViewType int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@IdList varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Apr-2012
	Action:	NO ACTION REQUIRED
*/

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

DECLARE @tmpFieldIDs TABLE(FieldID int)

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
END ELSE IF NOT EXISTS (SELECT * FROM VOL_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
END ELSE BEGIN
	INSERT INTO @tmpFieldIDs SELECT DISTINCT tm.*
		FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
		INNER JOIN VOL_FieldOption fo ON tm.ItemID = fo.FieldID
	WHERE fo.CanUseUpdate=1

	DELETE pr
		FROM VOL_View_UpdateField pr
		LEFT JOIN @tmpFieldIDs tm
			ON pr.FieldID = tm.FieldID
	WHERE tm.FieldID IS NULL AND ViewType=@ViewType
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewFieldObjectName, @ErrMsg
	IF @Error = 0 BEGIN
		INSERT INTO VOL_View_UpdateField (ViewType, FieldID) SELECT ViewType=@ViewType, tm.FieldID
			FROM @tmpFieldIDs tm
		WHERE NOT EXISTS(SELECT * FROM VOL_View_UpdateField pr WHERE ViewType=@ViewType AND pr.FieldID=tm.FieldID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewFieldObjectName, @ErrMsg
		IF @Error = 0 BEGIN
			UPDATE VOL_View
				SET MODIFIED_DATE	= GETDATE(),
					MODIFIED_BY		= @MODIFIED_BY
			WHERE ViewType=@ViewType
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewFieldObjectName, @ErrMsg
		END
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_UpdateFieldIDs_u] TO [cioc_login_role]
GO
