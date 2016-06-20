SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SearchTips_l]
	@MemberID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT ip.SearchTipsID, ip.PageTitle, ip.LangID
	FROM GBL_SearchTips ip
	INNER JOIN STP_Language sl
		ON ip.LangID=sl.LangID
WHERE ip.MemberID=@MemberID
	AND sl.Active=1
	AND ip.Domain=2
ORDER BY ip.PageTitle

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SearchTips_l] TO [cioc_login_role]
GO
