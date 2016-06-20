SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_View_QuickSearch_lf]
	@MemberID int,
	@AgencyCode char(3),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 21-Apr-2015
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
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	AND vw.ViewType=@ViewType

SELECT p.PageName, (SELECT TOP 1 d.PageTitle FROM GBL_PageInfo_Description d WHERE d.PageName=p.PageName ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS Name
FROM GBL_PageInfo p
WHERE CIC=1 AND SearchResults=1

SELECT	qs.*,
		(SELECT qsd.Name, l.Culture
		FROM CIC_View_QuickSearch_Name qsd
			INNER JOIN STP_Language l
				ON l.LangID=qsd.LangID
		WHERE qsd.QuickSearchID=qs.QuickSearchID
		FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions
FROM CIC_View_QuickSearch qs
WHERE qs.ViewType=@ViewType
ORDER BY DisplayOrder, 
	(SELECT TOP 1 Name 
	FROM CIC_View_QuickSearch_Name 
	WHERE QuickSearchID=qs.QuickSearchID 
	ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)

RETURN @Error
	
SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_QuickSearch_lf] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_QuickSearch_lf] TO [cioc_login_role]
GO
