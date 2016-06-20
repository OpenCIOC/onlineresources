SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Field_l]
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT FieldName, ISNULL(FieldDisplay,FieldName) AS FieldDisplay
	FROM CIC_ImportEntry_Field ief
	INNER JOIN GBL_FieldOption fo
		ON ief.FieldID=fo.FieldID
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE EF_ID=@EF_ID
ORDER BY FieldName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Field_l] TO [cioc_login_role]
GO
