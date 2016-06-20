SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_u_FollowUp]
	@MemberID int,
	@RefIDList varchar(max),
	@FollowUpFlag bit
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

IF @FollowUpFlag IS NULL BEGIN
	SET @FollowUpFlag = 0
END

UPDATE VOL_OP_Referral
		SET FollowUpFlag = @FollowUpFlag
	FROM VOL_OP_Referral AS rf 
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@RefIDList,',') AS id
		ON rf.REF_ID = id.ItemID
WHERE rf.MemberID=@MemberID

RETURN @Error

SET NOCOUNT OFF

END


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_u_FollowUp] TO [cioc_login_role]
GO
