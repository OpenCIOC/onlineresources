
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_RecordType_l]
	@MemberID [int],
	@ShowHidden [bit],
	@OverrideID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT rt.RT_ID, rt.RecordType, rtn.Name AS RecordTypeName
	FROM CIC_RecordType rt
	LEFT JOIN CIC_RecordType_Name rtn
		ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
WHERE rt.RT_ID=@OverrideID
	OR (
		(rt.MemberID IS NULL OR @MemberID IS NULL OR rt.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_RecordType_InactiveByMember WHERE RT_ID=rt.RT_ID AND MemberID=@MemberID)
		)
	)
ORDER BY rt.DisplayOrder, rt.RecordType

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_RecordType_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_RecordType_l] TO [cioc_login_role]
GO
