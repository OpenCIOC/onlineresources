SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_O211_Taxonomy_Link_Term](
	@BT_TAX_ID [int],
	@LangID [smallint]
)
RETURNS [varchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + '_','') + ttd.Term
	FROM CIC_BT_TAX_TM tlt
	INNER JOIN TAX_Term tt ON 
		tlt.Code = tt.Code
	LEFT JOIN TAX_Term_Description ttd
		ON tt.Code=ttd.Code AND LangID=@LangID
WHERE    tlt.BT_TAX_ID = @BT_TAX_ID

IF @returnStr = '' OR @returnStr IS NULL SET @returnStr = NULL

RETURN @returnStr

END
GO
