
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_LinkServiceNameLevel](
	@ViewType int,
	@NUM varchar(8),
	@ORG_NUM varchar(8),
	@Service nvarchar(200),
	@DateToday datetime
)
RETURNS bit WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 23-Oct-2014
	Action:	NO ACTION REQUIRED
*/

DECLARE	@returnVal	bit

SET @ORG_NUM = ISNULL(@ORG_NUM,@NUM)

DECLARE @TmpNUMs TABLE (NUM varchar(8) NOT NULL)
INSERT INTO @TmpNUMs
SELECT bt.NUM
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON btd.NUM=bt.NUM AND btd.LangID=@@LANGID
WHERE btd.NUM<>@NUM
	AND @ORG_NUM IN (bt.ORG_NUM,bt.NUM)
	AND @Service IN (SERVICE_NAME_LEVEL_1,SERVICE_NAME_LEVEL_2)

SELECT @returnVal = CASE WHEN NOT EXISTS(SELECT * FROM @TmpNUMs WHERE dbo.fn_CIC_RecordInView(NUM,@ViewType,@@LANGID,0,@DateToday)=1) THEN 0 ELSE 1 END

RETURN @returnVal

END

GO

GRANT EXECUTE ON  [dbo].[fn_CIC_LinkServiceNameLevel] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_LinkServiceNameLevel] TO [cioc_login_role]
GO
