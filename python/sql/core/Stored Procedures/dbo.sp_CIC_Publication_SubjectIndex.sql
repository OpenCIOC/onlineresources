SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_SubjectIndex]
	@Print_PB_ID int,
	@ViewType int,
	@NoDeleted [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 06-Oct-2013
	Action: TESTING REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeDeleted bit,
		@HidePastDueBy int,
		@PB_ID int,
		@LimitedView bit,
		@CanSeeNonPublicPub bit
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@CanSeeDeleted=CASE WHEN @NoDeleted=1 THEN 0 ELSE CanSeeDeleted END,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID,
		@LimitedView=LimitedView,
		@CanSeeNonPublicPub=CanSeeNonPublicPub
FROM CIC_View
WHERE ViewType=@ViewType

IF @LimitedView=1 AND @PB_ID IS NOT NULL BEGIN
	SET @Print_PB_ID=@PB_ID
END ELSE IF NOT EXISTS(SELECT * FROM CIC_Publication pb
				WHERE PB_ID=@Print_PB_ID
					AND (MemberID=@MemberID OR MemberID IS NULL)
					AND (@CanSeeNonPublicPub IS NOT NULL OR EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=pb.PB_ID))
					AND (@CanSeeNonPublicPub<>0 OR pb.NonPublic=0)
		) BEGIN
	SET @Print_PB_ID = NULL
END

DECLARE @wNumbers	TABLE (
	PNUM int IDENTITY (1, 1),
	NUM	varchar(8) COLLATE Latin1_General_100_CI_AI,
	ORG_LEVEL_1 nvarchar(200),
	ORG_LEVEL_2 nvarchar(200),
	ORG_LEVEL_3 nvarchar(200),
	ORG_LEVEL_4 nvarchar(200),
	ORG_LEVEL_5 nvarchar(200),
	LOCATION_NAME nvarchar(200),
	SERVICE_NAME_LEVEL_1 nvarchar(200),
	SERVICE_NAME_LEVEL_2 nvarchar(200)
)
INSERT INTO @wNumbers (NUM, ORG_LEVEL_1, ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2)

SELECT bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2
	FROM dbo.GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (@CanSeeDeleted=1 OR (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE()))
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx
		ON (((btd.SORT_AS_USELETTER IS NULL OR btd.SORT_AS_USELETTER=0) AND btd.ORG_LEVEL_1 LIKE idx.LetterIndex + '%')
			OR (btd.SORT_AS_USELETTER=1 AND btd.SORT_AS LIKE idx.LetterIndex + '%'))
	INNER JOIN CIC_BT_PB pb
		ON bt.NUM = pb.NUM
			AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
	WHERE pb.PB_ID = @Print_PB_ID
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
ORDER BY idx.LetterIndex, ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		)

SELECT bt.PNUM, gh.GH_ID, 1 AS Used,
	CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS Subject, 
	bt.ORG_LEVEL_1, bt.ORG_LEVEL_2, bt.ORG_LEVEL_3, bt.ORG_LEVEL_4, bt.ORG_LEVEL_5,
	bt.LOCATION_NAME, bt.SERVICE_NAME_LEVEL_1, bt.SERVICE_NAME_LEVEL_2,
	dbo.fn_CIC_GeneralHeading_Related(gh.GH_ID,'<BR>',@CanSeeNonPublicPub,0) AS RELATED,
	gh.DisplayOrder
FROM @wNumbers bt
	INNER JOIN CIC_BT_PB_GH prg
		ON bt.NUM = prg.NUM_Cache
	INNER JOIN CIC_GeneralHeading gh
		ON prg.GH_ID = gh.GH_ID
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
WHERE gh.PB_ID = @Print_PB_ID
	AND (gh.TaxonomyName=1 OR ghn.GH_ID IS NOT NULL)

UNION SELECT 0, gh.GH_ID, 0, 
		CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS Subject,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
		dbo.fn_CIC_GeneralHeading_Related(gh.GH_ID,'<BR>',@CanSeeNonPublicPub,0),
		gh.DisplayOrder
	FROM CIC_GeneralHeading gh
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
WHERE gh.PB_ID = @Print_PB_ID
	AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH WHERE GH_ID=gh.GH_ID)
	AND (gh.TaxonomyName=1 OR ghn.GH_ID IS NOT NULL)
	AND EXISTS(SELECT * FROM CIC_GeneralHeading_Related rt
		INNER JOIN CIC_GeneralHeading gh2
			ON rt.RelatedGH_ID=gh2.GH_ID
		LEFT JOIN CIC_GeneralHeading_Name ghn2
			ON gh2.GH_ID=ghn2.GH_ID AND ghn2.LangID=@@LANGID
		WHERE rt.GH_ID=gh.GH_ID 
			AND (gh2.TaxonomyName=1 OR ghn2.GH_ID IS NOT NULL)
			AND (@CanSeeNonPublicPub=1 OR NonPublic=0))
ORDER BY gh.DisplayOrder, Subject, PNUM

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_SubjectIndex] TO [cioc_login_role]
GO
