SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_l_Count]
	@ViewType [int],
	@PB_ID [int],
	@Used [bit],
	@NonPublic [bit],
	@IncludePubName [bit],
	@SortByGroup [bit] = 0,
	@PubCode varchar(20) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 26-May-2016
	Action: Need to be able to produce a list with just Taxonomy-based Terms
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@View_PB_ID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@View_PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

IF @PB_ID IS NULL BEGIN
	SELECT @PB_ID=PB_ID FROM dbo.CIC_Publication WHERE PubCode=@PubCode
END

IF @IncludePubName=1 BEGIN
	SELECT PubCode + CASE WHEN Name IS NULL THEN '' ELSE ' - ' + Name END AS PubName
		FROM CIC_Publication pb
		LEFT JOIN CIC_Publication_Name pbn
			ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
	WHERE (pb.MemberID=@MemberID OR pb.MemberID IS NULL)
		AND pb.PB_ID=@PB_ID
END

SELECT gh.GH_ID, ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS GeneralHeading,
		ghgn.GroupID, ghgn.Name AS [Group],
		gh.IconNameFull, ghgn.IconNameFull AS IconNameFullGroup,
		(SELECT COUNT(*)
			FROM GBL_BaseTable bt
			INNER JOIN GBL_BaseTable_Description btd
				ON bt.NUM=btd.NUM
					AND btd.LangID=@@LANGID
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
		WHERE EXISTS(SELECT * FROM CIC_BT_PB_GH WHERE NUM_Cache=bt.NUM AND GH_ID=gh.GH_ID)
				AND (@View_PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@View_PB_ID))
				AND (bt.MemberID=@MemberID
						OR EXISTS(SELECT *
							FROM GBL_BT_SharingProfile pr
							INNER JOIN GBL_SharingProfile shp
								ON pr.ProfileID=shp.ProfileID
									AND shp.Active=1
									AND (
										shp.CanUseAnyView=1
										OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
									)
							WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
				)
			) AS RecordsInView
	FROM CIC_Publication pb
	INNER JOIN CIC_GeneralHeading gh
		ON pb.PB_ID=gh.PB_ID
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN (SELECT ghg.GroupID, DisplayOrder, Name, ghg.IconNameFull
				FROM CIC_GeneralHeading_Group ghg
				INNER JOIN CIC_GeneralHeading_Group_Name ghgn
					ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=@@LANGID
				WHERE ghg.PB_ID=@PB_ID) ghgn 
		ON gh.HeadingGroup=ghgn.GroupID
WHERE (pb.MemberID=@MemberID OR pb.MemberID IS NULL)
	AND pb.PB_ID=@PB_ID
	AND (@Used=0 OR Used=1 OR (@Used IS NULL AND (Used=1 OR Used IS NULL)))
	AND (@NonPublic=1 OR gh.NonPublic=0)
ORDER BY CASE WHEN @SortByGroup=1 THEN ISNULL(ghgn.DisplayOrder,0) ELSE NULL END, CASE WHEN @SortByGroup=1 THEN ISNULL(ghgn.Name, ghn.Name) ELSE NULL END, gh.DisplayOrder, ghn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_l_Count] TO [cioc_cic_search_role]
GO
