SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_STP_Member_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 09-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

SELECT m.MemberID, md.MemberName
	FROM STP_Member m
	INNER JOIN STP_Member_Description md
		ON md.MemberID=m.MemberID AND md.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=md.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY md.MemberName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_STP_Member_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_STP_Member_l] TO [cioc_vol_search_role]
GO
