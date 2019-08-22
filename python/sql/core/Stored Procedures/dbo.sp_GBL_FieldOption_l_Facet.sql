SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_FieldOption_l_Facet]
	@MemberID [INT]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 25-Jul-2019
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT fo.FieldID, ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE fo.FacetFieldList IS NOT NULL
	AND (
		fi.FieldID IS NULL
		OR (@MemberID IS NULL AND EXISTS(SELECT * FROM STP_Member mem WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_InactiveByMember WHERE MemberID=mem.MemberID AND FieldID=fo.FieldID)))
	)
ORDER BY fo.DisplayOrder, ISNULL(FieldDisplay, FieldName)

RETURN @Error

SET NOCOUNT OFF





GO
