SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_CSrch]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT	vw.SrchCommunityDefault,
		vw.CSrch,
		vw.CSrchBusRoute,
		vw.CSrchKeywords,
		vw.CSrchLanguages,
		vw.CSrchNear,
		vw.CSrchSchoolEscort,
		vw.CSrchSchoolsInArea,
		vw.CSrchSubsidy,
        CASE WHEN memd.SubsidyNamedProgramSearchLabel IS NOT NULL THEN vw.CSrchSubsidyNamedProgram ELSE 0 END AS CSrchSubsidyNamedProgram,
		vw.CSrchSpaceAvailable,
		vw.CSrchTypeOfProgram,
        memd.SubsidyNamedProgramSearchLabel
	FROM dbo.CIC_View vw
    INNER JOIN dbo.STP_Member_Description memd
        ON memd.MemberID = vw.MemberID AND memd.LangID=@@LANGID
WHERE vw.ViewType = @ViewType

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_CSrch] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_CSrch] TO [cioc_login_role]
GO
