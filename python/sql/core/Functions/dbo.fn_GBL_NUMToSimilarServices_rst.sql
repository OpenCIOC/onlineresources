
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToSimilarServices_rst](
	@NUM varchar(8),
	@ORG_NUM varchar(8),
	@ViewType int,
	@ShowNotInView bit
)
RETURNS @OrgList TABLE (
	[NUM] varchar(8) NOT NULL,
	[LangID] smallint NOT NULL,
	[InView] bit,
	[Deleted] bit,
	[NON_PUBLIC] bit,
	[ORG_NAME] nvarchar(1000),
	[SUMMARY] nvarchar(500)
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 14-Oct-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @nLine nvarchar(2)

SET @nLine = CHAR(13) + CHAR(10)

DECLARE @SERVICE_NAME_LEVEL_1 nvarchar(200),
		@SERVICE_NAME_LEVEL_2 nvarchar(200),
		@IsServiceLocation bit

SELECT	@SERVICE_NAME_LEVEL_1=btd.SERVICE_NAME_LEVEL_1,
		@SERVICE_NAME_LEVEL_2=btd.SERVICE_NAME_LEVEL_2,
		@IsServiceLocation = CASE WHEN btd.SERVICE_NAME_LEVEL_2=btd.LOCATION_NAME THEN 1 ELSE 0 END
FROM dbo.GBL_BaseTable_Description btd
WHERE btd.NUM=@NUM
	AND btd.LangID=@@LANGID

INSERT INTO @OrgList
SELECT	sbtd.NUM, sbtd.LangID,
		dbo.fn_CIC_RecordInView(sbtd.NUM, @ViewType, @@LANGID, 0, GETDATE()),
		CASE WHEN sbtd.DELETION_DATE < GETDATE() THEN 1 ELSE 0 END,
		sbtd.NON_PUBLIC,
		ISNULL(STUFF(
				COALESCE(', ' + sbtd.SERVICE_NAME_LEVEL_1,'') +
				COALESCE(', ' + sbtd.SERVICE_NAME_LEVEL_2,''),
				1, 2, ''
			), ISNULL(
				STUFF(
					COALESCE(sbtd.ORG_LEVEL_1,'') +
					COALESCE(', ' + sbtd.ORG_LEVEL_2,'') +
					COALESCE(', ' + sbtd.ORG_LEVEL_3,'') +
					COALESCE(', ' + sbtd.ORG_LEVEL_4,'') +
					COALESCE(', ' + sbtd.ORG_LEVEL_5,''),
					1, 0, ''
				)
				,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
			)
		) AS ORG_NAME,
		CASE
			WHEN sbtd.SERVICE_NAME_LEVEL_2=sbtd.LOCATION_NAME AND @IsServiceLocation=1 THEN COALESCE(sbtd.CMP_LocDescriptionShort, sbtd.CMP_SiteAddress, cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Service Location',sbtd.LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',sbtd.LangID) + sbtd.CMP_LocatedIn)
			WHEN sbtd.SERVICE_NAME_LEVEL_2<>sbtd.LOCATION_NAME OR sbtd.SERVICE_NAME_LEVEL_2 IS NULL THEN sbtd.CMP_DescriptionShort
			WHEN sbtd.CMP_SiteAddress IS NULL THEN btd.CMP_DescriptionShort
			WHEN btd.CMP_DescriptionShort IS NULL THEN COALESCE(sbtd.CMP_SiteAddress, sbtd.CMP_LocDescriptionShort,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Service Location',sbtd.LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',sbtd.LangID) + sbtd.CMP_LocatedIn)
			ELSE sbtd.CMP_SiteAddress + @nLine + @nLine + sbtd.CMP_DescriptionShort
			END AS SUMMARY
	FROM GBL_BaseTable sbt
	INNER JOIN GBL_BaseTable_Description sbtd
		ON sbt.NUM=sbtd.NUM
			AND sbtd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=sbtd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_BaseTable_Description btd
		ON btd.NUM=ISNULL(@ORG_NUM,@NUM)
			AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE
	sbtd.SERVICE_NAME_LEVEL_1=@SERVICE_NAME_LEVEL_1
	AND sbt.ORG_NUM=@ORG_NUM AND sbt.NUM<>@NUM
	AND (
		@ViewType IS NULL
		OR @ShowNotInView=1
		OR dbo.fn_CIC_RecordInView(sbtd.NUM, @ViewType, @@LANGID, 1, GETDATE())=1
	)

RETURN

END




GO



GRANT SELECT ON  [dbo].[fn_GBL_NUMToSimilarServices_rst] TO [cioc_cic_search_role]
GO
