SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_l_Report] (
	@ViewType [int],
	@CMIDList varchar(MAX),
	@GHIDList varchar(MAX),
	@PBIDList varchar(MAX)
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE	@MemberID int,
		@CanSeeNonPublicPub bit,
		@QuickListPubHeadings int,
		@CanSeeNonPublic bit,
		@ViewPBID int

SELECT	@MemberID = vw.MemberID,
		@CanSeeNonPublicPub = vw.CanSeeNonPublicPub,
		@QuickListPubHeadings = vw.QuickListPubHeadings,
		@CanSeeNonPublic = vw.CanSeeNonPublic,
		@ViewPBID = vw.PB_ID
FROM dbo.CIC_View vw
WHERE ViewType=@ViewType

SELECT cm.CM_ID, ISNULL(cmn.Display,cmn.Name) AS Community
	FROM dbo.GBL_Community cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@CMIDList,',') pr
		ON cm.CM_ID=pr.ItemID
ORDER BY Community

SELECT pb.PB_ID, ISNULL(pbn.Name, pb.PubCode) AS Name
	FROM dbo.CIC_Publication pb
	LEFT JOIN dbo.CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@PBIDList,',') pr
		ON pb.PB_ID=pr.ItemID
WHERE (
		@CanSeeNonPublicPub=1
		OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=0)
		OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM dbo.CIC_View_QuickListPub qlp WHERE ViewType=@ViewType AND qlp.PB_ID=pb.PB_ID))
		)
	AND (pb.MemberID IS NULL OR pb.MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM dbo.CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
	AND @QuickListPubHeadings IS NULL
GROUP BY pb.PB_ID, ISNULL(pbn.Name, pb.PubCode)
ORDER BY ISNULL(pbn.Name, pb.PubCode)

SELECT gh.GH_ID,
	ISNULL(CASE WHEN gh.TaxonomyName=1
		THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID)
		ELSE CASE WHEN ghn.LangID=@@LANGID
			THEN ghn.Name
			ELSE '[' + ghn.Name + ']'
			END
		END,
		'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS GeneralHeading
FROM dbo.CIC_Publication pb
INNER JOIN dbo.CIC_GeneralHeading gh
	ON pb.PB_ID=gh.PB_ID
LEFT JOIN dbo.CIC_GeneralHeading_Name ghn
	ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM dbo.CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
INNER JOIN dbo.fn_GBL_ParseIntIDList(@GHIDList,',') pr
	ON gh.GH_ID=pr.ItemID
WHERE (pb.MemberID=@MemberID OR pb.MemberID IS NULL)
	AND pb.PB_ID=@QuickListPubHeadings
	AND (@CanSeeNonPublicPub=1 OR gh.NonPublic=0)
ORDER BY GeneralHeading


SET NOCOUNT OFF;

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_l_Report] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_l_Report] TO [cioc_login_role]
GO
