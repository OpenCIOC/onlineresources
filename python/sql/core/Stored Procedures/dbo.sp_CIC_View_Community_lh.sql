SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_Community_lh]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @CMList TABLE (
	CM_ID int NOT NULL PRIMARY KEY,
	Parent_CM_ID int NULL,
	Lvl tinyint NULL
)

INSERT INTO @CMList (CM_ID, Parent_CM_ID)
SELECT DISTINCT cm.CM_ID, cm.ParentCommunity
	FROM dbo.GBL_Community cm
	INNER JOIN dbo.GBL_Community_ParentList pl
		ON pl.CM_ID = cm.CM_ID
	INNER JOIN dbo.CIC_View_Community cs
		ON (cs.CM_ID = cm.CM_ID OR pl.Parent_CM_ID=cs.CM_ID) AND cs.ViewType = @ViewType

UPDATE cl SET
	Parent_CM_ID = NULL,
	Lvl = 0
FROM @CMList cl
WHERE NOT EXISTS(SELECT * FROM @CMList WHERE CM_ID=cl.Parent_CM_ID)

UPDATE cl SET
	Lvl = 1
FROM @CMList cl
INNER JOIN @CMList cp
	ON cl.Parent_CM_ID=cp.CM_ID
WHERE cp.Lvl=0

UPDATE cl SET
	Lvl = 2
FROM @CMList cl
INNER JOIN @CMList cp
	ON cl.Parent_CM_ID=cp.CM_ID
WHERE cp.Lvl=1

DELETE FROM @CMList WHERE lvl IS NULL

SELECT cm.CM_ID, cm.Lvl, cm.Parent_CM_ID, ISNULL(cmn.Display,cmn.Name) AS Community
	FROM @CMList cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY cm.Lvl, cm.Parent_CM_ID, Community

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_Community_lh] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_Community_lh] TO [cioc_login_role]
GO
