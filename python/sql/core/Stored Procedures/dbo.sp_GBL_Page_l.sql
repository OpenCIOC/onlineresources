SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Page_l] (
	@MemberID [int],
	@DM [bit],
	@AgencyCode char(3)
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: CL
	Checked on: 04-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT PageID, Slug, Title, l.Culture
FROM GBL_Page p
INNER JOIN STP_Language l
	ON p.LangID=l.LangID
WHERE MemberID=@MemberID AND DM=@DM AND (Owner IS NULL OR Owner=@AgencyCode)
ORDER BY l.LangID, Title


RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Page_l] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Page_l] TO [cioc_login_role]
GO
