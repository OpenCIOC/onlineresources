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

SELECT @returnStr =  COALESCE(@returnStr + ' ','') + '<div class="text-nowrap">' + /*CASE WHEN iedl.DELETION_DATE IS NOT NULL THEN ' alert alert-danger">' ELSE '">' END + */ sln.LanguageName
														+ CASE WHEN iedl.DELETION_DATE IS NOT NULL THEN ' <span class="glyphicon glyphicon-remove" title="[DELETED]" aria-hidden="true"></span><span class="sr-only">[DELETED]</span>' ELSE '' END 
														+ CASE WHEN iedl.NON_PUBLIC=1 THEN ' <span class="glyphicon glyphicon-lock" title="[NON_PUBLIC]" aria-hidden="true"></span><span class="sr-only">[NON_PUBLIC]</span>' ELSE '' END
														+ '</div>'
	FROM CIC_ImportEntry_Data_Language iedl
	INNER JOIN STP_Language sln
		ON iedl.LangID=sln.LangID
WHERE ER_ID=@ER_ID

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
