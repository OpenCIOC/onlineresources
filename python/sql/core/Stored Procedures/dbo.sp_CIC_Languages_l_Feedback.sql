
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Languages_l_Feedback](
	@Value xml
)
WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.7
	Checked by: CL
	Checked on: 30-Aug-2015
	Action: NO ACTION REQUIRED
*/

SELECT	lnn.Name,
STUFF((SELECT ', ' + REPLACE(REPLACE(REPLACE(lndn.Name, '&', '&amp;'), '>', '&gt;'), '<', '&lt;')
	FROM N.nodes('LNDS/LND') AS T(D)
	INNER JOIN dbo.GBL_Language_Details lnd
		ON D.value('.', 'int')=lnd.LND_ID
	INNER JOIN dbo.GBL_Language_Details_Name lndn
		ON lndn.LND_ID=lnd.LND_ID AND lndn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Language_Details_Name WHERE LND_ID=lnd.LND_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	ORDER BY lnd.DisplayOrder, Name
 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '') AS DETAILS,
N.value('@NOTE', 'nvarchar(255)') AS NOTE
FROM @Value.nodes('//LN') AS T(N)
INNER JOIN dbo.GBL_Language ln
ON ln.LN_ID=N.value('@ID', 'int')
LEFT JOIN dbo.GBL_Language_Name lnn
ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Language_Name WHERE LN_ID=ln.LN_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY ln.DisplayOrder, Name

END

GO


GRANT EXECUTE ON  [dbo].[sp_CIC_Languages_l_Feedback] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Languages_l_Feedback] TO [cioc_login_role]
GO
