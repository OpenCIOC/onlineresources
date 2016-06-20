SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_CICF_Check_i]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

EXEC sp_CIC_ImportEntry_CIC_Check_i @NUM

INSERT INTO CIC_BaseTable_Description (NUM,LangID,CREATED_BY)
SELECT NUM,LangID,'(Import)'
	FROM GBL_BaseTable_Description btd
WHERE NUM=@NUM AND LangID=2
	AND NOT EXISTS(SELECT * FROM CIC_BaseTable_Description WHERE NUM=btd.NUM AND LangID=btd.LangID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_CICF_Check_i] TO [cioc_login_role]
GO
