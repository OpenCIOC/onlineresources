SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMMembershipType_s]
	@MemberID int,
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT mt.MT_ID, mtn.LangID, CASE WHEN mtn.LangID=@@LANGID THEN mtn.Name ELSE '[' + mtn.Name + ']' END AS MembershipType,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM CIC_MembershipType mt
	INNER JOIN CIC_MembershipType_Name mtn
		ON mt.MT_ID=mtn.MT_ID
			AND LangID=(SELECT TOP 1 LangID FROM CIC_MembershipType_Name WHERE MT_ID=mt.MT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_BT_MT pr
		ON mt.MT_ID=pr.MT_ID AND pr.NUM=@NUM
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
WHERE pr.BT_MT_ID IS NOT NULL
	OR mt.MemberID=bt.MemberID
	OR mt.MemberID=@MemberID
	OR mt.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM CIC_MembershipType_InactiveByMember WHERE MT_ID=mt.MT_ID AND MemberID=@MemberID)
		OR NOT EXISTS(SELECT * FROM CIC_MembershipType_InactiveByMember WHERE MT_ID=mt.MT_ID AND MemberID=bt.MemberID)
	)
ORDER BY mt.DisplayOrder, mtn.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMMembershipType_s] TO [cioc_login_role]
GO
