
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_LinkOrgLevel](
	@ViewType int,
	@NUM varchar(8),
	@Org1 nvarchar(200),
	@Org2 nvarchar(200),
	@Org3 nvarchar(200),
	@Org4 nvarchar(200),
	@Org5 nvarchar(200),
	@DateToday datetime
)
RETURNS tinyint WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 26-Mar-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@returnVal	tinyint

DECLARE @MatchTable table (
	[ORG_LEVEL_2] [nvarchar](200) COLLATE Latin1_General_100_CI_AI NULL INDEX IX_TMP_O2,
	[ORG_LEVEL_3] [nvarchar](200) COLLATE Latin1_General_100_CI_AI NULL,
	[ORG_LEVEL_4] [nvarchar](200) COLLATE Latin1_General_100_CI_AI NULL,
	[ORG_LEVEL_5] [nvarchar](200) COLLATE Latin1_General_100_CI_AI NULL
)

INSERT INTO @MatchTable (
	ORG_LEVEL_2,
    ORG_LEVEL_3,
    ORG_LEVEL_4,
    ORG_LEVEL_5
)
SELECT ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5
FROM GBL_BaseTable_Description btd
	WHERE btd.NUM<>@NUM
		AND btd.LangID=@@LANGID
		AND dbo.fn_CIC_RecordInView(btd.NUM,@ViewType,@@LANGID,1,@DateToday)=1
		AND ORG_LEVEL_1=@Org1

SELECT @returnVal = CASE
		WHEN NOT EXISTS(SELECT * FROM @MatchTable) THEN 0
		WHEN NOT EXISTS(SELECT * FROM @MatchTable WHERE ORG_LEVEL_2=@Org2) THEN 1
		WHEN NOT EXISTS(SELECT * FROM @MatchTable WHERE ORG_LEVEL_2=@Org2 AND ORG_LEVEL_3=@Org3) THEN 2
		WHEN NOT EXISTS(SELECT * FROM @MatchTable WHERE ORG_LEVEL_2=@Org2 AND ORG_LEVEL_3=@Org3 AND ORG_LEVEL_4=@Org4) THEN 3
		WHEN NOT EXISTS(SELECT * FROM @MatchTable WHERE ORG_LEVEL_2=@Org2 AND ORG_LEVEL_3=@Org3 AND ORG_LEVEL_4=@Org4 AND ORG_LEVEL_5=@Org5) THEN 4
		ELSE 5
	END

RETURN @returnVal

END

GO

GRANT EXECUTE ON  [dbo].[fn_CIC_LinkOrgLevel] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_LinkOrgLevel] TO [cioc_login_role]
GO
