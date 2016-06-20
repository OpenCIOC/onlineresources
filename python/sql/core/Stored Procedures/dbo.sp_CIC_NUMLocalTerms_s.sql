SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMLocalTerms_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT sj.Subj_ID, CASE WHEN sjn.LangID=@@LANGID THEN sjn.Name ELSE '[' + sjn.Name + ']' END AS SubjectTerm
	FROM CIC_BT_SBJ pr
	INNER JOIN THS_Subject sj
		ON pr.Subj_ID = sj.Subj_ID
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE pr.NUM = @NUM
	AND sj.Authorized=0
ORDER BY sjn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMLocalTerms_s] TO [cioc_login_role]
GO
