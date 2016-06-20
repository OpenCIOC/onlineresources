SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToInterest_rst](
	@VNUM varchar(10),
	@LangID smallint
)
RETURNS @Interest TABLE (
	[AI_ID] int NULL,
	[InterestName] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

INSERT INTO @Interest
SELECT ai.AI_ID, ain.Name
	FROM VOL_OP_AI pr
	INNER JOIN VOL_Interest ai
		ON pr.AI_ID=ai.AI_ID
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND LangID=@LangID
WHERE pr.VNUM = @VNUM
ORDER BY ain.Name

RETURN

END
GO
