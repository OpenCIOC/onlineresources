SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunitySet_lf]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action:	NO ACTION REQUIRED
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

SELECT cs.*, 
	(SELECT COUNT(*) FROM VOL_OP_CommunitySet WHERE CommunitySetID=cs.CommunitySetID) As UsageCountRecords, 
	(SELECT COUNT(*) FROM VOL_View WHERE CommunitySetID=cs.CommunitySetID) AS UsageCountViews,
	(SELECT csn.SetName AS [@SetName], csn.AreaServed [@AreaServed], l.Culture AS [@Culture]
		FROM VOL_CommunitySet_Name csn
		INNER JOIN STP_Language l
			ON csn.LangID=l.LangID
		WHERE csn.CommunitySetID=cs.CommunitySetID
		FOR XML PATH('DESC'), TYPE) AS Descriptions
	FROM VOL_CommunitySet cs
WHERE cs.MemberID=@MemberID
ORDER BY (SELECT TOP 1 SetName FROM VOL_CommunitySet_Name WHERE CommunitySetID=cs.CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_lf] TO [cioc_vol_search_role]
GO
