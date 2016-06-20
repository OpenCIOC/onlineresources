SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Field_Radio_l]
	@AllDescriptions [bit] = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action:	NO ACTION REQUIRED
*/

SELECT	fo.FieldID,
		fo.FieldName,
		CASE WHEN fo.FieldType = 'GBL' THEN 1 ELSE 0 END AS  Shared, 
		(SELECT TOP 1 FieldDisplay FROM GBL_FieldOption_Description WHERE FieldID=fo.FieldID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS FieldDisplay,
		(SELECT fod.CheckboxOnText, fod.CheckboxOffText, l.Culture
			FROM GBL_FieldOption_Description fod
				INNER JOIN STP_Language l
					ON l.LangID=fod.LangID AND @AllDescriptions = 1
			WHERE fod.FieldID=fo.FieldID
			FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions
	FROM GBL_FieldOption fo
WHERE FormFieldType = 'c'
	AND EXISTS(
			SELECT * FROM STP_Member mem
			WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_InactiveByMember fi WHERE fi.MemberID=mem.MemberID AND fi.FieldID=fo.FieldID)
		)
ORDER BY DisplayOrder, FieldName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Field_Radio_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Field_Radio_l] TO [cioc_login_role]
GO
