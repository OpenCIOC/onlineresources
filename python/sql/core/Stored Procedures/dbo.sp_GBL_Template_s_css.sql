SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_s_css]
	@MemberID int,
	@Template_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-Jan-2012
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

IF NOT EXISTS(SELECT * FROM GBL_Template WHERE (MemberID=@MemberID OR MemberID IS NULL) AND Template_ID=@Template_ID) BEGIN
	SELECT @Template_ID=DefaultTemplate FROM STP_Member WHERE MemberID=@MemberID
END

DECLARE @LayoutCSS varchar(max),
		@NewLine char(2)

SET @NewLine = CHAR(13) + CHAR(10)

SELECT *
	FROM GBL_Template tp
WHERE tp.Template_ID=@Template_ID

SELECT LayoutCSS = '/* header layout start */' + @NewLine + ISNULL(LayoutCSS, '/* nothing */') + @NewLine + '/* header layout end */', LayoutCSSURL, SystemLayout
	FROM GBL_Template_Layout
WHERE LayoutID=(SELECT HeaderLayout FROM GBL_Template WHERE Template_ID=@Template_ID)
UNION SELECT LayoutCSS = '/* footer layout start */' + @NewLine + ISNULL(LayoutCSS,'/* nothing */') + @NewLine + '/* footer layout end */', LayoutCSSURL, SystemLayout
	FROM GBL_Template_Layout
WHERE LayoutID=(SELECT FooterLayout FROM GBL_Template WHERE Template_ID=@Template_ID)
UNION SELECT LayoutCSS = '/* cic basic search layout start */' + @NewLine + ISNULL(LayoutCSS,'/* nothing */') + @NewLine + '/* cic basic search layout end */', LayoutCSSURL, SystemLayout
	FROM GBL_Template_Layout
WHERE LayoutID=ISNULL((SELECT SearchLayoutCIC FROM GBL_Template WHERE Template_ID=@Template_ID), (SELECT TOP 1 LayoutID FROM GBL_Template_Layout WHERE LayoutType='cicsearch' AND DefaultSearchLayout=1))
UNION SELECT LayoutCSS = '/* vol basic search layout start */' + @NewLine + ISNULL(LayoutCSS,'/* nothing */') + @NewLine + '/* vol basic search layout end */', LayoutCSSURL, SystemLayout
	FROM GBL_Template_Layout
WHERE LayoutID=ISNULL((SELECT SearchLayoutVOL FROM GBL_Template WHERE Template_ID=@Template_ID), (SELECT TOP 1 LayoutID FROM GBL_Template_Layout WHERE LayoutType='volsearch' AND DefaultSearchLayout=1))

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_s_css] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_s_css] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_s_css] TO [cioc_vol_search_role]
GO
