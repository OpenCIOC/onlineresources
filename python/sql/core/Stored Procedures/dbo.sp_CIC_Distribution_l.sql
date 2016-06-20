
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Distribution_l]
	@MemberID [int],
	@ShowHidden [bit]
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

SELECT dst.DST_ID, dst.DistCode, dstn.Name AS DistName
	FROM CIC_Distribution dst
	LEFT JOIN CIC_Distribution_Name dstn
		ON dst.DST_ID=dstn.DST_ID AND LangID=@@LANGID
WHERE (dst.MemberID IS NULL OR @MemberID IS NULL OR dst.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_Distribution_InactiveByMember WHERE DST_ID=dst.DST_ID AND MemberID=@MemberID)
	)
ORDER BY DistCode

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Distribution_l] TO [cioc_login_role]
GO
