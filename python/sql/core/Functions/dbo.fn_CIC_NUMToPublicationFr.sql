SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToPublicationFr](
	@MemberID int,
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + PubName
	FROM dbo.fn_CIC_NUMToPublicationFr_rst(@MemberID,@NUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublicationFr] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublicationFr] TO [cioc_login_role]
GO
