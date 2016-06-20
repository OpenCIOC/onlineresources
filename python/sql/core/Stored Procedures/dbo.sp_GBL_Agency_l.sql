SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Agency_l]
	@MemberID [int],
	@ListForeignAgency [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Jan-2012
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
SELECT a.AgencyID, a.AgencyCode, a.MemberID
	FROM GBL_Agency a
	LEFT JOIN STP_Member_ListForeignAgency memf
		ON a.AgencyID=memf.AgencyID AND memf.MemberID=@MemberID
WHERE a.MemberID=@MemberID OR (@ListForeignAgency=1 AND memf.AgencyID IS NOT NULL)
ORDER BY a.AgencyCode

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_l] TO [cioc_vol_search_role]
GO
