SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_TypeOfProgram_Check]
	@TypeOfProgramEn nvarchar(200),
	@TypeOfProgramFr nvarchar(200),
	@TOP_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @TOP_ID = TOP_ID
	FROM CCR_TypeOfProgram_Name
WHERE [Name]=@TypeOfProgramEn OR [Name]=@TypeOfProgramFr
	ORDER BY CASE
		WHEN [Name]=@TypeOfProgramEn AND LangID=0 THEN 0
		WHEN [Name]=@TypeOfProgramFr AND LangID=2 THEN 1
		ELSE 2
	END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_TypeOfProgram_Check] TO [cioc_login_role]
GO
