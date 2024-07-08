SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_VOL_View_DisplayFieldGroup_lf]
	@MemberID int,
	@AgencyCode char(3),
	@ViewType int,
	@AllDescriptions [bit] = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.VOL_View WHERE ViewType=@ViewType AND MemberID=@MemberID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM dbo.VOL_View vw
	INNER JOIN dbo.VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	AND vw.ViewType=@ViewType

SELECT	fg.DisplayFieldGroupID,
		fg.DisplayOrder,
		(SELECT fgd.Name, l.Culture
		FROM dbo.VOL_View_DisplayFieldGroup_Name fgd
			INNER JOIN STP_Language l
				ON l.LangID=fgd.LangID AND @AllDescriptions = 1
		WHERE fgd.DisplayFieldGroupID=fg.DisplayFieldGroupID
		FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions
FROM dbo.VOL_View_DisplayFieldGroup fg
WHERE fg.ViewType=@ViewType
ORDER BY DisplayOrder, 
	(SELECT TOP 1 Name 
	FROM dbo.VOL_View_DisplayFieldGroup_Name 
	WHERE DisplayFieldGroupID=fg.DisplayFieldGroupID 
	ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)

RETURN @Error
	
SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_DisplayFieldGroup_lf] TO [cioc_login_role]
GO
