
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_BusRoute_l]
	@MemberID [int],
	@ShowHidden [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 10-Jun-2014
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT br.BR_ID, br.RouteNumber, brn.Name AS RouteName, ISNULL(cmn.Display,cmn.Name) AS Municipality 
	FROM CIC_BusRoute br
	LEFT JOIN CIC_BusRoute_Name brn
		ON br.BR_ID=brn.BR_ID
			AND brn.LangID=(SELECT TOP 1 LangID FROM CIC_BusRoute_Name WHERE BR_ID=br.BR_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Community_Name cmn
		ON br.Municipality = cmn.CM_ID
			AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (br.MemberID IS NULL OR @MemberID IS NULL OR br.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_BusRoute_InactiveByMember WHERE BR_ID=br.BR_ID AND MemberID=@MemberID)
	)
ORDER BY br.DisplayOrder, br.RouteNumber, brn.Name

RETURN @Error

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_CIC_BusRoute_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_BusRoute_l] TO [cioc_login_role]
GO
