SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_TopicSearch_s]
	@TopicSearchID int,
	@ViewType int,
	@AgencyCode char(3),
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 14-Sep-2013
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
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID) BEGIN
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
	
SELECT	ts.*
	FROM CIC_View_TopicSearch ts
WHERE ts.TopicSearchID=@TopicSearchID
	AND ts.ViewType = @ViewType
	
SELECT *, Culture
	FROM CIC_View_Description vd
	INNER JOIN STP_Language l
		ON l.LangID=vd.LangID 
	LEFT JOIN CIC_View_TopicSearch ts
		ON ts.ViewType=vd.ViewType AND ts.TopicSearchID=@TopicSearchID
	LEFT JOIN CIC_View_TopicSearch_Description tsd
		ON tsd.LangID=vd.LangID AND ts.TopicSearchID=tsd.TopicSearchID
WHERE vd.ViewType=@ViewType
ORDER BY l.LangID

EXEC dbo.sp_CIC_Publication_l_SharedLocal @MemberID

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_TopicSearch_s] TO [cioc_login_role]
GO
