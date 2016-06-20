
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_MembershipType_l]
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT mt.MT_ID, CASE WHEN mtn.LangID=@@LANGID THEN mtn.Name ELSE '[' + mtn.Name + ']' END AS MembershipType
	FROM CIC_MembershipType mt
	INNER JOIN CIC_MembershipType_Name mtn
		ON mt.MT_ID=mtn.MT_ID
			AND mtn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_MembershipType_Name WHERE MT_ID=mt.MT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE (mt.MemberID IS NULL OR @MemberID IS NULL OR mt.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_MembershipType_InactiveByMember WHERE MT_ID=mt.MT_ID AND MemberID=@MemberID)
	)
ORDER BY mt.DisplayOrder, mtn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_MembershipType_l] TO [cioc_login_role]
GO
