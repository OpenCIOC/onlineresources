
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_Layout_s]
	@MemberID int,
	@AgencyCode [char](3),
	@LayoutID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jul-2012
	Action: NO ACTION REQUIRED
	Notes: Should ensure that the front-end can manage if there are errors; may need proper error messages
*/

DECLARE	@Error int
SET @Error = 0
		
-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Template belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Template_Layout tp WHERE LayoutID=@LayoutID AND (MemberID=@MemberID OR MemberID IS NULL)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	tl.*,
		CASE WHEN tl.Owner IS NULL OR @AgencyCode IS NULL OR tl.Owner=@AgencyCode THEN NULL ELSE tl.Owner END AS ReadOnlyLayoutOwner,
		(SELECT Template_ID, Owner, Name, MemberID
		FROM (SELECT t.Template_ID, Owner, td.Name, t.MemberID
			FROM GBL_Template t
			INNER JOIN GBL_Template_Description td
				ON t.Template_ID=td.Template_ID AND td.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Description WHERE Template_ID=td.Template_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
			WHERE FooterLayout=tl.LayoutID OR HeaderLayout=tl.LayoutID OR SearchLayoutCIC=tl.LayoutID OR SearchLayoutVOL=tl.LayoutID) TMPL
		FOR XML AUTO, ROOT('TEMPLATES')) AS RELATED_TEMPLATE
	FROM GBL_Template_Layout tl
WHERE (MemberID=@MemberID OR MemberID IS NULL)
	AND LayoutID=@LayoutID

SELECT tld.*, l.Culture
	FROM GBL_Template_Layout_Description tld 
	INNER JOIN STP_Language l
		ON tld.LangID=l.LangID
WHERE LayoutID=@LayoutID

SET NOCOUNT OFF

GO


GRANT EXECUTE ON  [dbo].[sp_GBL_Template_Layout_s] TO [cioc_login_role]
GO
