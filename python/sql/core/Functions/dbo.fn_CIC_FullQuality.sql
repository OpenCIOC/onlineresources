SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_FullQuality](
	@RQ_ID int
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

IF @RQ_ID IS NOT NULL BEGIN
	SELECT @returnStr = CASE WHEN qln.Name IS NULL THEN ql.Quality ELSE '(' + ql.Quality + ') ' + qln.Name END
		FROM CIC_Quality ql
		LEFT JOIN CIC_Quality_Name qln
			ON ql.RQ_ID=qln.RQ_ID AND qln.LangID=@@LANGID
	WHERE ql.RQ_ID = @RQ_ID
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_FullQuality] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_FullQuality] TO [cioc_login_role]
GO
