SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_l]
	@MemberID INT,
	@Archived BIT = 0
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
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
	SET @MemberID = NULL
END

SELECT ie.EF_ID,
		ISNULL(ie.DisplayName, ie.[FileName]) AS DisplayName,
		LoadDate,
		LoadedBy,
		QDate,
		QBy,
		(SELECT COUNT(*)
			FROM GBL_BaseTable bt
			INNER JOIN CIC_ImportEntry_Data ied
				ON bt.NUM=ied.NUM
			WHERE ied.EF_ID=ie.EF_ID
				AND ied.DATA IS NOT NULL
				AND bt.MemberID=@MemberID
				AND ied.IMPORTED=0
		) AS UpdateCount,
		(SELECT COUNT(*)
			FROM GBL_BaseTable bt
			INNER JOIN CIC_ImportEntry_Data ied
				ON bt.NUM=ied.NUM
			WHERE ied.EF_ID=ie.EF_ID
				AND ied.DATA IS NOT NULL
				AND bt.MemberID<>@MemberID
				AND ied.IMPORTED=0
		) AS NoUpdateCount,
		(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE NOT EXISTS (SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)
				AND ied.EF_ID=ie.EF_ID
				AND ied.DATA IS NOT NULL
				AND ied.IMPORTED=0
		) AS AddCount,
		(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=ie.EF_ID
				AND  ied.DATA IS NULL OR ied.IMPORTED=1
		) AS CompletedCount
	FROM CIC_ImportEntry ie
WHERE MemberID=@MemberID AND ie.Archived=@Archived

ORDER BY LoadDate

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_l] TO [cioc_login_role]
GO
