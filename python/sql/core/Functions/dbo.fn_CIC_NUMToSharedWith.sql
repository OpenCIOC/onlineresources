SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToSharedWith](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + ISNULL(memd.MemberNameCIC,memd.MemberName)
	FROM STP_Member mem
	INNER JOIN STP_Member_Description memd
		ON mem.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=memd.MemberID ORDER BY CASE WHEN MemberNameCIC IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_SharingProfile shp
		ON mem.MemberID=shp.ShareMemberID
			AND shp.Active=1
	INNER JOIN GBL_BT_SharingProfile shpr
		ON shp.ProfileID=shpr.ProfileID
			AND shpr.NUM=@NUM

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToSharedWith] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToSharedWith] TO [cioc_login_role]
GO
