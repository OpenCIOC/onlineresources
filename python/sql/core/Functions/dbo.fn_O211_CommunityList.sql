SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_O211_CommunityList](
	@CM_ID int
)
RETURNS @communitiesTable TABLE (
	[CM_ID] int NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
	Notes: Recommend using new optimized search list build (see fn_GBL_Community_Search_rst)
*/

DECLARE	@loopCount int,
		@rowCount int

DECLARE @firstIDList TABLE ( CM_ID int )
DECLARE @tempCom1 TABLE ( CM_ID int )
DECLARE @tempCom2 TABLE ( CM_ID int )

INSERT @firstIDList
SELECT cm.CM_ID 
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND LangID=0
WHERE cm.CM_ID = @CM_ID
	AND cmn.Name NOT IN ('Not Limited', 'Not Known', 'International', 'North America')

INSERT @tempCom1 SELECT * FROM @firstIDList
INSERT @communitiesTable SELECT * FROM @firstIDList

SET @rowCount = @@ROWCOUNT
SET @loopCount = 10

WHILE @rowCount > 0 AND @loopCount > 0 BEGIN
	DELETE @tempCom2
	INSERT @tempCom2 SELECT * FROM @tempCom1
	DELETE @tempCom1
	INSERT @tempCom1 SELECT cm.ParentCommunity
		FROM @tempCom2 tm2
		INNER JOIN GBL_Community cm
			ON tm2.CM_ID = cm.CM_ID
		WHERE cm.ParentCommunity IS NOT NULL
			AND NOT EXISTS(SELECT *
				FROM GBL_Community pc
				INNER JOIN GBL_Community_Name cmn
					ON pc.CM_ID=cmn.CM_ID AND LangID=0
				WHERE pc.CM_ID=cm.ParentCommunity AND cmn.Name IN ('Not Limited', 'Not Known', 'International', 'North America'))
		GROUP BY cm.ParentCommunity
	SET @rowCount = @@ROWCOUNT
	IF @rowCount > 0 BEGIN
		INSERT @communitiesTable SELECT tm1.CM_ID
			FROM @tempCom1 tm1
			LEFT JOIN @communitiesTable cl
				ON tm1.CM_ID = cl.CM_ID
		WHERE cl.CM_ID IS NULL
		SET @rowCount = @@ROWCOUNT
	END
	SET @loopCount = @loopCount - 1
END
RETURN
END
GO
