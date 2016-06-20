SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_l]
	@MemberID int,
	@AgencyCode char(3),
	@OverrideIdList varchar(max) = ''
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT t.Template_ID, td.Name
	FROM GBL_Template t
	INNER JOIN GBL_Template_Description td
		ON t.Template_ID=td.Template_ID AND td.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Description WHERE Template_ID=td.Template_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
	LEFT JOIN (SELECT DISTINCT ItemID FROM dbo.fn_GBL_ParseIntIDList(@OverrideIdList,',')) tm
		ON t.Template_ID=tm.ItemID
WHERE (t.MemberID=@MemberID OR t.MemberID IS NULL)
	AND (
		@AgencyCode IS NULL
		OR t.Owner IS NULL
		OR t.Owner=@AgencyCode
		OR tm.ItemID IS NOT NULL
	)
ORDER BY td.Name

SET NOCOUNT OFF













GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_l] TO [cioc_vol_search_role]
GO
