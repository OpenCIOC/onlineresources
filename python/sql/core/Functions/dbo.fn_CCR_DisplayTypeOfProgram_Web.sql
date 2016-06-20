SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_DisplayTypeOfProgram_Web](
	@TOP_ID int,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(1000) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@TypeOfProgram	nvarchar(1000)

SELECT @TypeOfProgram = topn.Name
	FROM CCR_TypeOfProgram [top]
	INNER JOIN CCR_TypeOfProgram_Name topn
		ON [top].TOP_ID=topn.TOP_ID AND topn.LangID=@@LANGID
WHERE [top].TOP_ID = @TOP_ID

IF @TypeOfProgram = ''
	SET @TypeOfProgram = NULL
ELSE
	SET @TypeOfProgram = cioc_shared.dbo.fn_SHR_CCR_Link_TypeOfProgram(@TOP_ID,@TypeOfProgram,@HTTPVals,@PathToStart)

RETURN @TypeOfProgram

END



GO
GRANT EXECUTE ON  [dbo].[fn_CCR_DisplayTypeOfProgram_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CCR_DisplayTypeOfProgram_Web] TO [cioc_login_role]
GO
