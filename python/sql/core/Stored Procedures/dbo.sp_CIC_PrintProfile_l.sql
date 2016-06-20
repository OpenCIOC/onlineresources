SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_PrintProfile_l]
	@MemberID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT pp.ProfileID, ppd.ProfileName
	FROM GBL_PrintProfile pp
	INNER JOIN GBL_PrintProfile_Description ppd
		ON pp.ProfileID=ppd.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Description WHERE ppd.ProfileID=ProfileID AND ppd.ProfileName IS NOT NULL ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE Domain=1
	AND ((@ViewType IS NULL AND MemberID=@MemberID) OR EXISTS(SELECT * FROM CIC_View_PrintProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=pp.ProfileID))
ORDER BY ProfileName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_PrintProfile_l] TO [cioc_login_role]
GO
