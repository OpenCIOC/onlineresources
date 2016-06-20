SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExcelProfile_l]
	@MemberID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT ep.ProfileID, CASE WHEN epn.LangID=@@LANGID THEN epn.Name ELSE '[' + epn.Name + ']' END AS ProfileName
	FROM GBL_ExcelProfile ep
	INNER JOIN GBL_ExcelProfile_Name epn
		ON ep.ProfileID=epn.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_ExcelProfile_Name WHERE ProfileID=epn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE MemberID=@MemberID
	AND Domain=1
	AND (@ViewType IS NULL OR EXISTS(SELECT * FROM CIC_View_ExcelProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=ep.ProfileID))
ORDER BY epn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExcelProfile_l] TO [cioc_login_role]
GO
