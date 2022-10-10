SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_UpdateFields_l]
	@MemberID int,
	@AgencyCode char(3),
	@ViewType int,
	@RT_ID [int]
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

DECLARE @RT_HAS_FORM bit

IF @RT_ID IS NOT NULL BEGIN
	SET @RT_HAS_FORM = CAST(CASE WHEN EXISTS(SELECT uf.FieldID, fg.DisplayOrder, fg.DisplayFieldGroupID
			FROM dbo.CIC_View_UpdateField uf
			INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
				ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
			WHERE uf.RT_ID=@RT_ID) THEN 1 ELSE 0 END AS bit)

	SELECT rt.RT_ID, rt.RecordType, rtn.Name AS RecordTypeName, @RT_HAS_FORM AS RT_HAS_FORM
	FROM dbo.CIC_RecordType rt
	LEFT JOIN dbo.CIC_RecordType_Name rtn
		ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
	WHERE rt.RT_ID=@RT_ID

	IF @@ROWCOUNT = 0 SET @RT_ID = NULL
END

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(fod.FieldDisplay, fo.FieldName) AS FieldDisplay,
		fg.DisplayFieldGroupID
	FROM dbo.GBL_FieldOption fo
	LEFT JOIN dbo.GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN (SELECT uf.FieldID, fg.DisplayOrder, fg.DisplayFieldGroupID, fgn.Name AS DisplayFieldGroupName
			FROM dbo.CIC_View_UpdateField uf
			INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
				ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
			LEFT JOIN dbo.CIC_View_DisplayFieldGroup_Name fgn
				ON fgn.LangID=@@LANGID AND fgn.DisplayFieldGroupID=fg.DisplayFieldGroupID
			WHERE (((@RT_ID IS NULL OR @RT_HAS_FORM=0) AND uf.RT_ID IS NULL) OR uf.RT_ID=@RT_ID)) fg
		ON fo.FieldID=fg.FieldID
	LEFT JOIN dbo.GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE fo.CanUseUpdate=1 
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
GRANT EXECUTE ON  [dbo].[sp_CIC_View_UpdateFields_l] TO [cioc_login_role]
GO
