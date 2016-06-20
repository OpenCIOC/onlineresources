SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_l_Admin_Print] (
	@MemberID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 07-May-2012
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

SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, pb.MemberID,
	CAST(CASE WHEN MemberID IS NULL AND EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=@MemberID AND PB_ID=pb.PB_ID) THEN 1 ELSE 0 END AS bit) AS Inactive,
	(SELECT COUNT(*)
		FROM CIC_GeneralHeading
		WHERE pb.PB_ID=PB_ID) AS HeadingCount,
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
		WHERE pb.PB_ID=PB_ID AND vw.MemberID=@MemberID) AS ViewCountOther,
	(SELECT COUNT(*)
		FROM CIC_View vw
		WHERE vw.MemberID=@MemberID
			AND (
				(vw.CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE qlp.ViewType=vw.ViewType AND qlp.PB_ID=pb.PB_ID))
				OR (
					vw.CanSeeNonPublicPub IS NOT NULL
					AND (
						(vw.CanSeeNonPublicPub=1 OR pb.NonPublic=0)
						AND (
							pb.MemberID=vw.MemberID
							OR (pb.MemberID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=vw.MemberID AND PB_ID=pb.PB_ID))
						)
					)
				)
			)
		) AS QuickListCountLocal,
	(SELECT COUNT(*)
		FROM CIC_View vw
		WHERE vw.MemberID<>@MemberID
			AND (
				(vw.CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE qlp.ViewType=vw.ViewType AND qlp.PB_ID=pb.PB_ID))
				OR (
					vw.CanSeeNonPublicPub IS NOT NULL
					AND (
						(vw.CanSeeNonPublicPub=1 OR pb.NonPublic=0)
						AND (
							pb.MemberID=vw.MemberID
							OR (pb.MemberID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=vw.MemberID AND PB_ID=pb.PB_ID))
						)
					)
				)
			)
		) AS QuickListCountOther,
	(SELECT n.Name, l.Culture
		FROM CIC_Publication_Name n
		INNER JOIN STP_Language l
			ON n.LangID=l.LangID
		WHERE n.PB_ID=pb.PB_ID
		FOR XML PATH('DESC'),ROOT('DESCS'),TYPE) AS Descriptions
	FROM CIC_Publication pb
WHERE MemberID=@MemberID OR MemberID IS NULL
ORDER BY pb.PubCode

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Admin_Print] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Admin_Print] TO [cioc_login_role]
GO
