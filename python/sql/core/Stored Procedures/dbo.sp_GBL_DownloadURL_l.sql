SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_DownloadURL_l]
	@MemberID int,
	@Domain tinyint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT	url.URL_ID,
		ResourceURL, 
		ISNULL(Name,ResourceURL) AS ResourceName,
		sl.LangID,
		sl.LanguageName
FROM GBL_DownloadURL url
LEFT JOIN GBL_DownloadURL_Name urln
	ON url.URL_ID=urln.URL_ID AND LangID=(SELECT TOP 1 LangID FROM GBL_DownloadURL_Name WHERE URL_ID=urln.URL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN STP_Language sl
	ON urln.LangID=sl.LangID
WHERE MemberID=@MemberID
	AND Domain=@Domain
ORDER BY CASE WHEN urln.LangID=@@LANGID OR urln.LangID IS NULL THEN 0 ELSE 1 + sl.LangID END, ISNULL(Name,ResourceURL)

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_DownloadURL_l] TO [cioc_login_role]
GO
