
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Template_l_Admin]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT t.Template_ID, t.Owner, t.SystemTemplate, td.Name, (SELECT COUNT(*) FROM CIC_View WHERE Template=t.Template_ID OR PrintTemplate=t.Template_ID) + (SELECT COUNT(*) FROM VOL_View WHERE Template=t.Template_ID OR PrintTemplate=t.Template_ID) AS Usage
	FROM GBL_Template t
	INNER JOIN GBL_Template_Description td
		ON t.Template_ID=td.Template_ID AND td.LangID=(SELECT TOP 1 LangID FROM GBL_Template_Description WHERE Template_ID=td.Template_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE (t.MemberID=@MemberID OR t.SystemTemplate=1)
ORDER BY td.Name

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Template_l_Admin] TO [cioc_login_role]
GO
