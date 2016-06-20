SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToSharedWith](
	@VNUM varchar(10)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + ISNULL(memd.MemberNameVOL,memd.MemberName)
	FROM STP_Member mem
	INNER JOIN STP_Member_Description memd
		ON mem.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=memd.MemberID ORDER BY CASE WHEN MemberNameVOL IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_SharingProfile shp
		ON mem.MemberID=shp.ShareMemberID
			AND shp.Active=1
	INNER JOIN VOL_OP_SharingProfile shpr
		ON shp.ProfileID=shpr.ProfileID
			AND shpr.VNUM=@VNUM

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSharedWith] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSharedWith] TO [cioc_vol_search_role]
GO
