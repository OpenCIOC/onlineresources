SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Source_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT	s.*,
		(SELECT sn.SourceName, l.Culture
			FROM THS_Source_Name sn
			INNER JOIN STP_Language l
				ON sn.LangID=l.LangID
			WHERE sn.SRC_ID=s.SRC_ID
			FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions,
		(SELECT COUNT(*) FROM THS_Subject WHERE SRC_ID=s.SRC_ID) AS Usage
FROM THS_Source s

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_THS_Source_lf] TO [cioc_login_role]
GO
