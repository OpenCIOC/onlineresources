
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_d]
	@CM_ID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 02-Feb-2017
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@CommunityObjectName nvarchar(60)

SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')

-- Community ID given ?
IF @CM_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, NULL)
-- Community ID exists ?
END ELSE IF NOT EXISTS (SELECT CM_ID FROM GBL_Community WHERE CM_ID = @CM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @CommunityObjectName)
-- Community ID not in use by record ?
END ELSE IF EXISTS(SELECT * FROM GBL_BaseTable WHERE LOCATED_IN_CM=@CM_ID)
			OR EXISTS(SELECT * FROM CIC_BT_CM WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
-- Community ID not in use by record ?
END ELSE IF EXISTS(SELECT * FROM VOL_OP_CM WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record'))
-- Community ID not in use by other Community ?
END ELSE IF EXISTS(SELECT * FROM GBL_Community WHERE ParentCommunity=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, @CommunityObjectName)
-- Community ID not in use by Bus Route ?
END ELSE IF EXISTS(SELECT * FROM CIC_BusRoute WHERE Municipality=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Bus Route'))
-- Community ID not in use by Ward ?
END ELSE IF EXISTS(SELECT * FROM CIC_Ward WHERE Municipality=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Ward'))
-- Community ID not in use by View ?
END ELSE IF EXISTS(SELECT * FROM CIC_View_Community WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
-- Community ID not in use by Volunteer Community Group ?
END ELSE IF EXISTS(SELECT * FROM VOL_CommunityGroup_CM WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Group'))
END ELSE BEGIN
	DELETE FROM dbo.GBL_Community_ParentList WHERE Parent_CM_ID=@CM_ID
	DELETE GBL_Community
	WHERE (CM_ID = @CM_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg
END			

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Community_d] TO [cioc_login_role]
GO
