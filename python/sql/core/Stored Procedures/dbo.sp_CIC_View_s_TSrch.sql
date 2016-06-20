SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_s_TSrch]
	@ViewType [int],
	@TopicSearchTag [varchar](20),
	@PreviousStep tinyint,
	@GHIDList1 varchar(max) OUTPUT,
	@GHGroupList1 varchar(max) OUTPUT,
	@GHIDList2 varchar(max) OUTPUT,
	@GHGroupList2 varchar(max) OUTPUT,
	@CMIDList varchar(max) OUTPUT,
	@CMType varchar(1),
	@AgeGroupID int OUTPUT,
	@LN_ID int OUTPUT
WITH EXECUTE AS CALLER
AS

SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: CL
	Checked on: 20-Apr-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@PB_ID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @TopicSearchID int,
		@CurrentStep tinyint,
		@NextStep tinyint,
		@PB_ID1 int,
		@PB_ID2 int,
		@AgeGroupName nvarchar(200),
		@LanguageName nvarchar(200),
		@DoCount bit

SET @PreviousStep = CASE WHEN @PreviousStep IS NULL OR @PreviousStep < 0 THEN 0 ELSE @PreviousStep END

DECLARE @StepsTable TABLE (
	SearchType varchar(2) NOT NULL PRIMARY KEY,
	Title nvarchar(1000) NULL,
	Help nvarchar(4000) NULL,
	ListType tinyint NOT NULL,
	IsRequired bit NOT NULL,
	Criteria bit NOT NULL DEFAULT(0),
	Step tinyint NOT NULL,
	Missing bit NOT NULL DEFAULT(0),
	DisplayOrder tinyint NOT NULL
)

DECLARE @GHID1Table TABLE (
	GH_ID int NOT NULL PRIMARY KEY,
	Name nvarchar(200)
)

DECLARE @GHID2Table TABLE (
	GH_ID int NOT NULL PRIMARY KEY,
	Name nvarchar(200)
)

DECLARE @CMIDTable TABLE (
	CM_ID int NOT NULL PRIMARY KEY,
	Name nvarchar(200)
)

DECLARE @CMSearchTable TABLE (
	CM_ID int NOT NULL PRIMARY KEY
)

SELECT @TopicSearchID = TopicSearchID, @PB_ID1=PB_ID1, @PB_ID2=PB_ID2
	FROM CIC_View_TopicSearch vts
WHERE vts.ViewType=@ViewType AND vts.TopicSearchTag=@TopicSearchTag

IF @GHIDList1 IS NOT NULL OR @GHGroupList1 IS NOT NULL BEGIN
	INSERT INTO @GHID1Table
	SELECT DISTINCT gh.GH_ID, CASE WHEN gh.TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END
		FROM CIC_GeneralHeading gh
		LEFT JOIN CIC_GeneralHeading_Name ghn
			ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE gh.PB_ID=@PB_ID1
		AND (
			EXISTS(SELECT * FROM dbo.fn_GBL_ParseIntIDList(@GHIDList1,',') WHERE ItemID=gh.GH_ID)
			OR EXISTS(SELECT * FROM CIC_GeneralHeading_Group ghg INNER JOIN dbo.fn_GBL_ParseIntIDList(@GHGroupList1,',') ghl ON ghg.GroupID=ghl.ItemID WHERE ghg.PB_ID=@PB_ID1 AND gh.HeadingGroup=ghg.GroupID)
		)
		
	SET @GHIDList1 = NULL
	SET @GHGroupList1 = NULL
	IF EXISTS(SELECT * FROM @GHID1Table) BEGIN
		SELECT @GHIDList1 = COALESCE(@GHIDList1 + ',','') + CAST(gh.GH_ID AS varchar)
			FROM @GHID1Table gh
	END
END

IF @GHIDList2 IS NOT NULL BEGIN
	INSERT INTO @GHID2Table
	SELECT DISTINCT gh.GH_ID, CASE WHEN gh.TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END
		FROM CIC_GeneralHeading gh
		LEFT JOIN CIC_GeneralHeading_Name ghn
			ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE gh.PB_ID=@PB_ID2
		AND (
			EXISTS(SELECT * FROM dbo.fn_GBL_ParseIntIDList(@GHIDList2,',') WHERE ItemID=gh.GH_ID)
			OR EXISTS(SELECT * FROM CIC_GeneralHeading_Group ghg INNER JOIN dbo.fn_GBL_ParseIntIDList(@GHGroupList2,',') ghl ON ghg.GroupID=ghl.ItemID WHERE ghg.PB_ID=@PB_ID2 AND gh.HeadingGroup=ghg.GroupID)
		)

	SET @GHIDList2 = NULL
	SET @GHGroupList2 = NULL
	IF EXISTS(SELECT * FROM @GHID2Table) BEGIN
		SELECT @GHIDList2 = COALESCE(@GHIDList2 + ',','') + CAST(gh.GH_ID AS varchar)
			FROM @GHID2Table gh
	END
