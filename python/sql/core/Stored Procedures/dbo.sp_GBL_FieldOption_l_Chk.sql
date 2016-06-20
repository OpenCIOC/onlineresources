
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_FieldOption_l_Chk]
	@MemberID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 13-Aug-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT FieldType, CASE WHEN FieldType='GBL' THEN 0 WHEN FieldType='VOL' THEN 2 ELSE 1 END,ISNULL(FieldDisplay, FieldName) AS FieldDisplay, CASE WHEN ChecklistSearch IN ('scha','sche') THEN 'sch' ELSE ChecklistSearch END AS ChecklistSearch
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE ChecklistSearch IS NOT NULL AND ChecklistSearch NOT IN ('cm','lcm','map','sm')
	AND (
		fi.FieldID IS NULL
		OR (@MemberID IS NULL AND EXISTS(SELECT * FROM STP_Member mem WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_InactiveByMember WHERE MemberID=mem.MemberID AND FieldID=fo.FieldID)))
	)
UNION SELECT FieldType, CASE WHEN FieldType='GBL' THEN 0 WHEN FieldType='VOL' THEN 2 ELSE 1 END, ISNULL(FieldDisplay, FieldName) AS FieldDisplay, ChecklistSearch
	FROM VOL_FieldOption vfo
	LEFT JOIN VOL_FieldOption_Description vfod
		ON vfo.FieldID=vfod.FieldID and vfod.LangID=@@LANGID
	LEFT JOIN VOL_FieldOption_InactiveByMember fi
		ON vfo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE ChecklistSearch IS NOT NULL AND ChecklistSearch NOT IN ('ac','sm','ai')
	AND (
		fi.FieldID IS NULL
		OR (@MemberID IS NULL AND EXISTS(SELECT * FROM STP_Member mem WHERE NOT EXISTS(SELECT * FROM VOL_FieldOption_InactiveByMember WHERE MemberID=mem.MemberID AND FieldID=vfo.FieldID)))
	)
-- special creation of sub-checklist for language details
UNION SELECT FieldType, CASE WHEN FieldType='GBL' THEN 0 WHEN FieldType='VOL' THEN 2 ELSE 1 END,ISNULL(FieldDisplay, FieldName) + cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + cioc_shared.dbo.fn_SHR_STP_ObjectName('Detail') AS FieldDisplay, 'lnd' AS ChecklistSearch
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE ChecklistSearch='ln'
	AND (
		fi.FieldID IS NULL
		OR (@MemberID IS NULL AND EXISTS(SELECT * FROM STP_Member mem WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_InactiveByMember WHERE MemberID=mem.MemberID AND FieldID=fo.FieldID)))
	)
ORDER BY CASE WHEN FieldType='GBL' THEN 0 WHEN FieldType='VOL' THEN 2 ELSE 1 END, ISNULL(FieldDisplay, FieldName)

RETURN @Error

SET NOCOUNT OFF




GO


GRANT EXECUTE ON  [dbo].[sp_GBL_FieldOption_l_Chk] TO [cioc_login_role]
GO
