SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMInterest_s]
	@MemberID int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT ai.AI_ID, ain.LangID, CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName, 
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM dbo.VOL_Interest ai
	INNER JOIN dbo.VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM  dbo.VOL_Interest_Name WHERE AI_ID=ain.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN  dbo.VOL_OP_AI pr
		ON ai.AI_ID=pr.AI_ID AND pr.VNUM=@VNUM
ORDER BY IS_SELECTED DESC, ain.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMInterest_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMInterest_s] TO [cioc_vol_search_role]
GO
