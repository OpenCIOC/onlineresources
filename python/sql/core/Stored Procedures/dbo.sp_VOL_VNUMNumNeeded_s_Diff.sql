SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMNumNeeded_s_Diff]
	@VNUM varchar(10),
	@IncludeCMList VARCHAR(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT cm.CM_ID, cmn.Name AS Community, pr.OP_CM_ID, tm.ItemID AS Selected, pr.NUM_NEEDED
	FROM dbo.GBL_Community cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.VOL_OP_CM pr
		ON cm.CM_ID=pr.CM_ID AND pr.VNUM=@VNUM
	LEFT JOIN (SELECT ItemID FROM dbo.fn_GBL_ParseIntIDList(@IncludeCMList, ',')) tm
		ON tm.ItemID = cm.CM_ID
	WHERE pr.CM_ID IS NOT NULL OR tm.ItemID IS NOT NULL
	ORDER BY cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMNumNeeded_s_Diff] TO [cioc_vol_search_role]
GO
