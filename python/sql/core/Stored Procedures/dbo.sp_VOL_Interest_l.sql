SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Interest_l]
	@MemberID int,
	@IGIDList varchar(max),
	@GroupByGroup bit,
	@IncludeIGListNames bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @IGIDs TABLE (
	IG_ID int PRIMARY KEY
)

DECLARE @GroupNames nvarchar(max)

INSERT INTO @IGIDs (IG_ID)
SELECT ItemID FROM dbo.fn_GBL_ParseIntIDList(@IGIDList,',')

IF @IncludeIGListNames=1 BEGIN
	SELECT @GroupNames = COALESCE(@GroupNames + ', ','') + Name
		FROM dbo.VOL_InterestGroup ig
		LEFT JOIN dbo.VOL_InterestGroup_Name ign
			ON ig.IG_ID=ign.IG_ID AND ign.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_InterestGroup_Name WHERE IG_ID=ig.IG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		INNER JOIN @IGIDs igl ON igl.IG_ID = ig.IG_ID
	SELECT @GroupNames AS GroupNames
END

IF @GroupByGroup = 1 BEGIN
	SELECT ai.AI_ID, ain.Name AS InterestName, ig.IG_ID, ign.Name AS GroupName
		FROM dbo.VOL_Interest ai
		INNER JOIN dbo.VOL_Interest_Name ain
			ON ai.AI_ID=ain.AI_ID AND ain.LangID=@@LANGID
		INNER JOIN dbo.VOL_AI_IG aiig
			ON aiig.AI_ID = ai.AI_ID
		INNER JOIN dbo.VOL_InterestGroup ig
			 ON ig.IG_ID = aiig.IG_ID
		LEFT JOIN dbo.VOL_InterestGroup_Name ign
			ON ig.IG_ID=ign.IG_ID AND ign.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_InterestGroup_Name WHERE IG_ID=ig.IG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE (@IGIDList IS NULL OR ig.IG_ID IN (SELECT IG_ID FROM @IGIDs))
	AND NOT EXISTS(SELECT * FROM dbo.VOL_Interest_InactiveByMember WHERE AI_ID=ai.AI_ID AND MemberID=@MemberID)
	ORDER BY ig.DisplayOrder, ign.Name, ain.Name
END ELSE BEGIN
	SELECT ai.AI_ID, ain.Name AS InterestName
		FROM dbo.VOL_Interest ai
		INNER JOIN dbo.VOL_Interest_Name ain
			ON ai.AI_ID=ain.AI_ID AND ain.LangID=@@LANGID
	WHERE (@IGIDList IS NULL OR EXISTS(SELECT * FROM dbo.VOL_AI_IG WHERE AI_ID=ai.AI_ID AND IG_ID IN (SELECT IG_ID FROM @IGIDs)))
	AND NOT EXISTS(SELECT * FROM dbo.VOL_Interest_InactiveByMember WHERE AI_ID=ai.AI_ID AND MemberID=@MemberID)
	ORDER BY ain.Name
END

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_l] TO [cioc_vol_search_role]
GO
