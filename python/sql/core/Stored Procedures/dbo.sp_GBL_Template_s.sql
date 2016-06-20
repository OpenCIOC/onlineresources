
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_s] (
	@MemberID [int],
	@Template_ID [int],
	@PreviewTemplate_ID int = NULL
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 02-Feb-2016
	Action: NO ACTION REQUIRED
	Notes: Should ensure that the front-end can manage if there are errors; may need proper error messages
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

IF @PreviewTemplate_ID IS NOT NULL AND EXISTS(SELECT * FROM GBL_Template WHERE (MemberID=@MemberID Or MemberID IS NULL) AND Template_ID=@PreviewTemplate_ID AND PreviewTemplate=1) BEGIN
	SET @Template_ID = @PreviewTemplate_ID
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Template WHERE (MemberID=@MemberID Or MemberID IS NULL) AND Template_ID=@Template_ID) BEGIN
	SELECT @Template_ID=DefaultTemplate FROM STP_Member WHERE MemberID=@MemberID
END

SELECT	tp.Template_ID, StyleSheetUrl, JavaScriptBottomUrl, JavaScriptTopUrl, ShortCutIcon, AppleTouchIcon, BodyTagExtras, tp.SmallTitle,
		tp.HeaderSearchLink, tp.HeaderSearchIcon, tp.HeaderSuggestLink, tp.HeaderSuggestIcon, tp.ContainerContrast, tp.ContainerFluid,
		tpd.*, 
		TemplateCSSVersionDate AS VersionDate,
		tp.TemplateCSSLayoutURLs, tp.AlmostStandardsMode, tp.UseFullCIOCBootstrap_Cache AS UseFullCIOCBootstrap, tp.UseFontAwesome_Cache AS UseFontAwesome,
		tldh.LayoutHTML AS HeaderLayoutHTML, tldh.LayoutHTMLURL AS HeaderLayoutHTMLURL, (SELECT SystemLayout FROM GBL_Template_Layout WHERE LayoutID=tldh.LayoutID) HeaderSystemLayout,
		tldf.LayoutHTML AS FooterLayoutHTML, tldf.LayoutHTMLURL AS FooterLayoutHTMLURL, (SELECT SystemLayout FROM GBL_Template_Layout WHERE LayoutID=tldf.LayoutID) FooterSystemLayout
	FROM GBL_Template tp
	INNER JOIN GBL_Template_Description tpd
		ON tp.Template_ID=tpd.Template_ID AND tpd.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Description WHERE Template_ID=tpd.Template_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Template_Layout_Description tldh
		ON tldh.LayoutID=HeaderLayout AND tldh.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Layout_Description WHERE LayoutID=tldh.LayoutID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Template_Layout_Description tldf
		ON tldf.LayoutID=FooterLayout AND tldf.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Layout_Description WHERE LayoutID=tldf.LayoutID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE
	tp.Template_ID = @Template_ID

SELECT *
	FROM GBL_Template_Menu
WHERE Template_ID=@Template_ID AND LangID=@@LANGID AND MenuType IN ('header', 'footer')
ORDER BY MenuType, MenuGroup, DisplayOrder, Display

RETURN @Error

SET NOCOUNT OFF

GO






GRANT EXECUTE ON  [dbo].[sp_GBL_Template_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_s] TO [cioc_vol_search_role]
GO
