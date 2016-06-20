SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_THS_Subject_s_Basic]
	@Subj_ID int,
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 28-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT sj.*,
	CAST(CASE WHEN EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID) THEN 1 ELSE 0 END AS bit) AS Inactive
FROM THS_Subject sj
WHERE sj.Subj_ID = @Subj_ID

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_THS_Subject_s_Basic] TO [cioc_login_role]
GO
