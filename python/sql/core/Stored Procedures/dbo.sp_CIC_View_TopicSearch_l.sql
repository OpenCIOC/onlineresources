SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_TopicSearch_l]
	@MemberID int,
	@AgencyCode char(3),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 14-Sept-2013
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
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND (vw.Owner IS NULL OR vw.Owner=@AgencyCode)
	AND vw.ViewType=@ViewType

SELECT ts.TopicSearchID, SearchTitle
FROM CIC_View_TopicSearch ts
	INNER JOIN CIC_View_TopicSearch_Description tsd
		ON ts.TopicSearchID=tsd.TopicSearchID AND tsd.LangID=(SELECT TOP 1 LangID FROM CIC_View_TopicSearch_Description WHERE TopicSearchID=tsd.TopicSearchID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ts.ViewType=@ViewType
ORDER BY ts.DisplayOrder, tsd.SearchTitle

RETURN @Error

SET NOCOUNT OFF









GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_TopicSearch_l] TO [cioc_login_role]
GO
