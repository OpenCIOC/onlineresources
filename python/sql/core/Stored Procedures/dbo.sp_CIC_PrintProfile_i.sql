SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_PrintProfile_i]
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@ProfileName nvarchar(50),
	@ProfileID int OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@CopyProfileID	int
SET @CopyProfileID = @ProfileID

SET @ProfileName = RTRIM(LTRIM(@ProfileName))

EXEC @Error = dbo.sp_GBL_PrintProfile_i @MODIFIED_BY, @MemberID, @ProfileName, 1, @ProfileID OUTPUT, @ErrMsg OUTPUT

IF @Error = 0 AND @ProfileID IS NOT NULL AND @CopyProfileID IS NOT NULL BEGIN
	INSERT INTO  CIC_View_PrintProfile (
		ProfileID,
		ViewType
	) SELECT
		@ProfileID AS ProfileID,
		ViewType
	FROM CIC_View_PrintProfile
	WHERE ProfileID = @CopyProfileID
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_PrintProfile_i] TO [cioc_login_role]
GO
