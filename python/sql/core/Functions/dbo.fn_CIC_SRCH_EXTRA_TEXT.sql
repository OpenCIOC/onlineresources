SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_SRCH_EXTRA_TEXT](
	@NUM varchar(8),
	@LangID smallint,
	@PRIVACY_PROFILE int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr = COALESCE(@returnStr + @conStr,'') + [Value]
	FROM CIC_BT_EXTRA_TEXT et
	INNER JOIN GBL_FieldOption fo
		ON et.FieldName=fo.FieldName
WHERE et.NUM=@NUM AND et.LangID=@LangID
	AND fo.FullTextIndex=1
	AND dbo.fn_GBL_FieldIsPrivate(@PRIVACY_PROFILE,fo.FieldName)=0
	
RETURN @returnStr

END
GO
