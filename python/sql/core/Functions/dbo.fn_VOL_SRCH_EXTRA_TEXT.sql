SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_SRCH_EXTRA_TEXT](
	@VNUM varchar(10),
	@LangID smallint
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 25-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(MAX)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr = COALESCE(@returnStr + @conStr,'') + [Value]
	FROM VOL_OP_EXTRA_TEXT et
	INNER JOIN VOL_FieldOption fo
		ON et.FieldName=fo.FieldName
WHERE et.VNUM=@VNUM AND et.LangID=@LangID
	AND fo.FullTextIndex=1
	
RETURN @returnStr

END

GO
