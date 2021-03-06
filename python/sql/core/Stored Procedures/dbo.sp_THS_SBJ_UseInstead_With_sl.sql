SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_SBJ_UseInstead_With_sl]
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
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@@LANGID
	INNER JOIN THS_SBJ_UseInstead ui
		ON sj.Subj_ID=ui.UsedSubj_ID
			AND ui.UsedSubj_ID<>@Subj_ID
	INNER JOIN THS_SBJ_UseInstead ui2
		ON ui.Subj_ID=ui2.Subj_ID
			AND ui2.UsedSubj_ID=@Subj_ID
WHERE (@UseLocalSubjects=1 OR Authorized=1)
	AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
GROUP BY sj.Subj_ID, sjn.Name, sj.UseAll
HAVING sj.UseAll = 0
ORDER BY sjn.Name

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_UseInstead_With_sl] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_UseInstead_With_sl] TO [cioc_login_role]
GO
