
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_s_BSrch_Template]
	@ViewType [int],
	@PreviewTemplate_ID int = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE @Template_ID int

IF @PreviewTemplate_ID IS NOT NULL BEGIN
	SELECT @Template_ID=Template_ID
	FROM GBL_Template tp
	WHERE Template_ID=@PreviewTemplate_ID AND PreviewTemplate=1 AND (SystemTemplate=1 OR MemberID IS NULL OR MemberID=(SELECT MemberID FROM VOL_View WHERE ViewType=@ViewType))
END

IF @Template_ID IS NULL BEGIN
	SELECT @Template_ID=Template FROM VOL_View WHERE ViewType=@ViewType
END

SELECT tp.*,
	tld.LayoutHTML AS SearchLayoutHTML, tld.LayoutHTMLURL, tl.SystemLayout
	FROM GBL_Template tp
	INNER JOIN GBL_Template_Description tpd
		ON tp.Template_ID=tpd.Template_ID AND tpd.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Description WHERE Template_ID=tpd.Template_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Template_Layout tl
		ON tl.LayoutID=tp.SearchLayoutVOL OR (tp.SearchLayoutVOL IS NULL AND tl.LayoutID=(SELECT TOP 1 LayoutID FROM GBL_Template_Layout WHERE DefaultSearchLayout=1 AND LayoutType='volsearch'))
	LEFT JOIN GBL_Template_Layout_Description tld
		ON tld.LayoutID=tl.LayoutID AND tld.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Layout_Description WHERE LayoutID=tld.LayoutID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE tp.Template_ID=@Template_ID

SELECT * 
	FROM GBL_Template_Menu 
WHERE Template_ID = @Template_ID
	AND LangID=@@LANGID AND MenuType='volsearch' 
ORDER BY MenuGroup, DisplayOrder, Display

SET NOCOUNT OFF




GO


GRANT EXECUTE ON  [dbo].[sp_VOL_View_s_BSrch_Template] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_s_BSrch_Template] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_s_BSrch_Template] TO [cioc_vol_search_role]
GO