END

IF @CMIDList IS NOT NULL BEGIN
	INSERT INTO @CMIDTable
	SELECT DISTINCT cm.CM_ID, Name
		FROM dbo.fn_GBL_ParseIntIDList(@CMIDList,',') tm
		INNER JOIN GBL_Community cm
			ON tm.ItemID=cm.CM_ID
		LEFT JOIN GBL_Community_Name cmn
			ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

	SET @CMIDList = NULL

	IF EXISTS(SELECT * FROM @CMIDTable) BEGIN
		SELECT @CMIDList = COALESCE(@CMIDList + ',','') + CAST(cm.CM_ID AS varchar)
			FROM @CMIDTable cm

		INSERT INTO @CMSearchTable
		-- Given Communities (in the given group(s))
		SELECT CM_ID
			FROM @CMIDTable
		-- Children of Given Communities
		UNION SELECT cmpl.CM_ID
			FROM GBL_Community_ParentList cmpl
			INNER JOIN @CMIDTable tm
				ON cmpl.Parent_CM_ID=tm.CM_ID
		-- Parents of Given Communities
		UNION SELECT Parent_CM_ID
			FROM GBL_Community_ParentList cmpl
			INNER JOIN @CMIDTable tm
				ON cmpl.CM_ID=tm.CM_ID
	END
END

