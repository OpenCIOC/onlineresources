SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_l]
	@MemberID int,
	@LangID smallint,
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

SELECT vs.Name, sl.LanguageName
	FROM dbo.VOL_ApplicationSurvey vs
	INNER JOIN dbo.STP_Language sl
		ON vs.LangID=sl.LangID
WHERE vs.MemberID=@MemberID
	AND (@LangID IS NULL OR @LangID=vs.LangID)
	AND (@ActiveOnly=0 OR vs.ARCHIVED_DATE IS NULL)
ORDER BY sl.LanguageName, vs.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_l] TO [cioc_login_role]
GO
