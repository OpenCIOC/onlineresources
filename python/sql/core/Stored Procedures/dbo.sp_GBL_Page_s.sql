SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Page_s] (
	@MemberID [int],
	@AgencyCode char(3),
	@DM tinyint,
	@PageID int
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

SELECT p.*, l.LanguageName, p.Owner AS ReadOnlyPageOwner
FROM GBL_Page p
INNER JOIN STP_Language l
	ON l.LangID=p.LangID
WHERE PageID=@PageID AND MemberID=@MemberID AND DM=@DM AND (p.Owner IS NULL OR p.Owner=@AgencyCode)

IF @DM = 1 BEGIN
	SELECT vw.ViewType, vwd.ViewName, CAST(CASE WHEN pv.ViewType IS NOT NULL THEN 1 ELSE 0 END AS bit) AS Selected
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vwd.ViewType = vw.ViewType AND vwd.LangID=(SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vw.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_Page_View pv
		ON vw.ViewType=pv.ViewType AND pv.PageID=@PageID
	WHERE MemberID=@MemberID AND (pv.ViewType IS NOT NULL OR vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	ORDER BY ViewName
END ELSE BEGIN
	SELECT vw.ViewType, vwd.ViewName, CAST(CASE WHEN pv.ViewType IS NOT NULL THEN 1 ELSE 0 END AS bit) AS Selected
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vwd.ViewType = vw.ViewType AND vwd.LangID=(SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vw.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_Page_View pv
		ON vw.ViewType=pv.ViewType AND pv.PageID=@PageID
	WHERE MemberID=@MemberID AND (pv.ViewType IS NOT NULL OR vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	ORDER BY ViewName
END


RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Page_s] TO [cioc_login_role]
GO
