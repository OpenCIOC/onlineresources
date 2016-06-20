SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_UpdateFieldIDs_u]
	@ViewType int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@IdList varchar(max),
	@RT_ID int,
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
	DisplayFieldGroupID int NULL
)

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
-- Record Type exists ?
END ELSE IF @RT_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_RecordType WHERE RT_ID=@RT_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@RT_ID AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Record Type'))
END ELSE BEGIN
	INSERT INTO @UpdateFields
		SELECT uf2.UpdateFieldID, fo.FieldID, fg.DisplayFieldGroupID
		FROM dbo.fn_GBL_ParseIntIDPairList(@IdList,',','-') fl
		INNER JOIN GBL_FieldOption fo
			ON fl.LeftID=fo.FieldID
		LEFT JOIN CIC_View_DisplayFieldGroup fg
			ON fl.RightID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
		LEFT JOIN (SELECT uf.FieldID, uf.UpdateFieldID
				FROM CIC_View_UpdateField uf
				INNER JOIN CIC_View_DisplayFieldGroup fg
					ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType AND (uf.RT_ID=@RT_ID OR (uf.RT_ID IS NULL AND @RT_ID IS NULL))) uf2
			ON fo.FieldID=uf2.FieldID

	DELETE uf
		FROM CIC_View_UpdateField uf
		INNER JOIN @UpdateFields fl
			ON uf.UpdateFieldID=fl.UpdateFieldID AND fl.DisplayFieldGroupID IS NULL

	DELETE FROM @UpdateFields WHERE DisplayFieldGroupID IS NULL

	UPDATE uf
		SET DisplayFieldGroupID=fl.DisplayFieldGroupID
		FROM CIC_View_UpdateField uf
		INNER JOIN @UpdateFields fl
			ON uf.UpdateFieldID=fl.UpdateFieldID
		WHERE uf.DisplayFieldGroupID<>fl.DisplayFieldGroupID

	DELETE FROM @UpdateFields WHERE UpdateFieldID IS NOT NULL

	INSERT INTO CIC_View_UpdateField (FieldID,DisplayFieldGroupID,RT_ID)
	SELECT FieldID, DisplayFieldGroupID, @RT_ID FROM @UpdateFields

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewFieldObjectName, @ErrMsg
	IF @Error = 0 BEGIN
		UPDATE CIC_View
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
		WHERE ViewType=@ViewType
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_UpdateFieldIDs_u] TO [cioc_login_role]
GO
