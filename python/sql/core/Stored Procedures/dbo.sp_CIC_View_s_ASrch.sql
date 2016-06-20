SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_ASrch]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT	SrchCommunityDefault,
		ASrchAddress,
		ASrchAges,
		ASrchBool,
		ASrchEmail,
		ASrchEmployee,
		ASrchLastRequest,
		ASrchNear,
		ASrchOwner,
		ASrchVacancy,
		ASrchVOL,
		CSrch
	FROM CIC_View vw
WHERE ViewType = @ViewType

SELECT ISNULL(FieldDisplay, FieldName) AS FieldDisplay, ChecklistSearch
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_ChkField cfd
		ON fo.FieldID=cfd.FieldID AND cfd.ViewType=@ViewType
WHERE ChecklistSearch IS NOT NULL
ORDER BY ISNULL(FieldDisplay, FieldName)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_ASrch] TO [cioc_login_role]
GO
