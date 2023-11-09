SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_Page_l_Index] (
	@ViewType [int]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @Error int;
SET @Error = 0;

SELECT
    p.Slug,
    p.Title,
	cioc_shared.dbo.fn_SHR_GBL_DateString(p.DisplayPublishDate) AS DisplayPublishDate,
	p.Author,
	p.Category,
	p.ThumbnailImageURL,
	p.PreviewText
FROM    dbo.GBL_Page p
    INNER JOIN dbo.VOL_Page_View pv
		ON p.PageID=pv.PageID AND pv.ViewType=@ViewType
WHERE p.PublishAsArticle = 1
	AND (p.DisplayPublishDate IS NULL OR p.DisplayPublishDate <= GETDATE())
	AND p.LangID=@@LANGID
ORDER BY
	ISNULL(p.DisplayPublishDate,p.MODIFIED_DATE), p.Title;

RETURN @Error;

SET NOCOUNT OFF;



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Page_l_Index] TO [cioc_vol_search_role]
GO
