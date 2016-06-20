SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_CM_i]
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@CM_ID [int],
	@CommunityGroupID [int],
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
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
-- Community exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Community WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @CommunityObjectName)
-- Community already in group ?
END ELSE IF EXISTS(SELECT * FROM VOL_CommunityGroup_CM cgc WHERE CM_ID=@CM_ID AND CommunityGroupID=@CommunityGroupID) BEGIN
	SET @Error = 6 -- Value already in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, (SELECT TOP 1 Name FROM GBL_Community_Name WHERE CM_ID=@CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END), @CommunityObjectName)
END ELSE BEGIN
	INSERT INTO VOL_CommunityGroup_CM (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		CM_ID,
		CommunityGroupID
	)
	VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@CM_ID,
		@CommunityGroupID
	)
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityGroupObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_i] TO [cioc_login_role]
GO
