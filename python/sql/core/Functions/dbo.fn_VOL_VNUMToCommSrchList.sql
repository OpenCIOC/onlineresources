SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToCommSrchList](
	@VNUM varchar(10)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@conStr varchar(3),
		@returnStr varchar(max)

SET @conStr = ','

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') +  CAST(cms.CM_ID AS varchar)
	FROM (
		-- Given Communities (in the given group(s))
		SELECT CM_ID
			FROM VOL_OP_CM pr
		WHERE pr.VNUM=@VNUM
		-- Children of Given Communities
		UNION SELECT cmpl.CM_ID
			FROM VOL_OP_CM pr
			INNER JOIN GBL_Community_ParentList cmpl
				ON cmpl.Parent_CM_ID=pr.CM_ID
		WHERE pr.VNUM=@VNUM
		-- Parents of Given Communities
		UNION SELECT cmpl.Parent_CM_ID
			FROM VOL_OP_CM pr
			INNER JOIN GBL_Community_ParentList cmpl
				ON cmpl.CM_ID=pr.CM_ID
		WHERE pr.VNUM=@VNUM 
		) cms

RETURN @returnStr

END
GO
