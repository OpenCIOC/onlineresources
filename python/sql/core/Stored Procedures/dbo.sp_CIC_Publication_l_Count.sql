SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Publication_l_Count]
	@ViewType int,
	@HasHeadings bit,
	@UsedHeadings bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 26-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@View_PB_ID int,
		@CanSeeNonPublicPub bit,
		@UsePubNamesOnly bit
		
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@View_PB_ID=PB_ID,
		@CanSeeNonPublicPub=CanSeeNonPublicPub,
		@UsePubNamesOnly=UsePubNamesOnly
FROM CIC_View
WHERE ViewType=@ViewType

SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, 
		CASE
			WHEN @UsePubNamesOnly=1 THEN ISNULL(pbn.Name, pb.PubCode)
			ELSE Name
		END AS PubName,
		(SELECT COUNT(*)
			FROM GBL_BaseTable bt
			INNER JOIN GBL_BaseTable_Description btd
				ON bt.NUM=btd.NUM
					AND btd.LangID=@@LANGID
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
		WHERE EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=pb.PB_ID)
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
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE (
		@CanSeeNonPublicPub=1
		OR (@CanSeeNonPublicPub=0 AND NonPublic=0)
		OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=@ViewType AND qlp.PB_ID=pb.PB_ID))
		)
	AND (@HasHeadings = 0 OR EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID AND (@UsedHeadings=0 OR Used=1 OR (@UsedHeadings IS NULL AND (Used=1 OR Used IS NULL)))))
	AND (MemberID IS NULL OR MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
ORDER BY CASE WHEN @UsePubNamesOnly=1 THEN ISNULL(pbn.Name, pb.PubCode) ELSE pb.PubCode END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Count] TO [cioc_cic_search_role]
GO
