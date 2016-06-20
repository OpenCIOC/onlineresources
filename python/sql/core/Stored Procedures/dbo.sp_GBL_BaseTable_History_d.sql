SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_d]
WITH EXECUTE AS CALLER
AS

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DELETE hst2
	FROM GBL_BaseTable_History hst2
	INNER JOIN GBL_FieldOption fo
		ON hst2.FieldID=fo.FieldID
WHERE EXISTS(SELECT * FROM (SELECT HST_ID, ROW_NUMBER() OVER (ORDER BY hst.MODIFIED_DATE DESC) AS EntryNumber
					FROM GBL_BaseTable_History hst
					WHERE hst.FieldID=hst2.FieldID AND hst.NUM=hst2.NUM AND hst.LangID=hst2.LangID) y
		WHERE y.HST_ID=hst2.HST_ID AND EntryNumber > ChangeHistory)


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_d] TO [cioc_login_role]
GO
