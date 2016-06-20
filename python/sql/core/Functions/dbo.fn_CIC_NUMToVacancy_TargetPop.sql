SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToVacancy_TargetPop](
	@BT_VUT_ID int
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

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(', ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + vtp.TargetPopulation
	FROM dbo.fn_CIC_NUMToVacancy_TargetPop_rst(@BT_VUT_ID) vtp

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