IF @AgeGroupID IS NOT NULL BEGIN
	SELECT @AgeGroupName = Name
		FROM GBL_AgeGroup ag
		INNER JOIN GBL_AgeGroup_Name agn
			ON ag.AgeGroup_ID=agn.AgeGroup_ID AND agn.LangID=(SELECT TOP 1 LangID FROM GBL_AgeGroup_Name WHERE AgeGroup_ID=ag.AgeGroup_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE ag.AgeGroup_ID = @AgeGroupID
	IF @AgeGroupName IS NULL BEGIN
		SET @AgeGroupID = NULL
	END
END

IF @LN_ID IS NOT NULL BEGIN
	SELECT @LanguageName = lnn.Name
		FROM GBL_Language ln
		INNER JOIN GBL_Language_Name lnn
			ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=ln.LN_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE ln.LN_ID = @LN_ID
	IF @LanguageName IS NULL BEGIN
		SET @LN_ID = NULL
	END
END

INSERT INTO @StepsTable (SearchType, Title, Help, ListType, IsRequired, Step, Criteria, DisplayOrder)
SELECT 
		x.SearchType,
		x.Title,
		x.Help,
		x.ListType,
		x.IsRequired,
		x.Step,
		x.Criteria,
		x.DisplayOrder
	FROM CIC_View_TopicSearch vts
	LEFT JOIN CIC_View_TopicSearch_Description vtsd
		ON vts.TopicSearchID=vtsd.TopicSearchID AND vtsd.LangID=@@LANGID
CROSS APPLY 
(
    VALUES
		('G1', ISNULL(Heading1Title,cioc_shared.dbo.fn_SHR_STP_ObjectName('Category')), Heading1Help,
			vts.Heading1Step, vts.Heading1ListType, CAST(1 AS bit), CASE WHEN @GHIDList1 IS NULL THEN 0 ELSE 1 END, 1),
		('G2', ISNULL(Heading2Title,cioc_shared.dbo.fn_SHR_STP_ObjectName('Category')), Heading2Help,
			vts.Heading2Step, vts.Heading2ListType, vts.Heading2Required, CASE WHEN @GHIDList2 IS NULL THEN 0 ELSE 1 END, 2),
        ('C', cioc_shared.dbo.fn_SHR_STP_ObjectName('Community'), CommunityHelp,
			vts.CommunityStep, vts.CommunityListType, vts.CommunityRequired, CASE WHEN @CMIDList IS NULL THEN 0 ELSE 1 END, 3),
        ('A', cioc_shared.dbo.fn_SHR_STP_ObjectName('Age Group'), AgeGroupHelp,
			vts.AgeGroupStep, CAST(1 AS bit), vts.AgeGroupRequired, CASE WHEN @AgeGroupID IS NULL THEN 0 ELSE 1 END, 4),
        ('L', cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'), LanguageHelp,
			vts.LanguageStep, CAST(1 AS bit), vts.LanguageRequired, CASE WHEN @LN_ID IS NULL THEN 0 ELSE 1 END, 5)
) x (SearchType, Title, Help, Step, ListType, IsRequired, Criteria, DisplayOrder)
WHERE x.Step IS NOT NULL
	AND vts.TopicSearchID=@TopicSearchID

UPDATE @StepsTable
	SET Step = 0
WHERE Criteria=1

SELECT @CurrentStep = MIN(Step)
	FROM @StepsTable
WHERE Step > @PreviousStep

IF @CurrentStep IS NULL BEGIN
	SELECT @CurrentStep = MAX(Step)
		FROM @StepsTable
END

IF @CurrentStep IS NULL OR @CurrentStep=0 BEGIN
	SET @CurrentStep = 1
END

UPDATE @StepsTable
	SET Step = @CurrentStep,
		Missing = 1
WHERE IsRequired = 1 AND Step < @CurrentStep AND Criteria=0

SELECT @NextStep = MIN(Step)
	FROM @StepsTable
WHERE Step > @CurrentStep

SET @DoCount = CAST(CASE WHEN (SELECT COUNT(*) FROM @StepsTable WHERE Step=@CurrentStep AND Criteria=0)=1 THEN 1 ELSE 0 END AS bit)

SELECT vts.TopicSearchID, vtsd.SearchTitle, vtsd.SearchDescription, @CurrentStep AS Step, @NextStep AS NextStep,
		@DoCount AS DoCount
	FROM CIC_View_TopicSearch vts
	LEFT JOIN CIC_View_TopicSearch_Description vtsd
		ON vts.TopicSearchID=vtsd.TopicSearchID AND vtsd.LangID=@@LANGID
WHERE vts.TopicSearchID=@TopicSearchID

SELECT step.SearchType, step.Title
	FROM @StepsTable step
WHERE Criteria=1
ORDER BY Step, DisplayOrder

SELECT step.SearchType, step.Title, step.Help, step.IsRequired, step.ListType, step.Missing
	FROM @StepsTable step
WHERE step.Step=@CurrentStep
ORDER BY Step, DisplayOrder

IF EXISTS(SELECT * FROM @StepsTable WHERE SearchType='G1' AND Criteria=1) BEGIN
	SELECT GH_ID, Name, NULL AS Usage
	FROM @GHID1Table
END ELSE BEGIN
	SELECT gh.GH_ID, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END,
			CASE WHEN @DoCount=1 THEN COUNT(bt.NUM) ELSE NULL END AS Usage, ghgn.GroupID, ghgn.Name AS [Group]
		FROM CIC_GeneralHeading gh
		LEFT JOIN CIC_GeneralHeading_Name ghn
			ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
		LEFT JOIN CIC_GeneralHeading_Group_Name ghgn
			ON gh.HeadingGroup=ghgn.GroupID AND ghgn.LangID=@@LANGID
		INNER JOIN CIC_BT_PB_GH pr
			ON gh.GH_ID=pr.GH_ID
		INNER JOIN GBL_BaseTable bt
			ON pr.NUM_Cache=bt.NUM
				AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
		INNER JOIN GBL_BaseTable_Description btd
			ON bt.NUM=btd.NUM
				AND btd.LangID=@@LANGID
				AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
				AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
				AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	WHERE gh.PB_ID=@PB_ID1
		AND (ghn.Name IS NOT NULL OR gh.TaxonomyName=1)
		AND EXISTS(SELECT * FROM @StepsTable WHERE SearchType='G1' AND Step=@CurrentStep)
		AND (
			@GHIDList2 IS NULL OR
				EXISTS(SELECT *
					FROM CIC_BT_PB_GH pr
					INNER JOIN @GHID2Table gh2
						ON pr.GH_ID=gh2.GH_ID
					WHERE pr.NUM_Cache=bt.NUM
					)
			)
		AND (
			@CMIDList IS NULL OR
				(
					(@CMType='L' AND (bt.LOCATED_IN_CM IS NULL OR EXISTS(SELECT * FROM @CMSearchTable WHERE CM_ID=bt.LOCATED_IN_CM)))
					OR (
						(@CMType IS NULL OR @CMType<>'L')
						AND EXISTS(SELECT * FROM CIC_BT_CM pr INNER JOIN @CMSearchTable cms ON pr.CM_ID=cms.CM_ID WHERE pr.NUM=bt.NUM)
					)
				)
			)
		AND (
			@AgeGroupID IS NULL
				OR NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.NUM=bt.NUM)
				OR (
					EXISTS(SELECT *
						FROM CIC_BaseTable cbt
						INNER JOIN GBL_AgeGroup ag
							ON ag.AgeGroup_ID=@AgeGroupID
								AND (
									(cbt.MIN_AGE IS NULL OR ag.MaxAge >= cbt.MIN_AGE OR ag.MaxAge IS NULL)
									 AND (
										cbt.MAX_AGE IS NULL OR ag.MinAge IS NULL
										OR ((FLOOR(cbt.MAX_AGE)=cbt.MAX_AGE AND ag.MinAge < FLOOR(cbt.MAX_AGE)+1)
										OR (ag.MinAge <= cbt.MAX_AGE))
									)
								)
						WHERE cbt.NUM=bt.NUM
					)
				)
		)
		AND (
			@LN_ID IS NULL OR
				EXISTS(SELECT *
					FROM CIC_BT_LN pr
					WHERE pr.NUM=bt.NUM AND pr.LN_ID=@LN_ID
					)
			)
	GROUP BY gh.GH_ID, gh.TaxonomyName, gh.DisplayOrder, ghn.Name, ghgn.GroupID, ghgn.Name
	ORDER BY ghgn.Name, gh.DisplayOrder, ghn.Name
