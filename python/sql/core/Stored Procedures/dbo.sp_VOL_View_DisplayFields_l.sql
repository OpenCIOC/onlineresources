SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_DisplayFields_l]
	@MemberID int,
	@AgencyCode char(3),
	@ViewType int
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

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(fod.FieldDisplay,fo.FieldName) AS FieldDisplay,
		ISNULL(fg.DisplayFieldGroupID,CASE WHEN fg.FieldID IS NOT NULL THEN '-1' ELSE NULL END) AS DisplayFieldGroupID
	FROM dbo.VOL_FieldOption fo
	LEFT JOIN dbo.VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN (SELECT
				fd.FieldID, fg.DisplayOrder,
				fg.DisplayFieldGroupID,
				fgn.Name AS DisplayFieldGroupName
			FROM dbo.VOL_View_DisplayField fd
			LEFT JOIN dbo.VOL_View_DisplayFieldGroup fg
				ON fd.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
			LEFT JOIN dbo.VOL_View_DisplayFieldGroup_Name fgn
				ON fgn.LangID=@@LANGID AND fgn.DisplayFieldGroupID=fg.DisplayFieldGroupID
			WHERE fd.ViewType=@ViewType) fg
		ON fo.FieldID=fg.FieldID
	LEFT JOIN dbo.VOL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE (fo.CanUseDisplay=1)
	AND (fi.FieldID IS NULL OR fg.FieldID IS NOT NULL)
ORDER BY CASE WHEN fg.DisplayFieldGroupID IS NULL THEN CASE WHEN fg.FieldID IS NULL THEN 2 ELSE 0 END ELSE 1 END,
	fg.DisplayOrder, fg.DisplayFieldGroupName, fg.DisplayFieldGroupID, fo.DisplayOrder, fo.FieldName

RETURN @Error

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_DisplayFields_l] TO [cioc_login_role]
GO
