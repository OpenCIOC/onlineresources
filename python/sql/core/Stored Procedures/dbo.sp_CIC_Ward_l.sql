
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Ward_l]
	@MemberID [int],
	@ShowHidden [bit],
	@OverrideID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT wd.WD_ID, wd.WardNumber, wdn.Name AS WardName, cmn.Name AS Municipality
	FROM CIC_Ward wd
	LEFT JOIN CIC_Ward_Name wdn
		ON wd.WD_ID=wdn.WD_ID AND wdn.LangID=@@LANGID
	LEFT JOIN GBL_Community cm
		ON wd.Municipality=cm.CM_ID
	LEFT JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE wd.WD_ID=@OverrideID
	OR (
		(wd.MemberID IS NULL OR @MemberID IS NULL OR wd.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_Ward_InactiveByMember WHERE WD_ID=wd.WD_ID AND MemberID=@MemberID)
		)
	)
ORDER BY cmn.Name, wd.WardNumber

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Ward_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Ward_l] TO [cioc_login_role]
GO
