SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_CommunitySet_d]
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@CommunitySetID int,
	@VNUMList varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@CommunitySetObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunitySetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Set')

DECLARE @tmpVNUMs TABLE(VNUM varchar(10))

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
END ELSE BEGIN
	INSERT INTO @tmpVNUMs
	SELECT DISTINCT vo.VNUM
		FROM dbo.fn_GBL_ParseVarCharIDList(@VNUMList,',') tm
		INNER JOIN VOL_Opportunity vo
			ON tm.ItemID=vo.VNUM COLLATE Latin1_General_100_CS_AI
	WHERE EXISTS(SELECT * FROM VOL_OP_CommunitySet vcs WHERE vcs.VNUM=vo.VNUM AND vcs.CommunitySetID=@CommunitySetID)

	DELETE vocs 
		FROM VOL_OP_CommunitySet vocs 
		INNER JOIN @tmpVNUMs tm
			ON vocs.VNUM=tm.VNUM
				AND CommunitySetID=@CommunitySetID

	UPDATE vo
		SET MODIFIED_BY		= @MODIFIED_BY,
			MODIFIED_DATE	= GETDATE()
		FROM VOL_Opportunity vo
		INNER JOIN @tmpVNUMs tm
			ON vo.VNUM=tm.VNUM AND vo.MemberID=@MemberID
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_CommunitySet_d] TO [cioc_login_role]
GO
