SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToNumNeeded_rst](
	@VNUM varchar(10)
)
RETURNS @NeededComms TABLE (
	[Community] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL,
	[NUM_NEEDED] int NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

INSERT INTO @NeededComms
SELECT cmn.Name AS Community, pr.NUM_NEEDED
	FROM VOL_OP_CM pr
	INNER JOIN GBL_Community cm
		ON pr.CM_ID = cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE VNUM = @VNUM
ORDER BY cmn.Name

RETURN

END
GO
