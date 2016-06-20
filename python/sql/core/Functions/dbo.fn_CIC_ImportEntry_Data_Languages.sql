SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_ImportEntry_Data_Languages](
	@ER_ID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + LanguageName
	FROM CIC_ImportEntry_Data_Language iedl
	INNER JOIN STP_Language sln
		ON iedl.LangID=sln.LangID
WHERE ER_ID=@ER_ID

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
