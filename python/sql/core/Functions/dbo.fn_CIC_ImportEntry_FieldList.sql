SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_ImportEntry_FieldList](
	@EF_ID int
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

DECLARE	@conStr	varchar(3),
		@returnStr	varchar(max)

SET @conStr = ','

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + CAST(FieldID AS varchar)
FROM CIC_ImportEntry_Field
WHERE EF_ID = @EF_ID

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_ImportEntry_FieldList] TO [cioc_login_role]
GO
