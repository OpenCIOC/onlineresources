SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_Community_AuthParent](
	@CM_ID int,
	@FIRST_ID int,
	@TriesLeft tinyint,
	@LangID smallint
)
RETURNS nvarchar(255) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 23-Mar-2012
	Action: NO ACTION REQUIRED
	Notes: REVIEW FOR EFFICIENCY - CAN WE USE _ParentList TABLE?
*/

DECLARE	@IsAuthorized	bit,
		@ParentID	int,
		@CommunityName	nvarchar(255),
		@returnStr	nvarchar(255)

SELECT @IsAuthorized=cm.Authorized, @CommunityName=cmn.Name, @ParentID=ParentCommunity
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
WHERE cm.CM_ID=@CM_ID

IF @CM_ID IS NULL BEGIN
	SET @returnStr = NULL
END ELSE IF @IsAuthorized=1 BEGIN
	IF @CM_ID = @FIRST_ID BEGIN
		SET @returnStr = NULL
	END ELSE BEGIN
		SET @returnStr = @CommunityName
	END
END ELSE IF @TriesLeft > 0 AND @ParentID IS NOT NULL BEGIN
	SET @returnStr = dbo.fn_GBL_Community_AuthParent(
		@ParentID,
		@FIRST_ID,
		@TriesLeft-1,
		@LangID
	)
END ELSE BEGIN
	SET @returnStr = NULL
END

RETURN @returnStr
END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_AuthParent] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_AuthParent] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_AuthParent] TO [cioc_vol_search_role]
GO
