
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Interest_l]
	@MemberID int,
	@IGIDList varchar(max),
	@IncludeGroupName [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @IGIDs TABLE (
	IG_ID int PRIMARY KEY
)

DECLARE @GroupNames nvarchar(max)

INSERT INTO @IGIDs (IG_ID)
SELECT ItemID FROM dbo.fn_GBL_ParseIntIDList(@IGIDList,',')

IF @IncludeGroupName=1 BEGIN
	SELECT @GroupNames = COALESCE(@GroupNames + ', ','') + Name
		FROM VOL_InterestGroup ig
		LEFT JOIN VOL_InterestGroup_Name ign
			ON ig.IG_ID=ign.IG_ID AND ign.LangID=(SELECT TOP 1 LangID FROM VOL_InterestGroup_Name WHERE IG_ID=ig.IG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			
	SELECT @GroupNames AS GroupNames
END

SELECT ai.AI_ID, ain.Name AS InterestName
	FROM VOL_Interest ai
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=@@LANGID
WHERE (@IGIDList IS NULL OR EXISTS(SELECT * FROM VOL_AI_IG WHERE AI_ID=ai.AI_ID AND IG_ID IN (SELECT IG_ID FROM @IGIDs)))
AND NOT EXISTS(SELECT * FROM VOL_Interest_InactiveByMember WHERE AI_ID=ai.AI_ID AND MemberID=@MemberID)
ORDER BY ain.Name

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_l] TO [cioc_vol_search_role]
GO
