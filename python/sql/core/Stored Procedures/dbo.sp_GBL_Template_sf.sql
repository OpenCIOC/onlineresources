
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_sf]
	@MemberID [int],
	@AgencyCode [char](3),
	@Template_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.1
	Checked by: CL
	Checked on: 18-Oct-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0
		
-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Template belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Template tp WHERE Template_ID=@Template_ID AND (MemberID=@MemberID OR MemberID IS NULL)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	t.*,
		CASE WHEN t.Owner IS NULL OR @AgencyCode IS NULL OR t.Owner=@AgencyCode THEN NULL ELSE t.Owner END AS ReadOnlyTemplateOwner,
		CAST(CASE WHEN EXISTS(SELECT * FROM STP_Member WHERE DefaultTemplate=t.Template_ID AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS IsDefaultTemplate,
		CAST(CASE WHEN EXISTS(SELECT * FROM STP_Member WHERE DefaultPrintTemplate=t.Template_ID AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS IsDefaultPrintTemplate,
		(SELECT ViewType, Owner, ViewName, MemberID
		FROM (SELECT vw.ViewType, Owner, vwd.ViewName, vw.MemberID
			FROM CIC_View vw
			INNER JOIN CIC_View_Description vwd
				ON vw.ViewType=vwd.ViewType AND vwd.LangID=(SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
			WHERE vw.Template=t.Template_ID or vw.PrintTemplate=t.Template_ID) [VIEW]
		FOR XML AUTO, ROOT ('VIEWS'),TYPE) AS RELATED_VIEW_CIC,
	(SELECT ViewType, Owner, ViewName, MemberID
		FROM (SELECT vw.ViewType, Owner, vwd.ViewName, vw.MemberID
			FROM VOL_View vw
			INNER JOIN VOL_View_Description vwd
				ON vw.ViewType=vwd.ViewType AND vwd.LangID=(SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
			WHERE vw.Template=t.Template_ID or vw.PrintTemplate=t.Template_ID) [VIEW]
		FOR XML AUTO,ROOT('VIEWS'),TYPE) AS RELATED_VIEW_VOL,
	(SELECT MenuID, MenuType, Display, Link, DisplayOrder, MenuGroup, l.Culture
		FROM GBL_Template_Menu tm
		INNER JOIN STP_Language l
			ON tm.LangID=l.LangID
		WHERE Template_ID=@Template_ID
		ORDER BY MenuType, Culture, DisplayOrder
		FOR XML PATH('MENU'),ROOT('MENUS'),TYPE) AS MENUS
	FROM GBL_Template t
WHERE Template_ID=@Template_ID
	AND (MemberID=@MemberID OR MemberID IS NULL)

SELECT td.*, l.Culture
	FROM GBL_Template_Description td 
	INNER JOIN STP_Language l
		ON td.LangID=l.LangID
WHERE Template_ID=@Template_ID

RETURN @Error

SET NOCOUNT OFF

GO



GRANT EXECUTE ON  [dbo].[sp_GBL_Template_sf] TO [cioc_login_role]
GO
