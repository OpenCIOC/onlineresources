SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_DisplayTypeOfProgram](
	@TOP_ID int,
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@TypeOfProgram	nvarchar(200)

SELECT @TypeOfProgram = topn.Name
	FROM CCR_TypeOfProgram [top]
	INNER JOIN CCR_TypeOfProgram_Name topn
		ON [top].TOP_ID=topn.TOP_ID AND topn.LangID=@LangID
WHERE [top].TOP_ID = @TOP_ID

IF @TypeOfProgram = '' SET @TypeOfProgram = NULL

RETURN @TypeOfProgram

END



GO
GRANT EXECUTE ON  [dbo].[fn_CCR_DisplayTypeOfProgram] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CCR_DisplayTypeOfProgram] TO [cioc_login_role]
GO
