
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Publication_l_SharedLocal]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 12-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, pbn.Name AS PubName,
		CASE WHEN EXISTS(SELECT * FROM dbo.CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID) THEN 1 ELSE 0 END AS HasHeadings
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE (MemberID IS NULL OR MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
ORDER BY pb.PubCode

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_SharedLocal] TO [cioc_login_role]
GO
