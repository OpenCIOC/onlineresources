SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_CommBallsLegend](
	@CommunitySetID [int]
)
RETURNS [varchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN 

DECLARE @returnStr varchar(max),
		@baseURLVOL varchar(200)

DECLARE @ballTable TABLE (
	BallFileName varchar(200),
	CommunityGroupName varchar(100)
)

SELECT @baseURLVOL = '//' + mem.BaseURLVOL
	FROM STP_Member mem
	INNER JOIN VOL_CommunitySet vcs
		ON mem.MemberID=vcs.MemberID
WHERE vcs.CommunitySetID=@CommunitySetID

INSERT INTO @ballTable SELECT ISNULL(vcg.ImageURL, @baseURLVOL + '/images/' + bl.BallFileName), vcgn.CommunityGroupName
	FROM VOL_CommunityGroup vcg
	INNER JOIN VOL_CommunityGroup_Name vcgn
		ON vcg.CommunityGroupID=vcgn.CommunityGroupID AND vcgn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=vcgn.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_Ball bl
		ON vcg.BallID = bl.BallID
	WHERE vcg.CommunitySetID=@CommunitySetID
	ORDER BY vcgn.CommunityGroupName

SELECT @returnStr = COALESCE(@returnStr,'')
        + '<div class="col-sm-6 col-md-12 vol-comm-legend-item">'
        + '<img src="' + BallFileName + '" alt="' + CommunityGroupName + '"> '
        + CommunityGroupName
        + '</div>'
	FROM @ballTable

RETURN @returnStr

END

GO



GRANT EXECUTE ON  [dbo].[fn_VOL_CommBallsLegend] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_CommBallsLegend] TO [cioc_vol_search_role]
GO
