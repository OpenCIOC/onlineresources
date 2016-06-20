SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_FullRecordType](
	@RT_ID int
)
RETURNS nvarchar(210) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(210)

IF @RT_ID IS NOT NULL BEGIN
	SELECT @returnStr = CASE WHEN rtn.Name IS NULL THEN rt.RecordType ELSE '(' + rt.RecordType + ') ' + rtn.Name END
		FROM CIC_RecordType rt
		LEFT JOIN CIC_RecordType_Name rtn
			ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
	WHERE rt.RT_ID = @RT_ID
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_FullRecordType] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_FullRecordType] TO [cioc_login_role]
GO
