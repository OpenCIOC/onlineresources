SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_SBJ_BroaderTerm_sl]
	@Subj_ID int,
	@ViewType int	
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 24-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@UseLocalSubjects bit
		
SELECT @MemberID=MemberID, @UseLocalSubjects=UseLocalSubjects
	FROM CIC_View
WHERE ViewType=@ViewType

SELECT sj.Subj_ID, sjn.Name AS SubjectTerm
	FROM THS_Subject sj
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND LangID=@@LANGID
	INNER JOIN THS_SBJ_BroaderTerm bsj
		ON bsj.BroaderSubj_ID=sj.Subj_ID
			AND bsj.Subj_ID=@Subj_ID
WHERE (@UseLocalSubjects=1 OR Authorized=1)
	AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
ORDER BY sjn.Name

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_BroaderTerm_sl] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_BroaderTerm_sl] TO [cioc_login_role]
GO
