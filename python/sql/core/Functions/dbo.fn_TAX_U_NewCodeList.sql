SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_TAX_U_NewCodeList](@OldCode [varchar](21))
RETURNS [varchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@conStr	varchar(3),
		@returnStr	varchar(max)

SET @conStr = ' ; '
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + uoc.Code
FROM dbo.TAX_U_oldCode uoc
WHERE uoc.oldCode=@OldCode

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr

END
GO
