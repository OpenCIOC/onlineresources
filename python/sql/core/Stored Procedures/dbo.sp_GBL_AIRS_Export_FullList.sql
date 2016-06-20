
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_AIRS_Export_FullList] (
	@ViewType [int],
	@LangID [smallint],
	@DistCode [varchar](20),
	@PubCodeSynch [bit],
	@IncludeDeleted [bit],
	@AutoIncludeSiteAgency [bit]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.3
	Checked by: KL
	Checked on: 04-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeDeleted bit,
		@HidePastDueBy int,
		@PB_ID int
		
SELECT	@MemberID = MemberID,
		@CanSeeNonPublic = CanSeeNonPublic,
		@CanSeeDeleted = CASE WHEN CanSeeDeleted=0 OR @IncludeDeleted=0 THEN 0 ELSE 1 END,
		@HidePastDueBy = HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @DST_ID int
IF @DistCode IS NOT NULL BEGIN
	SELECT @DST_ID=DST_ID FROM CIC_Distribution WHERE DistCode=@DistCode
	SET @DST_ID=ISNULL(@DST_ID,-1)
END

IF @PubCodeSynch=1 BEGIN
	IF LEN(REPLACE((SELECT DistCode FROM CIC_Distribution WHERE DST_ID=@DST_ID),'AIRSEXPORT-','')) > 2 BEGIN
		MERGE INTO CIC_BT_DST dst
		USING (SELECT DISTINCT NUM
			FROM CIC_BT_PB pr
			INNER JOIN CIC_Publication pb
				ON pr.PB_ID=pb.PB_ID
			INNER JOIN CIC_Distribution d
				ON pb.PubCode LIKE REPLACE(d.DistCode,'AIRSEXPORT-','') + '%' AND d.DST_ID=@DST_ID) src
			ON dst.NUM=src.NUM AND dst.DST_ID=@DST_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (NUM, DST_ID) VALUES (src.NUM, @DST_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.DST_ID=@DST_ID THEN
			DELETE
		;
	END
END

DECLARE @ADD_TO_BT_LOCATION_SERVICE table ( NUM varchar(8) PRIMARY KEY )
INSERT INTO @ADD_TO_BT_LOCATION_SERVICE
		(NUM)
SELECT bt.NUM
FROM GBL_BaseTable bt
WHERE ORG_NUM='ZZZ00001'
	AND EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='TOPIC' WHERE pr.NUM=bt.NUM)
	AND NOT EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE WHERE SERVICE_NUM=bt.NUM)

UPDATE dbo.GBL_BaseTable SET DISPLAY_LOCATION_NAME=0 WHERE DISPLAY_LOCATION_NAME=1 AND EXISTS(SELECT * FROM @ADD_TO_BT_LOCATION_SERVICE WHERE NUM=GBL_BaseTable.NUM)

INSERT INTO GBL_BT_LOCATION_SERVICE (LOCATION_NUM, SERVICE_NUM)
SELECT 'ZZZ00002', bt.NUM
FROM @ADD_TO_BT_LOCATION_SERVICE bt


DECLARE @nLine nvarchar(2),
		@nLine10 char(1)

SET @nLine = CHAR(13) + CHAR(10)
SET @nLine10 = CHAR(10)

DECLARE @TmpExportListTable table (
	NUM varchar(8) NOT NULL INDEX IX_TmpELTNUM NONCLUSTERED,
	ORG_NUM varchar(8) NULL INDEX IX_TmpELTType,
	Type varchar(20) NOT NULL
)

INSERT INTO @TmpExportListTable
        ( NUM, Type )
SELECT
	btd.NUM, 'AGENCY' AS Type
FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=@LangID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (
				btd.DELETION_DATE IS NULL
				OR btd.DELETION_DATE > GETDATE()
				OR (
					@CanSeeDeleted=1
					AND @AutoIncludeSiteAgency=1
					AND (
						@DST_ID IS NULL
						OR EXISTS(SELECT * FROM GBL_BaseTable slbt INNER JOIN GBL_BaseTable_Description slbtd ON slbt.NUM=slbtd.NUM AND slbtd.LangID=0 AND slbtd.DELETION_DATE IS NULL WHERE ORG_NUM=bt.NUM
							AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)
						)
					)
				)
			)
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM = cbt.NUM
	LEFT JOIN CIC_BaseTable_Description cbtd
		ON cbt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID
WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
	AND EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='AGENCY' WHERE pr.NUM=bt.NUM)
	AND (
		@DST_ID IS NULL
		OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=bt.NUM)
		OR (@AutoIncludeSiteAgency=1 AND EXISTS(SELECT * FROM GBL_BaseTable slbt WHERE ORG_NUM=bt.NUM AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)))
	)

INSERT INTO @TmpExportListTable (NUM, ORG_NUM, Type)
SELECT CASE WHEN bt.NUM='ZZZ00001' THEN slbtd.NUM ELSE slbt.NUM END AS NUM, bt.NUM AS ORG_NUM, 'SITE' AS Type
FROM GBL_BaseTable slbt
INNER JOIN @TmpExportListTable bt
	ON (slbt.NUM=bt.NUM OR slbt.ORG_NUM=bt.NUM)
