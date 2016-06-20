SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_PrintProfile_s]
	@MemberID int,
	@AgencyCode char(3),
	@ProfileID [int]
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
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=1) BEGIN
	SET @Error = 3 -- No Such Record
-- Ownership OK ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID AND Domain=1) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT pp.*,
		(SELECT TOP 1 ProfileName FROM GBL_PrintProfile_Description WHERE pp.ProfileID=ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ProfileName,
		(SELECT COUNT(*) FROM GBL_PrintProfile_Fld pf WHERE pf.ProfileID=pp.ProfileID) AS FieldCount,
		(SELECT ppd.*, l.Culture
			FROM GBL_PrintProfile_Description ppd
			INNER JOIN STP_Language l
				ON l.LangID=ppd.LangID
			WHERE ppd.ProfileID=pp.ProfileID
			FOR XML PATH('DESC'),TYPE) AS Descriptions
	FROM GBL_PrintProfile pp
WHERE MemberID=@MemberID 
	AND ProfileID=@ProfileID
	AND Domain=1

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		CAST(CASE WHEN pp.ProfileID IS NULL THEN 0 ELSE 1 END AS bit) AS InView
	FROM CIC_View vw
	LEFT JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_View_PrintProfile pp 
		ON pp.ViewType=vw.ViewType AND ProfileID=@ProfileID
WHERE pp.ProfileID IS NOT NULL
	OR (
		vw.MemberID=@MemberID
		AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	)
ORDER BY vwd.ViewName

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_PrintProfile_s] TO [cioc_login_role]
GO
