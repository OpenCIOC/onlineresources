SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_Month_l]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT DATENAME(m, ReferralDate) + ' ' + CAST(YEAR(ReferralDate) AS varchar) AS REFERRAL_MONTH, COUNT(*) As ReferralCount
	FROM VOL_OP_Referral rf
WHERE rf.MemberID=@MemberID
GROUP BY DATENAME(m, ReferralDate) + ' ' + CAST(YEAR(ReferralDate) AS varchar)
ORDER BY CAST(DATENAME(m, ReferralDate) + ' ' + CAST(YEAR(ReferralDate) AS varchar) AS smalldatetime)

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_Month_l] TO [cioc_login_role]
GO
