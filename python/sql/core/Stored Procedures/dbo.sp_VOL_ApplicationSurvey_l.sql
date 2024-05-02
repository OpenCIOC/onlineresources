SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_l]
	@MemberID int,
	@ActiveOnly bit

WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT	vs.APP_ID,
		vs.Name,
		sl.LangID,
		sl.LanguageName,
		CASE WHEN vs.ARCHIVED_DATE IS NULL THEN 0 ELSE 1 END AS Archived
	FROM dbo.VOL_ApplicationSurvey vs
	INNER JOIN dbo.STP_Language sl
		ON vs.LangID=sl.LangID
WHERE vs.MemberID=@MemberID
	AND (@ActiveOnly=0 OR vs.ARCHIVED_DATE IS NULL)
ORDER BY sl.LanguageName, CASE WHEN vs.ARCHIVED_DATE IS NULL THEN 0 ELSE 1 END, vs.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_l] TO [cioc_login_role]
GO
