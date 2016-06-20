SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_Dist_u]
	@ProfileID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@IdList [varchar](max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 06-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')

DECLARE @tmpDST_IDs TABLE(
	DST_ID int NOT NULL PRIMARY KEY
)

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @ProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	INSERT INTO @tmpDST_IDs SELECT DISTINCT tm.*
		FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
		INNER JOIN CIC_Distribution dst
			ON tm.ItemID = dst.DST_ID

	DELETE pr
		FROM CIC_ExportProfile_Dist pr
		LEFT JOIN @tmpDST_IDs tm
			ON pr.DST_ID = tm.DST_ID
	WHERE tm.DST_ID IS NULL AND ProfileID=@ProfileID
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		INSERT INTO CIC_ExportProfile_Dist (
			ProfileID,
			DST_ID
		)
		SELECT
				@ProfileID,
				tm.DST_ID
			FROM @tmpDST_IDs tm
		WHERE NOT EXISTS(SELECT * FROM CIC_ExportProfile_Dist pr WHERE ProfileID=@ProfileID AND pr.DST_ID=tm.DST_ID)
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
		
		IF @Error = 0 BEGIN
			UPDATE CIC_ExportProfile
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
			WHERE ProfileID=@ProfileID
		END
	END
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_Dist_u] TO [cioc_login_role]
GO