LEFT JOIN GBL_BaseTable_Description slbtd
	ON slbtd.LangID=@LangID
		AND slbtd.NUM = CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code='SITE' WHERE lpr.NUM=slbt.NUM) THEN slbt.NUM ELSE 'ZZZ00002' END
		AND (
				(
					(@CanSeeNonPublic=1 OR slbtd.NON_PUBLIC=0)
					AND (slbtd.DELETION_DATE IS NULL OR slbtd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (slbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,slbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
				) OR (
					slbtd.NUM='ZZZ00002'
				)
			)
LEFT JOIN CIC_BaseTable cslbt
	ON slbtd.NUM=cslbt.NUM
LEFT JOIN CIC_BaseTable_Description slcbtd
	ON cslbt.NUM=slcbtd.NUM AND slcbtd.LangID=slbtd.LangID
WHERE slbtd.NUM IS NOT NULL
	AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=slbt.NUM AND PB_ID=@PB_ID))
	AND (slbt.MemberID=@MemberID
			OR EXISTS(SELECT *
				FROM GBL_BT_SharingProfile pr
				INNER JOIN GBL_SharingProfile shp
					ON pr.ProfileID=shp.ProfileID
						AND shp.Active=1
						AND (
							shp.CanUseAnyView=1
							OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
						)
				WHERE NUM=slbt.NUM AND ShareMemberID_Cache=@MemberID)
		)
	AND (
		EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code='SITE' WHERE lpr.NUM=slbt.NUM)
		OR (
			NOT EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code='SITE' WHERE lpr.NUM=slbt.NUM)
			AND NOT EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE WHERE SERVICE_NUM=slbt.NUM)
			AND EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code IN ('SERVICE','TOPIC') WHERE lpr.NUM=slbt.NUM)
		)
	)
	AND (
		@DST_ID IS NULL
		OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)
		OR (@AutoIncludeSiteAgency=1 AND EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE ls WHERE ls.LOCATION_NUM=slbt.NUM AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=ls.SERVICE_NUM)))
	)

INSERT INTO @TmpExportListTable (NUM, ORG_NUM, Type)
SELECT svbtd.NUM, slbt.ORG_NUM, 'PROGRAM'
FROM GBL_BaseTable svbt
INNER JOIN dbo.GBL_BT_LOCATION_SERVICE prls
	ON SERVICE_NUM=svbt.NUM
INNER JOIN @TmpExportListTable slbt
	ON prls.LOCATION_NUM=slbt.NUM AND slbt.Type='SITE'
INNER JOIN GBL_BaseTable_Description svbtd
	ON svbt.NUM=svbtd.NUM AND svbtd.LangID=@LangID
		AND (@CanSeeNonPublic=1 OR svbtd.NON_PUBLIC=0)
		AND (svbtd.DELETION_DATE IS NULL OR svbtd.DELETION_DATE > GETDATE())
		AND (@HidePastDueBy IS NULL OR (svbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,svbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
LEFT JOIN CIC_BaseTable svcbt
	ON svbt.NUM = svcbt.NUM
LEFT JOIN CIC_BaseTable_Description svcbtd
	ON svcbt.NUM=svcbtd.NUM AND svcbtd.LangID=svbtd.LangID
WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=slbt.NUM AND PB_ID=@PB_ID))
	AND (svbt.MemberID=@MemberID
			OR EXISTS(SELECT *
				FROM GBL_BT_SharingProfile pr
				INNER JOIN GBL_SharingProfile shp
					ON pr.ProfileID=shp.ProfileID
						AND shp.Active=1
						AND (
							shp.CanUseAnyView=1
							OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
						)
				WHERE NUM=svbt.NUM AND ShareMemberID_Cache=@MemberID)
		)
	AND EXISTS(SELECT * FROM GBL_BT_OLS spr INNER JOIN GBL_OrgLocationService sols ON spr.OLS_ID=sols.OLS_ID AND sols.Code IN ('SERVICE','TOPIC') WHERE spr.NUM=svbt.NUM)
	AND (
		@DST_ID IS NULL
		OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=svbt.NUM)
	)

INSERT INTO @TmpExportListTable (NUM, ORG_NUM, Type)
SELECT svbtd.NUM, slbt.ORG_NUM, 'PROGRAM'
FROM GBL_BaseTable svbt
INNER JOIN @TmpExportListTable slbt
	ON svbt.NUM=slbt.NUM AND slbt.Type='SITE'
INNER JOIN GBL_BaseTable_Description svbtd
	ON svbt.NUM=svbtd.NUM AND svbtd.LangID=@LangID
		AND (@CanSeeNonPublic=1 OR svbtd.NON_PUBLIC=0)
		AND (svbtd.DELETION_DATE IS NULL OR svbtd.DELETION_DATE > GETDATE())
		AND (@HidePastDueBy IS NULL OR (svbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,svbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
LEFT JOIN CIC_BaseTable svcbt
	ON svbt.NUM = svcbt.NUM
LEFT JOIN CIC_BaseTable_Description svcbtd
	ON svcbt.NUM=svcbtd.NUM AND svcbtd.LangID=svbtd.LangID
WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=slbt.NUM AND PB_ID=@PB_ID))
	AND (svbt.MemberID=@MemberID
			OR EXISTS(SELECT *
				FROM GBL_BT_SharingProfile pr
				INNER JOIN GBL_SharingProfile shp
					ON pr.ProfileID=shp.ProfileID
						AND shp.Active=1
						AND (
							shp.CanUseAnyView=1
							OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
						)
				WHERE NUM=svbt.NUM AND ShareMemberID_Cache=@MemberID)
		)
	AND EXISTS(SELECT * FROM GBL_BT_OLS spr INNER JOIN GBL_OrgLocationService sols ON spr.OLS_ID=sols.OLS_ID AND sols.Code IN ('SERVICE','TOPIC') WHERE spr.NUM=svbt.NUM)
	AND (
		@DST_ID IS NULL
		OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=svbt.NUM)
	)

SELECT * FROM @TmpExportListTable
ORDER BY NUM

RETURN @Error

SET NOCOUNT OFF

--DELETE FROM GBL_BT_LOCATION_SERVICE where LOCATION_NUM='ZZZ00002'


GO



GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_FullList] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_FullList] TO [cioc_login_role]
GO
