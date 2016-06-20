SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_s_CanCopy_2]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT	fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN VOL_View_UpdateField uf
		ON fo.FieldID = uf.FieldID
WHERE	(CanUseUpdate = 1) 
		AND (uf.ViewType = @ViewType)
		AND FieldName NOT IN ('VNUM','RECORD_OWNER','NON_PUBLIC','NUM','POSITION_TITLE')
ORDER BY fo.DisplayOrder, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_s_CanCopy_2] TO [cioc_login_role]
GO
