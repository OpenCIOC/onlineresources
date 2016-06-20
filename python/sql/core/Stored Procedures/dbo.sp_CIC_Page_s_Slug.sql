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

SELECT * FROM GBL_Page p
WHERE MemberID=@MemberID AND DM=1 AND LangID=@@LANGID AND @Slug = Slug 
AND EXISTS(SELECT * FROM CIC_Page_View WHERE PageID=p.PageID AND ViewType=@ViewType)

SELECT Title, Culture FROM GBL_Page p 
INNER JOIN STP_Language l
	ON l.LangID=p.LangID
WHERE MemberID=@MemberID AND DM=1 AND @Slug = Slug 
AND EXISTS(SELECT * FROM CIC_Page_View WHERE PageID=p.PageID AND ViewType=@ViewType)

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Page_s_Slug] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Page_s_Slug] TO [cioc_login_role]
GO
