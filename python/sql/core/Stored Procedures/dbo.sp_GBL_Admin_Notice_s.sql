SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Admin_Notice_s]
	@AdminNoticeID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 23-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

SELECT an.*, 
		CASE WHEN adm.CheckListSearch IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Checklist') + cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') END + COALESCE(admn.Name, fod.FieldDisplay, fo.FieldName, vfod.FieldDisplay, vfo.FieldName, adm.AreaCode) AS AreaName,

	adm.AreaCode, adm.Domain, adm.Inactive, adm.CheckListSearch, 
	adm.ManageLocation, adm.ManageLocationParams, adm.CheckGblFieldActive, 
	adm.CheckVolFieldActive
FROM GBL_Admin_Notice an
INNER JOIN GBL_Admin_Area adm
	ON an.AdminAreaID=adm.AdminAreaID
LEFT JOIN GBL_Admin_Area_Name admn
	ON admn.AdminAreaID=adm.AdminAreaID AND admn.LangID=(SELECT TOP 1 LangID FROM GBL_Admin_Area_Name WHERE AdminAreaID=admn.AdminAreaID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN GBL_FieldOption fo
	ON adm.CheckListSearch=fo.CheckListSearch AND adm.Domain IN (1,3,4)
LEFT JOIN GBL_FieldOption_Description fod
	ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
LEFT JOIN VOL_FieldOption vfo
	ON adm.CheckListSearch=vfo.CheckListSearch AND adm.Domain=2
LEFT JOIN VOL_FieldOption_Description vfod
	ON vfo.FieldID=vfod.FieldID AND vfod.LangID=@@LANGID

WHERE AdminNoticeID=@AdminNoticeID

SET NOCOUNT OFF

















GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Admin_Notice_s] TO [cioc_login_role]
GO
