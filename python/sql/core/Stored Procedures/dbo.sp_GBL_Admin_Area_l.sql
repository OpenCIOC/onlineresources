SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Admin_Area_l]
	@MemberID [int],
	@SelectedID [int]
WITH EXECUTE AS CALLER
AS

SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Dec-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE	@UseCIC bit,
		@UseVOL bit

SELECT TOP 1 @UseCIC=UseCIC, @UseVOL=UseVOL
	FROM STP_Member
WHERE MemberID=@MemberID

SELECT adm.AdminAreaID,
		CASE WHEN adm.CheckListSearch IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Checklist') + cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') END + COALESCE(admn.Name, fod.FieldDisplay, fo.FieldName, vfod.FieldDisplay, vfo.FieldName, adm.AreaCode) AS Name,
		adm.AreaCode,
		adm.Domain
	FROM GBL_Admin_Area adm
	LEFT JOIN GBL_Admin_Area_Name admn
		ON adm.AdminAreaID=admn.AdminAreaID AND admn.LangID=(SELECT TOP 1 LangID FROM GBL_Admin_Area_Name WHERE AdminAreaID=adm.AdminAreaID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_FieldOption fo
		ON adm.CheckListSearch=fo.CheckListSearch AND adm.Domain IN (1,3,4)
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN VOL_FieldOption vfo
		ON adm.CheckListSearch=vfo.CheckListSearch AND adm.Domain=2
	LEFT JOIN VOL_FieldOption_Description vfod
		ON vfo.FieldID=vfod.FieldID AND vfod.LangID=@@LANGID
WHERE @SelectedID=adm.AdminAreaID OR
	(
		(@UseCIC=1 OR Domain NOT IN (1,3)) AND (@UseVOL=1 OR Domain NOT IN (2))
		AND ((CheckGblFieldActive IS NULL AND CheckVolFieldActive IS NULL)
			OR EXISTS(SELECT *
				FROM GBL_FieldOption
				LEFT JOIN GBL_FieldOption_InactiveByMember fi
					ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
				WHERE FieldName=CheckGblFieldActive AND fi.FieldID IS NULL)
			OR EXISTS(SELECT *
				FROM VOL_FieldOption
				LEFT JOIN VOL_FieldOption_InactiveByMember fi
					ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
				WHERE FieldName=CheckVolFieldActive AND fi.FieldID IS NULL)
		)
			
	)
ORDER BY Name

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Admin_Area_l] TO [cioc_login_role]
GO
