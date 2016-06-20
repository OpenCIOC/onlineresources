SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_History_d]
WITH EXECUTE AS CALLER
AS

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DELETE hst2
	FROM VOL_Opportunity_History hst2
	INNER JOIN VOL_FieldOption fo
		ON hst2.FieldID=fo.FieldID
WHERE EXISTS(SELECT * FROM (SELECT HST_ID, ROW_NUMBER() OVER (ORDER BY hst.MODIFIED_DATE DESC) AS EntryNumber
					FROM VOL_Opportunity_History hst
					WHERE hst.FieldID=hst2.FieldID AND hst.VNUM=hst2.VNUM AND hst.LangID=hst2.LangID) y
		WHERE y.HST_ID=hst2.HST_ID AND EntryNumber > ChangeHistory)

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_History_d] TO [cioc_login_role]
GO
