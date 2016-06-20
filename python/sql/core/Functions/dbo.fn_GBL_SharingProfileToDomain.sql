SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION [dbo].[fn_GBL_SharingProfileToDomain](
	@ProfileID int
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Feb-2012
	Action: NO ACTION REQUIRED
*/

RETURN (SELECT Domain FROM GBL_SharingProfile WHERE ProfileID=@ProfileID)

END


GO
