SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_l]
	@MemberID int,
	@ViewType int,
	@AllLanguages bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
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

SELECT ep.ProfileID,
	CASE WHEN epn.LangID=@@LANGID THEN epn.Name ELSE '[' + epn.Name + ']' END AS ProfileName
	FROM CIC_ExportProfile ep
	INNER JOIN CIC_ExportProfile_Description epn
		ON ep.ProfileID=epn.ProfileID
			AND epn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_ExportProfile_Description WHERE ProfileID=epn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE ((@ViewType IS NULL AND MemberID=@MemberID) OR EXISTS(SELECT * FROM CIC_View_ExportProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=ep.ProfileID))
ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, epn.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_l] TO [cioc_login_role]
GO
