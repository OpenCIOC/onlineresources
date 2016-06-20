
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_l_Admin]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 04-Jun-2015
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
END

SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, pbn.Name AS PubName,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID) THEN 1 ELSE 0 END AS bit) AS HasHeadings,
		(SELECT COUNT(*)
			FROM CIC_BT_PB pr
			INNER JOIN GBL_BaseTable bt
				ON pr.NUM=bt.NUM AND (@MemberID IS NULL OR bt.MemberID=@MemberID)
			WHERE pb.PB_ID=PB_ID) AS UsageCountLocal,
		(SELECT COUNT(*)
			FROM CIC_BT_PB pr
			INNER JOIN GBL_BaseTable bt
				ON pr.NUM=bt.NUM AND @MemberID IS NOT NULL AND bt.MemberID<>@MemberID
			WHERE pb.PB_ID=PB_ID) AS UsageCountOther,
		(SELECT COUNT(*)
			FROM CIC_View vw
			WHERE pb.PB_ID=PB_ID AND (@MemberID IS NULL OR vw.MemberID=@MemberID)) AS ViewCountLocal
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE @MemberID IS NULL OR MemberID=@MemberID
ORDER BY pb.PubCode

IF @MemberID IS NOT NULL BEGIN
SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, pbn.Name AS PubName, pb.CanEditHeadingsShared,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=@MemberID AND PB_ID=pb.PB_ID) THEN 1 ELSE 0 END AS bit) AS Hide,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID) THEN 1 ELSE 0 END AS bit) AS HasHeadings,
		(SELECT mem.MemberID, ISNULL(memd.MemberNameCIC,memd.MemberName) AS MemberName
			FROM STP_Member mem
			LEFT JOIN STP_Member_Description memd
				ON mem.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=mem.MemberID ORDER BY CASE WHEN MemberNameCIC IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.MemberID=mem.MemberID AND pbi.PB_ID=pb.PB_ID)
			FOR XML PATH('MEMBER'), ROOT('MEMBERS'), TYPE) AS InUseByMembers,
		(SELECT COUNT(*)
			FROM CIC_BT_PB pr
			INNER JOIN GBL_BaseTable bt
				ON pr.NUM=bt.NUM AND bt.MemberID=@MemberID
			WHERE pb.PB_ID=PB_ID) AS UsageCountLocal,
		(SELECT COUNT(*)
			FROM CIC_BT_PB pr
			INNER JOIN GBL_BaseTable bt
				ON pr.NUM=bt.NUM AND bt.MemberID<>@MemberID
			WHERE pb.PB_ID=PB_ID) AS UsageCountOther,
		(SELECT COUNT(*)
			FROM CIC_View vw
			WHERE pb.PB_ID=PB_ID AND vw.MemberID=@MemberID) AS ViewCountLocal,
		(SELECT COUNT(*)
			FROM CIC_View vw
			WHERE pb.PB_ID=PB_ID AND vw.MemberID<>@MemberID) AS ViewCountOther
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE MemberID IS NULL
ORDER BY pb.PubCode

SELECT COUNT(*) AS OtherMemberPubCount FROM CIC_Publication WHERE MemberID<>@MemberID

END

RETURN @Error

SET NOCOUNT OFF

GO


GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Admin] TO [cioc_login_role]
GO
