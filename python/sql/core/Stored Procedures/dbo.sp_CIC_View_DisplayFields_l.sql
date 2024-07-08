SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_DisplayFields_l]
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
END ELSE IF NOT EXISTS (SELECT * FROM dbo.CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM dbo.CIC_View vw
	INNER JOIN dbo.CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	AND vw.ViewType=@ViewType

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(fod.FieldDisplay,fo.FieldName) AS FieldDisplay,
		fg.DisplayFieldGroupID
	FROM dbo.GBL_FieldOption fo
	LEFT JOIN dbo.GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN (SELECT fd.FieldID, fg.DisplayOrder, fg.DisplayFieldGroupID, fgn.Name AS DisplayFieldGroupName
			FROM dbo.CIC_View_DisplayField fd
			INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
				ON fd.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
			LEFT JOIN dbo.CIC_View_DisplayFieldGroup_Name fgn
				ON fgn.LangID=@@LANGID AND fgn.DisplayFieldGroupID=fg.DisplayFieldGroupID) fg
		ON fo.FieldID=fg.FieldID
	LEFT JOIN dbo.GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE (fo.CanUseDisplay=1)
	AND (fi.FieldID IS NULL OR fg.DisplayFieldGroupID IS NOT NULL)
	AND (fo.PB_ID IS NULL
		OR fg.DisplayFieldGroupID IS NOT NULL
		OR (
			EXISTS(SELECT * FROM dbo.CIC_Publication pb WHERE pb.PB_ID=fo.PB_ID AND (pb.MemberID IS NULL OR pb.MemberID=@MemberID))
			AND NOT EXISTS(SELECT * FROM dbo.CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=fo.PB_ID AND pbi.MemberID=@MemberID)
		)
	)
ORDER BY CASE WHEN fg.DisplayFieldGroupID IS NULL THEN 1 ELSE 0 END,
	fg.DisplayOrder, fg.DisplayFieldGroupName, fg.DisplayFieldGroupID, fo.DisplayOrder, fo.FieldName

RETURN @Error

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_DisplayFields_l] TO [cioc_login_role]
GO
