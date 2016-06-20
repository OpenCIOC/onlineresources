SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_GHIDToWhereClause_AllorAny](
	@GH_ID int,
	@MatchAny bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(5),
		@returnStr nvarchar(max)

SET @conStr = CASE WHEN @MatchAny=1 THEN ' OR ' ELSE ' AND ' END

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ 'EXISTS(SELECT * FROM CIC_BT_TAX tl WHERE tl.NUM=bt.NUM AND '
		+ dbo.fn_CIC_GHIDToWhereClause_Link(ght.GH_TAX_ID,TaxonomyRestrict)
		+ ')'
	FROM CIC_GeneralHeading_TAX ght
	INNER JOIN CIC_GeneralHeading gh
		ON ght.GH_ID=gh.GH_ID
WHERE gh.GH_ID=@GH_ID
	AND ght.MatchAny=@MatchAny

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToWhereClause_AllorAny] TO [cioc_login_role]
GO
