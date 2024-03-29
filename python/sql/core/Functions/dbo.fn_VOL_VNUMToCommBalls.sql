SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToCommBalls](
	@MemberID [int],
	@VNUM [varchar](10),
	@CommunitySetID [int]
)
RETURNS [varchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE @returnStr	varchar(max),
		@BaseURLVOL	varchar(100)

DECLARE @ballTable TABLE (
	BallFileName VARCHAR(255) NULL,
	CommunityGroupName	varchar(100) NOT NULL
)

SELECT @baseURLVOL = '//' + mem.BaseURLVOL
	FROM dbo.STP_Member mem
	INNER JOIN dbo.VOL_CommunitySet vcs
		ON mem.MemberID=vcs.MemberID
WHERE vcs.CommunitySetID=@CommunitySetID

DECLARE @communitiesTable TABLE (
	[CM_ID] int NOT NULL PRIMARY KEY
)

DECLARE @startTable TABLE (
	[CM_ID] int NOT NULL PRIMARY KEY
)

INSERT INTO @startTable
	SELECT CM_ID
	FROM dbo.VOL_OP_CM
WHERE VNUM=@VNUM

INSERT INTO @communitiesTable
	-- Given Communities (in the given group(s))
	SELECT CM_ID
		FROM @startTable
	-- Children of Given Communities
	UNION SELECT cmpl.CM_ID
		FROM dbo.GBL_Community_ParentList cmpl
		INNER JOIN @startTable tm
			ON cmpl.Parent_CM_ID=tm.CM_ID
	-- Parents of Given Communities
	UNION SELECT cmpl.Parent_CM_ID
		FROM dbo.GBL_Community_ParentList cmpl
		INNER JOIN @startTable tm
			ON cmpl.CM_ID=tm.CM_ID

INSERT INTO @ballTable
	SELECT ISNULL(vcg.ImageURL, @baseURLVOL + '/images/' + bl.BallFileName), vcgn.CommunityGroupName
	FROM dbo.VOL_CommunityGroup vcg
	INNER JOIN dbo.VOL_CommunityGroup_Name vcgn
		ON vcg.CommunityGroupID=vcgn.CommunityGroupID AND vcgn.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_CommunityGroup_Name WHERE CommunityGroupID=vcgn.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.VOL_Ball bl
		ON vcg.BallID = bl.BallID
	WHERE vcg.CommunitySetID=@CommunitySetID
		AND EXISTS(SELECT * FROM @communitiesTable ct INNER JOIN dbo.VOL_CommunityGroup_CM vcgc ON ct.CM_ID=vcgc.CM_ID WHERE vcgc.CommunityGroupID=vcg.CommunityGroupID)
	ORDER BY vcgn.CommunityGroupName

SELECT @returnStr = COALESCE(@returnStr + '&nbsp;','')  + '<img src="' + BallFileName + '" alt="' + CommunityGroupName + '" title="' + CommunityGroupName + '">&nbsp;'
	FROM @ballTable

RETURN @returnStr

END

GO

GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToCommBalls] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToCommBalls] TO [cioc_vol_search_role]
GO
