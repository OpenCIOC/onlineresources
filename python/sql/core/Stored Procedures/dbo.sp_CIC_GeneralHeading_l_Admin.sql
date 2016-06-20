
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_l_Admin]
	@MemberID int,
	@PB_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 12-May-2016
	Action: Need to update counts
*/

SELECT gh.*,
	ghgn.Name AS HeadingGroupName,
	(SELECT COUNT(*) 
			FROM CIC_BT_PB_GH pbgh 
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=pbgh.NUM_Cache
					AND bt.MemberID=@MemberID
		WHERE pbgh.GH_ID=gh.GH_ID) AS UsageCountLocal,
	(SELECT COUNT(*) 
			FROM CIC_BT_PB_GH pbgh 
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=pbgh.NUM_Cache
					AND bt.MemberID<>@MemberID
		WHERE pbgh.GH_ID=gh.GH_ID) AS UsageCountOther,
	(SELECT COUNT(*)
		FROM CIC_View vw
		WHERE vw.MemberID=@MemberID
			AND (
				(
				vw.PB_ID=pb.PB_ID
				AND vw.LimitedView=1
				) OR
				vw.QuickListPubHeadings=pb.PB_ID
			)
			AND (vw.CanSeeNonPublicPub=1 OR gh.NonPublic=0)
		) AS QuickListCountLocal,
	(SELECT COUNT(*)
		FROM CIC_View vw
		WHERE vw.MemberID<>@MemberID
			AND (
				(
				vw.PB_ID=pb.PB_ID
				AND vw.LimitedView=1
				) OR
				vw.QuickListPubHeadings=pb.PB_ID
			)
			AND (vw.CanSeeNonPublicPub=1 OR gh.NonPublic=0)
		) AS QuickListCountOther,
	CASE WHEN TaxonomyName=1
		THEN (SELECT dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID,l.LangID) AS Name, l.Culture 
				FROM STP_Language l
					WHERE Active=1
			FOR XML PATH('DESC'),ROOT('DESCS'),TYPE)
		ELSE (SELECT ghn.Name, l.Culture 
				FROM CIC_GeneralHeading_Name ghn
				INNER JOIN STP_Language l
					ON l.LangID=ghn.LangID
			WHERE ghn.GH_ID=gh.GH_ID
			FOR XML PATH('DESC'),ROOT('DESCS'),TYPE)
		END AS Descriptions,
	(SELECT ISNULL(CASE WHEN gh2.TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh2.GH_ID, @@LANGID) ELSE ghn.Name END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS Name
			FROM CIC_GeneralHeading gh2
			INNER JOIN CIC_GeneralHeading_Related ghr
				ON gh2.GH_ID=ghr.RelatedGH_ID AND ghr.GH_ID=gh.GH_ID
			LEFT JOIN CIC_GeneralHeading_Name ghn
				ON gh2.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		FOR XML PATH('HEADING'),ROOT('HEADINGS'),TYPE) AS RelatedHeadings
	FROM CIC_GeneralHeading gh
	INNER JOIN CIC_Publication pb
		ON gh.PB_ID=pb.PB_ID
	LEFT JOIN CIC_GeneralHeading_Group_Name ghgn
		ON gh.HeadingGroup=ghgn.GroupID AND ghgn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=gh.HeadingGroup ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE pb.PB_ID=@PB_ID
	AND (pb.MemberID IS NULL OR @MemberID IS NULL OR pb.MemberID=@MemberID)
ORDER BY gh.DisplayOrder

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_l_Admin] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_l_Admin] TO [cioc_login_role]
GO
