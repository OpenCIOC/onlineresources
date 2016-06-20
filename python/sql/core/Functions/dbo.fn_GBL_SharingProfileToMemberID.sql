SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fn_GBL_SharingProfileToMemberID](
	@ProfileID int
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

RETURN (SELECT MemberID FROM GBL_SharingProfile WHERE ProfileID=@ProfileID)

END

GO
