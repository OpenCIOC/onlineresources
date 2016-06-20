SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Fields_l] (
	@MemberID [int]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 08-Jun-2012
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

SELECT	fo.FieldID,
		fo.FieldName,
		fod.FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE fi.FieldID IS NULL
	AND ( fo.PB_ID IS NULL OR ( 
	EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=fo.PB_ID AND (pb.MemberID IS NULL OR pb.MemberID=@MemberID)) 
	AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=fo.PB_ID AND pbi.MemberID=@MemberID) ))
ORDER BY FieldName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Fields_l] TO [cioc_login_role]
GO