END

IF EXISTS(SELECT * FROM @StepsTable WHERE SearchType='G2' AND Criteria=1) BEGIN
	SELECT GH_ID, Name
	FROM @GHID2Table
END ELSE BEGIN
	SET @GHIDList2 = NULL
	SELECT gh.GH_ID, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END,
			CASE WHEN @DoCount=1 THEN COUNT(bt.NUM) ELSE NULL END AS Usage, NULL AS GroupID, NULL AS [Group]
		FROM CIC_GeneralHeading gh
		LEFT JOIN CIC_GeneralHeading_Name ghn
			ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
		INNER JOIN CIC_BT_PB_GH pr
			ON gh.GH_ID=pr.GH_ID
		INNER JOIN GBL_BaseTable bt
			ON pr.NUM_Cache=bt.NUM
				AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
		INNER JOIN GBL_BaseTable_Description btd
			ON bt.NUM=btd.NUM
				AND btd.LangID=@@LANGID
				AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
				AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
				AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	WHERE gh.PB_ID=@PB_ID2
		AND (ghn.Name IS NOT NULL OR gh.TaxonomyName=1)
		AND EXISTS(SELECT * FROM @StepsTable WHERE SearchType='G2' AND Step=@CurrentStep)
		AND (
			@GHIDList1 IS NULL OR
				EXISTS(SELECT *
					FROM CIC_BT_PB_GH pr
					INNER JOIN @GHID1Table gh1
						ON pr.GH_ID=gh1.GH_ID
					WHERE pr.NUM_Cache=bt.NUM
					)
			)
		AND (
			@CMIDList IS NULL OR
				(
					(@CMType='L' AND (bt.LOCATED_IN_CM IS NULL OR EXISTS(SELECT * FROM @CMSearchTable WHERE CM_ID=bt.LOCATED_IN_CM)))
					OR (
						(@CMType IS NULL OR @CMType<>'L')
						AND EXISTS(SELECT * FROM CIC_BT_CM pr INNER JOIN @CMSearchTable cms ON pr.CM_ID=cms.CM_ID WHERE pr.NUM=bt.NUM)
					)
				)
			)
		AND (
			@AgeGroupID IS NULL
				OR NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.NUM=bt.NUM)
				OR (
					EXISTS(SELECT *
						FROM CIC_BaseTable cbt
						INNER JOIN GBL_AgeGroup ag
							ON ag.AgeGroup_ID=@AgeGroupID
								AND (
									(cbt.MIN_AGE IS NULL OR ag.MaxAge >= cbt.MIN_AGE OR ag.MaxAge IS NULL)
									 AND (
										cbt.MAX_AGE IS NULL OR ag.MinAge IS NULL
										OR ((FLOOR(cbt.MAX_AGE)=cbt.MAX_AGE AND ag.MinAge < FLOOR(cbt.MAX_AGE)+1)
										OR (ag.MinAge <= cbt.MAX_AGE))
									)
								)
						WHERE cbt.NUM=bt.NUM
					)
				)
		)
		AND (
			@LN_ID IS NULL OR
				EXISTS(SELECT *
					FROM CIC_BT_LN pr
					WHERE pr.NUM=bt.NUM AND pr.LN_ID=@LN_ID
					)
			)
	GROUP BY gh.GH_ID, gh.TaxonomyName, ghn.Name
END

