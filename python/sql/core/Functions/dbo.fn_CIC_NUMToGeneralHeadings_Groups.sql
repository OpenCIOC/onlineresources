SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToGeneralHeadings_Groups](
	@MemberID int,
	@NUM varchar(8),
	@PB_ID int,
	@NonPublic bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 22-Feb-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + GroupName
	FROM fn_CIC_NUMToGeneralHeadings_Groups_rst(@MemberID,@NUM,@PB_ID,@NonPublic)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToGeneralHeadings_Groups] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToGeneralHeadings_Groups] TO [cioc_login_role]
GO
