SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_l_CanUpdate]
	@User_ID [int],
	@ViewType [int],
	@BT_VUT_ID_List varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

SELECT BT_VUT_ID
FROM CIC_BT_VUT btvut
INNER JOIN dbo.fn_GBL_ParseIntIDList(@BT_VUT_ID_List, ',') idlist
	ON btvut.BT_VUT_ID=idlist.ItemID
WHERE dbo.fn_CIC_CanUpdateVacancy(btvut.NUM, @User_ID, @ViewType, @@LANGID, GETDATE())=1

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_l_CanUpdate] TO [cioc_cic_search_role]
GO
