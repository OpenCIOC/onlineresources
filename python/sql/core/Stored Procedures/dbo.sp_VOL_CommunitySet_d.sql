SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunitySet_d]
	@CommunitySetID int,
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
		@CommunitySetObjectName nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunitySetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Set')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @CommunitySetObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Community Set ID given ?
END ELSE IF @CommunitySetID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunitySetObjectName, NULL)
-- Community Set ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_CommunitySet WHERE CommunitySetID=@CommunitySetID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CommunitySetID AS varchar(20)), @CommunitySetObjectName)
-- Community Set belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet WHERE CommunitySetID=@CommunitySetID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Used by an Opportunity ?
END ELSE IF EXISTS(SELECT * FROM VOL_OP_CommunitySet WHERE CommunitySetID=@CommunitySetID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunitySetObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record'))
-- Used by a View ?
END ELSE IF EXISTS(SELECT * FROM VOL_View WHERE CommunitySetID=@CommunitySetID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunitySetObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE BEGIN
	DELETE VOL_CommunitySet
	WHERE (CommunitySetID=@CommunitySetID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunitySetObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_d] TO [cioc_login_role]
GO
