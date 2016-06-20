SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_CIC_DisplayMember_Link](
	@NUM varchar(8)
)
RETURNS nvarchar(255) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7.1
	Checked by: KL
	Checked on: 14-Sep-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(MAX)

SELECT TOP 1 @returnStr = 
	'&copy; <a href="' + 
	CASE WHEN ISNULL(m.FullSSLCompatible, 0)=0 OR tmpl.FullSSLCompatible_Cache=0 THEN 'http://' ELSE 'https://' END + m.DomainName + '/?Ln=' + (SELECT l.Culture FROM STP_Language l WHERE l.LangID=@@LANGID) +
	'">' + CASE WHEN mem.UseMemberNameAsSourceDB=1 THEN ISNULL(memd.MemberNameCIC,memd.MemberName) ELSE memd.DatabaseNameCIC END + '</a>'
FROM STP_Member mem
INNER JOIN STP_Member_Description memd
	ON mem.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=mem.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
INNER JOIN GBL_View_DomainMap m
	ON m.DomainName=mem.BaseURLCIC AND m.MemberID=mem.MemberID
INNER JOIN CIC_View vw
	ON vw.ViewType=ISNULL(m.CICViewType, mem.DefaultViewCIC)
INNER JOIN GBL_Template tmpl
	ON tmpl.Template_ID = vw.Template
INNER JOIN GBL_BaseTable bt
		ON bt.MemberID=mem.MemberID
WHERE bt.NUM=@NUM

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayMember_Link] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayMember_Link] TO [cioc_login_role]
GO
