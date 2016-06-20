SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_RecordNote_Type_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT nt.NoteTypeID, nt.HighPriority, ISNULL(ntn.Name,nt.Code) AS NoteTypeName
	FROM GBL_RecordNote_Type nt
	LEFT JOIN GBL_RecordNote_Type_Name ntn
		ON nt.NoteTypeID=ntn.NoteTypeID AND ntn.LangID=@@LANGID
ORDER BY nt.HighPriority DESC, ISNULL(ntn.Name,nt.Code)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_RecordNote_Type_l] TO [cioc_login_role]
GO
