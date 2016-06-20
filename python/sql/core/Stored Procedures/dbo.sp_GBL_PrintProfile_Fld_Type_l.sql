SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_Fld_Type_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT ft.FieldTypeID, FieldType
	FROM GBL_PrintProfile_Fld_Type ft
	INNER JOIN GBL_PrintProfile_Fld_Type_Name ftn
		ON ft.FieldTypeID=ftn.FieldTypeID
			AND LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Fld_Type_Name WHERE ftn.FieldTypeID=FieldTypeID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Fld_Type_l] TO [cioc_login_role]
GO
