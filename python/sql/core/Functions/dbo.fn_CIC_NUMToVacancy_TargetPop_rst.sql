SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToVacancy_TargetPop_rst](
	@BT_VUT_ID int
)
RETURNS @TargetPop TABLE (
	[TP_ID] int NULL,
	[TargetPopulation] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TargetPop
SELECT vtp.VTP_ID, vtpn.Name
	FROM CIC_BT_VUT_TP pr
	INNER JOIN CIC_Vacancy_TargetPop vtp
		ON pr.VTP_ID = vtp.VTP_ID
	INNER JOIN CIC_Vacancy_TargetPop_Name vtpn
		ON vtp.VTP_ID = vtpn.VTP_ID AND LangID=@@LANGID
WHERE pr.BT_VUT_ID = @BT_VUT_ID
ORDER BY vtp.DisplayOrder, vtpn.Name

RETURN

END
GO
