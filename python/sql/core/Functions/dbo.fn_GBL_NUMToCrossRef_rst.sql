SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToCrossRef_rst](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @CrossRefNames TABLE (
	[OrgName] nvarchar(255) COLLATE Latin1_General_100_CS_AS NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 30-Sep-2013
	Action: NO ACTION REQUIRED
*/

INSERT INTO @CrossRefNames
select NAME COLLATE Latin1_General_100_CS_AS
FROM GBL_BaseTable_Description btd
UNPIVOT (NAME FOR NM IN (ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LEGAL_ORG, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2)) AS t
WHERE NUM=@NUM AND LangID=@LangID
	AND NAME IS NOT NULL 
	AND (
	(NM='ORG_LEVEL_2' AND O2_PUBLISH=1)
	OR (NM='ORG_LEVEL_3' AND O3_PUBLISH=1) 
	OR (NM='ORG_LEVEL_4' AND O4_PUBLISH=1)
	OR (NM='ORG_LEVEL_5' AND O5_PUBLISH=1)
	OR (NM='LEGAL_ORG' AND LO_PUBLISH=1)
	OR (NM='SERVICE_NAME_LEVEL_1' AND S1_PUBLISH=1)
	OR (NM='SERVICE_NAME_LEVEL_2' AND S1_PUBLISH=2)
	)
UNION SELECT ALT_ORG As OrgName
	FROM GBL_BT_ALTORG
WHERE PUBLISH=1 AND LangID=@LangID AND NUM=@NUM
UNION SELECT FORMER_ORG AS OrgName
	FROM GBL_BT_FORMERORG
WHERE PUBLISH=1 AND LangID=@LangID AND NUM=@NUM

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_GBL_NUMToCrossRef_rst] TO [cioc_cic_search_role]
GO
