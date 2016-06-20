SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_FieldOption_l_Extra]
	@ExtraFieldType char(1)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 23-Feb-2015
	Action: NO ACTION REQUIRED
*/

SELECT	fo.FieldID,
		MemberID,
		CASE
			WHEN ExtraFieldType IN ('a','d') THEN REPLACE(fo.FieldName,'EXTRA_DATE_','')
			WHEN ExtraFieldType='e' THEN REPLACE(fo.FieldName,'EXTRA_EMAIL_','')
			WHEN ExtraFieldType = 'l' THEN REPLACE(fo.FieldName,'EXTRA_CHECKLIST_','')
			WHEN ExtraFieldType = 'p' THEN REPLACE(fo.FieldName,'EXTRA_DROPDOWN_','')
			WHEN ExtraFieldType='r' THEN REPLACE(fo.FieldName,'EXTRA_RADIO_','')
			WHEN ExtraFieldType='t' THEN REPLACE(fo.FieldName,'EXTRA_','')
			WHEN ExtraFieldType='w' THEN REPLACE(fo.FieldName,'EXTRA_WWW_','')
		END AS ExtraFieldName,
		ISNULL(fod.FieldDisplay,fo.FieldName) AS FieldDisplay,
		fo.MaxLength,
		fo.FullTextIndex,
		fo.ExtraFieldType,
		CASE
			WHEN ExtraFieldType IN ('a', 'd') THEN (SELECT COUNT(*) FROM VOL_OP_EXTRA_DATE WHERE FieldName=fo.FieldName)
			WHEN ExtraFieldType='e' THEN (SELECT COUNT(*) FROM VOL_OP_EXTRA_EMAIL WHERE FieldName=fo.FieldName)
			WHEN ExtraFieldType='l' THEN (SELECT COUNT(*) FROM (SELECT DISTINCT VNUM FROM VOL_OP_EXC WHERE FieldName_Cache=fo.FieldName) src)
			WHEN ExtraFieldType='p' THEN (SELECT COUNT(*) FROM VOL_OP_EXD WHERE FieldName_Cache=fo.FieldName)
			WHEN ExtraFieldType='r' THEN (SELECT COUNT(*) FROM VOL_OP_EXTRA_RADIO WHERE FieldName=fo.FieldName)
			WHEN ExtraFieldType='t' THEN (SELECT COUNT(*) FROM VOL_OP_EXTRA_TEXT WHERE FieldName=fo.FieldName)
			WHEN ExtraFieldType='w' THEN (SELECT COUNT(*) FROM VOL_OP_EXTRA_WWW WHERE FieldName=fo.FieldName)
		END AS Usage,
		(SELECT TOP 1 MemberNameVOL FROM STP_Member_Description WHERE MemberID=fo.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) MemberName
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE ExtraFieldType=@ExtraFieldType OR (@ExtraFieldType IN ('a','d') AND ExtraFieldType IN ('a','d'))
ORDER BY ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_l_Extra] TO [cioc_login_role]
GO
