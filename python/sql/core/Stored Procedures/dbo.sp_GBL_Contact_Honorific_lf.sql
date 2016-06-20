SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Contact_Honorific_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT h.*, Honorific AS OldValue, 
		(SELECT COUNT (*) FROM GBL_BaseTable bt 
			WHERE EXISTS(SELECT * FROM GBL_Contact WHERE GblNUM IS NOT NULL AND bt.NUM=GblNUM AND NAME_HONORIFIC=h.Honorific)) AS Usage1,
		(SELECT COUNT (*) FROM VOL_Opportunity op 
			WHERE EXISTS(SELECT * FROM GBL_Contact WHERE VolVNUM IS NOT NULL AND op.VNUM=VolVNUM AND NAME_HONORIFIC=h.Honorific)) AS Usage2
	FROM GBL_Contact_Honorific h
ORDER BY Honorific

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_Honorific_lf] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_Honorific_lf] TO [cioc_login_role]
GO
