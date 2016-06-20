
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMVacancy_s]
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

SELECT prtp.BT_VUT_ID, prtp.VTP_ID
	FROM CIC_BT_VUT prut
	INNER JOIN CIC_BT_VUT_TP prtp
	ON prut.BT_VUT_ID=prtp.BT_VUT_ID
WHERE prut.NUM=@NUM

SELECT	pr.*,
		vutn.Name AS UnitTypeName,
		prn.ServiceTitle, prn.Notes,
		(SELECT TOP 1 BT_VUT_HIST_ID FROM CIC_BT_VUT_History h WHERE pr.BT_VUT_ID=h.BT_VUT_ID ORDER BY MODIFIED_DATE DESC, BT_VUT_HIST_ID DESC) AS LastVacancyChange
	FROM CIC_Vacancy_UnitType vut
	INNER JOIN CIC_Vacancy_UnitType_Name vutn
		ON vut.VUT_ID=vutn.VUT_ID AND LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_UnitType_Name WHERE VUT_ID=vut.VUT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN CIC_BT_VUT pr
		ON vut.VUT_ID=pr.VUT_ID
	LEFT JOIN CIC_BT_VUT_Notes prn
		ON pr.BT_VUT_ID=prn.BT_VUT_ID AND prn.LangID=@@LANGID
WHERE pr.NUM=@NUM

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_NUMVacancy_s] TO [cioc_login_role]
GO
