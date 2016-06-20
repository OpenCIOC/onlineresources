
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_FieldOption_sf_Help]
	@FieldID [int],
	@MemberID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 05-Sep-2014
	Action: NO ACTION REQUIRED
*/

SELECT	fo.FieldID,
		fo.FieldName,
		(SELECT fod.FieldDisplay FROM GBL_FieldOption_Description fod WHERE fod.FieldID=fo.FieldID AND LangID=@@LANGID) AS FieldDisplay
FROM GBL_FieldOption fo
WHERE FieldID=@FieldID

SELECT fod.HelpText, l.Culture, foh.HelpText AS HelpTextMember
FROM GBL_FieldOption_Description fod
INNER JOIN STP_Language l
	ON l.LangID=fod.LangID AND l.ActiveRecord=1
LEFT JOIN GBL_FieldOption_HelpByMember foh
	ON foh.FieldID = fod.FieldID AND foh.LangID = fod.LangID AND MemberID=@MemberID
WHERE fod.FieldID=@FieldID
	
SET NOCOUNT OFF






GO

GRANT EXECUTE ON  [dbo].[sp_CIC_FieldOption_sf_Help] TO [cioc_login_role]
GO
