
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToLanguages](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 30-Aug-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')  + LanguageName
FROM (SELECT
		+ lnn.Name
		+ CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND prlnd WHERE prlnd.BT_LN_ID=pr.BT_LN_ID)
			THEN cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) ELSE '' END
		+ ISNULL((SELECT STUFF((SELECT ', ' + ISNULL(lndn.Name,lnd.Code)
            FROM dbo.CIC_BT_LN_LND prlnd
			INNER JOIN dbo.GBL_Language_Details lnd
				ON lnd.LND_ID = prlnd.LND_ID
			LEFT JOIN dbo.GBL_Language_Details_Name lndn
				ON lndn.LND_ID = lnd.LND_ID AND lndn.LangID=@LangID
			WHERE prlnd.BT_LN_ID=pr.BT_LN_ID
            FOR XML PATH('')) ,1,2,'')),'')
		+ CASE WHEN prn.Notes IS NULL THEN ''
			ELSE CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND prlnd WHERE prlnd.BT_LN_ID=pr.BT_LN_ID)
			THEN ', ' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) END + prn.Notes END AS LanguageName,
		ln.DisplayOrder
	FROM CIC_BT_LN pr
	LEFT JOIN CIC_BT_LN_Notes prn
		ON pr.BT_LN_ID=prn.BT_LN_ID AND prn.LangID=@LangID
	INNER JOIN GBL_Language ln
		ON pr.LN_ID=ln.LN_ID
	INNER JOIN GBL_Language_Name lnn
		ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=ln.LN_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
	WHERE NUM = @NUM
	) x
ORDER BY x.DisplayOrder, x.LanguageName

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO




GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToLanguages] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToLanguages] TO [cioc_login_role]
GO
