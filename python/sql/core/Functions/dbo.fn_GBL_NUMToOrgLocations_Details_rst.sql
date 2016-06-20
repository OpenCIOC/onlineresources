
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_NUMToOrgLocations_Details_rst](
	@NUM varchar(8),
	@ViewType int,
	@ShowNotInView bit
)
RETURNS @OrgList table (
	[NUM] varchar(8) NOT NULL PRIMARY KEY,
	[LangID] smallint NOT NULL,
	[InView] bit,
	[Deleted] bit INDEX IX_OLDELETED,
	[NON_PUBLIC] bit,
	[ORG_NAME] nvarchar(1000),
	[SUMMARY] nvarchar(800)
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 23-Jul-2015
	Action: NO ACTION REQUIRED
*/

INSERT INTO @OrgList
SELECT	lbtd.NUM, lbtd.LangID,
		dbo.fn_CIC_RecordInView(lbtd.NUM, @ViewType, @@LANGID, 0, GETDATE()),
		CASE WHEN lbtd.DELETION_DATE < GETDATE() THEN 1 ELSE 0 END,
		lbtd.NON_PUBLIC,
		ISNULL(lbtd.LOCATION_NAME,
			ISNULL(
				STUFF(
					COALESCE(lbtd.ORG_LEVEL_1,'') +
					COALESCE(', ' + lbtd.ORG_LEVEL_2,'') +
					COALESCE(', ' + lbtd.ORG_LEVEL_3,'') +
					COALESCE(', ' + lbtd.ORG_LEVEL_4,'') +
					COALESCE(', ' + lbtd.ORG_LEVEL_5,''),
					1, 0, ''
				)
				,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
			)
		) AS ORG_NAME,
		COALESCE(lbtd.CMP_SiteAddressWeb, lbtd.CMP_LocDescriptionShort, lbtd.CMP_LocatedIn) AS SUMMARY
	FROM GBL_BaseTable lbt
	INNER JOIN GBL_BaseTable_Description lbtd
		ON lbt.NUM=lbtd.NUM AND lbtd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=lbtd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_BaseTable_Description btd
		ON btd.NUM=@NUM
			AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			AND btd.NUM IN (lbt.NUM,lbt.ORG_NUM)
WHERE (EXISTS(SELECT * FROM GBL_BT_OLS opr INNER JOIN GBL_OrgLocationService ols ON opr.OLS_ID=ols.OLS_ID WHERE opr.NUM=lbt.NUM AND ols.Code='SITE'))
	AND (
		@ShowNotInView=1
		OR dbo.fn_CIC_RecordInView(lbtd.NUM, @ViewType, @@LANGID, 1, GETDATE())=1
	)

RETURN

END




GO




GRANT SELECT ON  [dbo].[fn_GBL_NUMToOrgLocations_Details_rst] TO [cioc_cic_search_role]
GO
