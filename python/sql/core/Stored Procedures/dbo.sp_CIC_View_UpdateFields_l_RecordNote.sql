SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_UpdateFields_l_RecordNote]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 24-Nov-2012
	Action:	NO ACTION REQUIRED
*/

SELECT DISTINCT ISNULL(FieldDisplay, FieldName) AS FieldDisplay, FieldName
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_UpdateField uf
		ON fo.FieldID=uf.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
WHERE DisplayFM = 'cbtd.CMP_InternalMemo'
ORDER BY ISNULL(FieldDisplay, FieldName)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_UpdateFields_l_RecordNote] TO [cioc_login_role]
GO