IF EXISTS(SELECT * FROM @StepsTable WHERE SearchType='C' AND Criteria=1) BEGIN
	SELECT CM_ID, Name
	FROM @CMIDTable
END ELSE BEGIN
	SET @CMIDList = NULL
	SELECT cm.CM_ID, ISNULL(cmn.Display,cmn.Name) AS Name
		FROM GBL_Community cm
		INNER JOIN GBL_Community_Name cmn
			ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		INNER JOIN CIC_View_Community vwcm
			ON cm.CM_ID=vwcm.CM_ID AND vwcm.ViewType=@ViewType
	WHERE EXISTS(SELECT * FROM @StepsTable WHERE SearchType='C' AND Step=@CurrentStep)
	ORDER BY vwcm.DisplayOrder, cmn.Name
END

IF @AgeGroupName IS NOT NULL BEGIN
	SELECT @AgeGroupID AS AgeGroup_ID, @AgeGroupName AS Name
END ELSE BEGIN
	SET @AgeGroupID = NULL
	SELECT ag.AgeGroup_ID, Name
		FROM GBL_AgeGroup ag
		INNER JOIN GBL_AgeGroup_Name agn
			ON ag.AgeGroup_ID=agn.AgeGroup_ID AND agn.LangID=@@LANGID
	WHERE EXISTS(SELECT * FROM @StepsTable WHERE SearchType='A' AND Step=@CurrentStep)
		AND EXISTS(SELECT *
			FROM GBL_BaseTable bt
			INNER JOIN GBL_BaseTable_Description btd
				ON bt.NUM=btd.NUM
					AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
					AND btd.LangID=@@LANGID
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
			LEFT JOIN CIC_BaseTable cbt
				ON bt.NUM=cbt.NUM
			WHERE (
					(cbt.MIN_AGE IS NULL OR ag.MaxAge >= cbt.MIN_AGE OR ag.MaxAge IS NULL)
					 AND (
						cbt.MAX_AGE IS NULL OR ag.MinAge IS NULL
						OR ((FLOOR(cbt.MAX_AGE)=cbt.MAX_AGE AND ag.MinAge < FLOOR(cbt.MAX_AGE)+1)
						OR (ag.MinAge <= cbt.MAX_AGE))
					)
				)
				AND (
					@GHIDList1 IS NULL OR
						EXISTS(SELECT *
							FROM CIC_BT_PB_GH pr
							INNER JOIN @GHID1Table gh1
								ON pr.GH_ID=gh1.GH_ID
							WHERE pr.NUM_Cache=bt.NUM
							)
					)
				AND (
					@GHIDList2 IS NULL OR
						EXISTS(SELECT *
							FROM CIC_BT_PB_GH pr
							INNER JOIN @GHID2Table gh2
								ON pr.GH_ID=gh2.GH_ID
							WHERE pr.NUM_Cache=bt.NUM
							)
					)
		)

	ORDER BY ag.MinAge, ag.MaxAge
END

IF @LanguageName IS NOT NULL BEGIN
	SELECT @LN_ID AS LN_ID, @LanguageName AS Name
END ELSE BEGIN
	SET @LN_ID = NULL
	SELECT ln.LN_ID, lnn.Name
		FROM GBL_Language ln
		INNER JOIN GBL_Language_Name lnn
			ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=@@LANGID
	WHERE EXISTS(SELECT * FROM @StepsTable WHERE SearchType='L' AND Step=@CurrentStep)
		AND EXISTS(SELECT *
			FROM CIC_BT_LN pr
			INNER JOIN GBL_BaseTable bt
				ON pr.NUM=bt.NUM
					AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
			INNER JOIN GBL_BaseTable_Description btd
				ON bt.NUM=btd.NUM
					AND btd.LangID=@@LANGID
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
			WHERE ln.LN_ID=pr.LN_ID
				AND (
					@GHIDList1 IS NULL OR
						EXISTS(SELECT *
							FROM CIC_BT_PB_GH pr
							INNER JOIN @GHID1Table gh1
								ON pr.GH_ID=gh1.GH_ID
							WHERE pr.NUM_Cache=bt.NUM
							)
					)
				AND (
					@GHIDList2 IS NULL OR
						EXISTS(SELECT *
							FROM CIC_BT_PB_GH pr
							INNER JOIN @GHID2Table gh2
								ON pr.GH_ID=gh2.GH_ID
							WHERE pr.NUM_Cache=bt.NUM
							)
					)
		)
	ORDER BY ln.DisplayOrder, lnn.Name
END

SET NOCOUNT OFF








GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_TSrch] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_TSrch] TO [cioc_login_role]
GO
