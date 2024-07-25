SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_QuickList_l_Report] (
	@ViewType [int],
	@CMIDList varchar(MAX)
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @CMList TABLE (
	CM_ID int PRIMARY KEY NOT NULL
)

INSERT INTO @CMList (CM_ID)
SELECT DISTINCT 
	cm.CM_ID
FROM dbo.GBL_Community cm
INNER JOIN dbo.fn_GBL_ParseIntIDList(@CMIDList,',') pr
	ON cm.CM_ID=pr.ItemID

DELETE cl
	FROM @CMList cl
	INNER JOIN dbo.GBL_Community_ParentList pl
		ON pl.CM_ID=cl.CM_ID
	INNER JOIN @CMList cl2
		ON pl.Parent_CM_ID=cl2.CM_ID

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
	FROM @CMList cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY Community

IF @QuickListPubHeadings IS NULL BEGIN
	SELECT pb.PB_ID, ISNULL(pbn.Name, pb.PubCode) AS Name, COUNT(*) AS RecordCount
		FROM dbo.CIC_Publication pb
		LEFT JOIN dbo.CIC_Publication_Name pbn
			ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
		INNER JOIN dbo.CIC_BT_PB pr
			ON pr.PB_ID=pb.PB_ID
		INNER JOIN dbo.GBL_BaseTable bt
			ON pr.NUM=bt.NUM
				AND (bt.MemberID=@MemberID
					OR EXISTS(SELECT *
						FROM dbo.GBL_BT_SharingProfile pr
						INNER JOIN dbo.GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
								AND (
									shp.CanUseAnyView=1
									OR EXISTS(SELECT * FROM dbo.GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
								)
						WHERE pr.NUM=bt.NUM AND pr.ShareMemberID_Cache=@MemberID)
				)
				AND (@ViewPBID IS NULL OR EXISTS(SELECT * FROM dbo.CIC_BT_PB WHERE PB_ID=@ViewPBID AND NUM=bt.NUM))
				AND (@CMIDList IS NULL OR EXISTS(SELECT *
					FROM dbo.CIC_BT_CM cm
					INNER JOIN dbo.fn_GBL_Community_Search_rst(@CMIDList) cl
						ON cl.CM_ID=cm.CM_ID
					WHERE cm.NUM=bt.NUM))
		INNER JOIN dbo.GBL_BaseTable_Description btd
			ON bt.NUM=btd.NUM AND btd.LangID=@@LangID
				AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
				AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
	WHERE (
			@CanSeeNonPublicPub=1
			OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=0)
			OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM dbo.CIC_View_QuickListPub qlp WHERE ViewType=@ViewType AND qlp.PB_ID=pb.PB_ID))
			)
		AND (pb.MemberID IS NULL OR pb.MemberID=@MemberID)
		AND NOT EXISTS(SELECT * FROM dbo.CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
	GROUP BY pb.PB_ID, ISNULL(pbn.Name, pb.PubCode)
	ORDER BY ISNULL(pbn.Name, pb.PubCode)
END ELSE BEGIN
	SELECT
		gh.GH_ID,
		ISNULL(CASE WHEN gh.TaxonomyName=1
			THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID)
			ELSE CASE WHEN ghn.LangID=@@LANGID
				THEN ghn.Name
				ELSE '[' + ghn.Name + ']'
				END
			END,
			'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS GeneralHeading,
		ghgn.GroupID, ghgn.Name AS [Group],
		COUNT(*) AS RecordCount
	FROM dbo.CIC_Publication pb
	INNER JOIN dbo.CIC_GeneralHeading gh
		ON pb.PB_ID=gh.PB_ID
	LEFT JOIN dbo.CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM dbo.CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN (SELECT ghg.GroupID, ghg.DisplayOrder, ghgn.Name
				FROM dbo.CIC_GeneralHeading_Group ghg
				INNER JOIN dbo.CIC_GeneralHeading_Group_Name ghgn
					ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=@@LANGID
				WHERE ghg.PB_ID=@QuickListPubHeadings) ghgn 
		ON gh.HeadingGroup=ghgn.GroupID
	INNER JOIN dbo.CIC_BT_PB_GH pr
		ON pr.GH_ID=gh.GH_ID
	INNER JOIN dbo.GBL_BaseTable bt
		ON pr.NUM_Cache=bt.NUM
			AND (bt.MemberID=@MemberID
				OR EXISTS(SELECT *
					FROM dbo.GBL_BT_SharingProfile pr
					INNER JOIN dbo.GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
							AND (
								shp.CanUseAnyView=1
								OR EXISTS(SELECT * FROM dbo.GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
							)
					WHERE pr.NUM=bt.NUM AND pr.ShareMemberID_Cache=@MemberID)
			)
			AND (@ViewPBID IS NULL OR EXISTS(SELECT * FROM dbo.CIC_BT_PB WHERE PB_ID=@ViewPBID AND NUM=bt.NUM))
			AND (@CMIDList IS NULL OR EXISTS(SELECT *
				FROM dbo.CIC_BT_CM cm
				INNER JOIN dbo.fn_GBL_Community_Search_rst(@CMIDList) cl
					ON cl.CM_ID=cm.CM_ID
				WHERE cm.NUM=bt.NUM))
	INNER JOIN dbo.GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=@@LangID
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
	WHERE (pb.MemberID=@MemberID OR pb.MemberID IS NULL)
		AND pb.PB_ID=@QuickListPubHeadings
		AND (@CanSeeNonPublicPub=1 OR gh.NonPublic=0)
	GROUP BY gh.GH_ID,
			ISNULL(CASE WHEN gh.TaxonomyName=1
				THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID)
				ELSE CASE WHEN ghn.LangID=@@LANGID
					THEN ghn.Name
					ELSE '[' + ghn.Name + ']'
					END
				END,
				'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']'),
			ghgn.GroupID,
			ghgn.Name,
			ghgn.DisplayOrder,
			gh.DisplayOrder
	ORDER BY ISNULL(ghgn.DisplayOrder,0), ghgn.Name, gh.DisplayOrder, GeneralHeading
END

SET NOCOUNT OFF;

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_QuickList_l_Report] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_QuickList_l_Report] TO [cioc_login_role]
GO
