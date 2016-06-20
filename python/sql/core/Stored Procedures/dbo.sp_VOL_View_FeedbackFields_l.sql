SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_FeedbackFields_l]
	@MemberID int,
	@AgencyCode char(3),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_View WHERE ViewType=@ViewType AND MemberID=@MemberID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	AND vw.ViewType=@ViewType

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(fod.FieldDisplay, fo.FieldName) AS FieldDisplay,
		CASE WHEN EXISTS(SELECT * FROM VOL_View_FeedbackField WHERE ViewType=@ViewType AND FieldID=fo.FieldID)
			THEN 1 ELSE 0 END AS IS_SELECTED
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN VOL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE CanUseFeedback=1
	AND (fi.FieldID IS NULL OR EXISTS(SELECT * FROM VOL_View_FeedbackField WHERE ViewType=@ViewType AND FieldID=fo.FieldID))
ORDER BY fo.DisplayOrder, fo.FieldName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_FeedbackFields_l] TO [cioc_login_role]
GO
