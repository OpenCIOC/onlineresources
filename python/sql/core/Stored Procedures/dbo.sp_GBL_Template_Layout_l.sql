SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_Template_Layout_l]
	@MemberID int,
	@AgencyCode [char](3),
	@OverrideID varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jul-2012
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

SELECT tl.LayoutID, tl.LayoutType, tl.Owner, tl.SystemLayout, tld.LayoutName
	FROM GBL_Template_Layout tl
	INNER JOIN GBL_Template_Layout_Description tld
		ON tl.LayoutID=tld.LayoutID AND tld.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Layout_Description WHERE LayoutID=tld.LayoutID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE (tl.MemberID=@MemberID OR tl.SystemLayout=1)
	AND (
		tl.LayoutID IN (SELECT * FROM dbo.fn_GBL_ParseIntIDList(@OverrideID,','))
		OR @AgencyCode IS NULL
		OR tl.Owner IS NULL
		OR tl.Owner=@AgencyCode
	)
ORDER BY LayoutType, tld.LayoutName

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_Layout_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_Layout_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_Layout_l] TO [cioc_vol_search_role]
GO
