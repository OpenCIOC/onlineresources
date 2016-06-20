SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fn_GBL_SharingProfile_CheckActive](
	@AcceptedDate datetime,
	@RevokedDate datetime,
	@Active bit
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

RETURN CASE WHEN @AcceptedDate IS NOT NULL OR @Active=0 THEN 1 ELSE 0 END

END

GO
