SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Page_l] (@MemberID [int], @DM [tinyint], @AgencyCode char(3))
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @Error int;
SET @Error = 0;

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS (SELECT * FROM  dbo.STP_Member WHERE MemberID = @MemberID) BEGIN
    SET @Error = 3; -- No Such Record
END;

SELECT
    p.PageID,
    p.Slug,
    p.Title,
	p.PublishAsArticle,
	p.DisplayPublishDate,
    l.Culture
FROM    dbo.GBL_Page p
    INNER JOIN dbo.STP_Language l
        ON p.LangID = l.LangID
WHERE   p.MemberID = @MemberID AND p.DM = @DM AND (p.Owner IS NULL OR p.Owner = @AgencyCode)
ORDER BY
	p.PublishAsArticle,
    l.LangID,
    p.Title;


RETURN @Error;

SET NOCOUNT OFF;



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Page_l] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Page_l] TO [cioc_login_role]
GO
