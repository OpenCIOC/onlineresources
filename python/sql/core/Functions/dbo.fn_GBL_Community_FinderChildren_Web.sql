
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_Community_FinderChildren_Web](
	@CM_ID int,
	@HTTPVals varchar(500),
	@PathToStart varchar(50),
	@SearchParameters bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7.2
	Checked by: KL
	Checked on: 23-Oct-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + '</li><li>','')
		+ cioc_shared.dbo.fn_SHR_GBL_Link_CommunityFinder(cm.CM_ID,
			CASE WHEN cm.AlternativeArea=1 THEN '<em>' ELSE '' END + cmn.Name + CASE WHEN cm.AlternativeArea=1 THEN '</em>' ELSE '' END,
			CASE WHEN EXISTS(SELECT * FROM GBL_Community WHERE ParentCommunity=cm.CM_ID) THEN 1 ELSE 0 END,
			@HTTPVals,
			@PathToStart
		) + CASE WHEN @SearchParameters=1 THEN ' <span class="HighLight">CMID=' + CAST(cm.CM_ID AS nvarchar(25)) + '</span>' ELSE '' END
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cm.ParentCommunity=@CM_ID
ORDER BY cmn.Name

IF @returnStr = '' BEGIN
	SET @returnStr = NULL 
END ELSE BEGIN
	SET @returnStr = '<ul><li>' + @returnStr + '</li></ul>'
END

RETURN @returnStr

END




GO



GRANT EXECUTE ON  [dbo].[fn_GBL_Community_FinderChildren_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_FinderChildren_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_FinderChildren_Web] TO [cioc_vol_search_role]
GO
