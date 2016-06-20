SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_s]
	@MemberID int,
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE 	@Error	int
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
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT *,
		(SELECT TOP 1 Name FROM CIC_ExportProfile_Description WHERE ProfileID=ep.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ProfileName,
		(SELECT COUNT(*) FROM CIC_ExportProfile_Fld pf WHERE pf.ProfileID=ep.ProfileID) AS FieldCount,
		(SELECT COUNT(*) FROM CIC_ExportProfile_Dist pd WHERE pd.ProfileID=ep.ProfileID) AS DistCount,
		(SELECT COUNT(*) FROM CIC_ExportProfile_Pub pp WHERE pp.ProfileID=ep.ProfileID) AS PubCount,
		(SELECT epd.*, l.Culture
			FROM CIC_ExportProfile_Description epd
			INNER JOIN STP_Language l
				ON l.LangID=epd.LangID
			WHERE epd.ProfileID=ep.ProfileID
			FOR XML PATH('DESC'),TYPE) AS Descriptions
	FROM CIC_ExportProfile ep
WHERE MemberID=@MemberID
	AND ProfileID=@ProfileID

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		CAST(CASE WHEN ep.ProfileID IS NULL THEN 0 ELSE 1 END AS bit) AS InView
	FROM CIC_View vw
	LEFT JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_View_ExportProfile ep 
		ON ep.ViewType=vw.ViewType AND ProfileID=@ProfileID
WHERE ep.ProfileID IS NOT NULL
	OR vw.MemberID=@MemberID
ORDER BY CASE WHEN ep.ViewType IS NOT NULL THEN 0 ELSE 1 END, vwd.ViewName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_s] TO [cioc_login_role]
GO
