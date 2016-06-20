SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_d]
	@CommunityGroupID int,
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

DECLARE @Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@CommunityGroupObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunityGroupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Group')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @CommunityGroupObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Community Group ID given ?
END ELSE IF @CommunityGroupID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityGroupObjectName, NULL)
-- Community Group ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_CommunityGroup WHERE CommunityGroupID=@CommunityGroupID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CommunityGroupID AS varchar(20)), @CommunityGroupObjectName)
-- Community Group belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet vcs INNER JOIN VOL_CommunityGroup vcg ON vcs.CommunitySetID=vcg.CommunitySetID WHERE CommunityGroupID=@CommunityGroupID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Used by a Community ?
END ELSE IF EXISTS(SELECT * FROM VOL_CommunityGroup_CM WHERE CommunityGroupID=@CommunityGroupID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityGroupObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Community'))
END ELSE BEGIN
	DELETE VOL_CommunityGroup
	WHERE (CommunityGroupID=@CommunityGroupID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityGroupObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_d] TO [cioc_login_role]
GO
