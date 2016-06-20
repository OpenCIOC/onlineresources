SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_VOL_View_l]
	@MemberID int,
	@AgencyCode char(3),
	@AllAgencies bit,
	@OverrideIdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jul-2011
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

DECLARE @DefaultViewVOL int

SELECT @DefaultViewVOL=DefaultViewVOL
	FROM STP_Member
WHERE MemberID=@MemberID

SELECT vw.ViewType, CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		CAST(CASE WHEN vw.ViewType=@DefaultViewVOL OR EXISTS(SELECT * FROM VOL_View_Recurse vwr WHERE vwr.ViewType=@DefaultViewVOL AND vwr.CanSee=vw.ViewType) THEN 1 ELSE 0 END AS bit) AS IsPublic,
		Owner
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.fn_GBL_ParseIntIDList(@OverrideIdList,',') tm
		ON vw.ViewType=tm.ItemID
WHERE vw.MemberID=@MemberID
	AND (
		@AllAgencies = 1
		OR @AgencyCode IS NULL
		OR vw.Owner IS NULL
		OR vw.Owner=@AgencyCode
		OR tm.ItemID IS NOT NULL
	)
ORDER BY CASE WHEN vw.ViewType=@DefaultViewVOL OR EXISTS(SELECT * FROM VOL_View_Recurse vwr WHERE vwr.ViewType=@DefaultViewVOL AND vwr.CanSee=vw.ViewType) THEN 0 ELSE 1 END,
	vwd.ViewName

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_l] TO [cioc_login_role]
GO
