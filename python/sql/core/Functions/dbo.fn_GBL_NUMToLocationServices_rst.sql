
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_NUMToLocationServices_rst](
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
	[ORG_NAME] nvarchar(1000)
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 15-Jul-2015
	Action: NO ACTION REQUIRED
*/

INSERT INTO @OrgList
SELECT	sbtd.NUM, sbtd.LangID,
		dbo.fn_CIC_RecordInView(sbtd.NUM, @ViewType, @@LANGID, 0, GETDATE()),
		CASE WHEN sbtd.DELETION_DATE < GETDATE() THEN 1 ELSE 0 END,
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
		) AS ORG_NAME
		FROM GBL_BT_LOCATION_SERVICE ls
	INNER JOIN GBL_BaseTable lbt
		ON ls.SERVICE_NUM=lbt.NUM
	INNER JOIN GBL_BaseTable_Description sbtd
		ON lbt.NUM=sbtd.NUM
			AND sbtd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=sbtd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_BaseTable_Description btd
		ON btd.NUM=ISNULL(@ORG_NUM,@NUM)
			AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ls.LOCATION_NUM=@NUM
	AND (
		@ViewType IS NULL
		OR @ShowNotInView=1
		OR dbo.fn_CIC_RecordInView(sbtd.NUM, @ViewType, @@LANGID, 1, GETDATE())=1
	)

RETURN

END



GO


GRANT SELECT ON  [dbo].[fn_GBL_NUMToLocationServices_rst] TO [cioc_cic_search_role]
GO
