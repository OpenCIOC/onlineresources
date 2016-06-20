SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_GHIDToWhereClause_Link](
	@GH_TAX_ID int,
	@Restrict bit
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

SET @conStr = ' AND '

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ 'EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID'
		+ ' AND tlt.Code' + CASE WHEN @Restrict=1 THEN '=''' + Code + '''' ELSE ' LIKE ''' + Code + '%''' END
		+ ')'
	FROM CIC_GeneralHeading_TAX_TM
WHERE GH_TAX_ID=@GH_TAX_ID

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToWhereClause_Link] TO [cioc_login_role]
GO
