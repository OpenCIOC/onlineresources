SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Page_s_Slug] (
	@MemberID [int],
	@Slug varchar(50),
	@ViewType int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT p.PageID,
       p.CREATED_DATE,
       p.CREATED_BY,
       p.MODIFIED_DATE,
       p.MODIFIED_BY,
       p.MemberID,
       p.DM,
       p.LangID,
       p.Owner,
       p.Slug,
       p.Title,
       p.PageContent,
       p.PublishAsArticle,
       p.Author,
       p.DisplayPublishDate,
       p.Category,
       p.PreviewText,
       p.ThumbnailImageURL
	FROM dbo.GBL_Page p
WHERE MemberID = @MemberID
	AND DM = 1
	AND LangID = @@LANGID
	AND Slug = @Slug
	AND EXISTS(SELECT * FROM dbo.CIC_Page_View WHERE PageID=p.PageID AND ViewType=@ViewType)

SELECT p.Title, l.Culture
	FROM dbo.GBL_Page p 
	INNER JOIN dbo.STP_Language l
		ON l.LangID=p.LangID
WHERE p.MemberID = @MemberID
	AND p.DM = 1
	AND p.Slug = @Slug
	AND EXISTS(SELECT * FROM dbo.CIC_Page_View WHERE PageID=p.PageID AND ViewType=@ViewType)

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Page_s_Slug] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Page_s_Slug] TO [cioc_login_role]
GO
