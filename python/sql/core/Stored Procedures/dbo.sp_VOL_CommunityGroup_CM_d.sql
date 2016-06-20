SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_CM_d]
	@CG_CM_ID int,
	@MemberID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberObjectName nvarchar(100),
		@CommunityGroupObjectName nvarchar(100),
		@CommunityObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunityGroupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Group')
SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @CommunityGroupObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Community Group ID given ?
END ELSE IF @CG_CM_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, NULL)
-- Community Group ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_CommunityGroup_CM vcgc WHERE CG_CM_ID=@CG_CM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CG_CM_ID AS varchar), @CommunityGroupObjectName)
-- Community Group belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet vcs
		INNER JOIN VOL_CommunityGroup vcg ON vcs.CommunitySetID=vcg.CommunitySetID
		INNER JOIN VOL_CommunityGroup_CM vcgc ON vcg.CommunityGroupID=vcgc.CommunityGroupID
		WHERE CG_CM_ID=@CG_CM_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DELETE VOL_CommunityGroup_CM
	WHERE (CG_CM_ID=@CG_CM_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_d] TO [cioc_login_role]
GO
