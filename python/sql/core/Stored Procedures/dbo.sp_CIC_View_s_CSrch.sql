
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_CSrch]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT	SrchCommunityDefault,
		CSrch,
		CSrchBusRoute,
		CSrchKeywords,
		CSrchLanguages,
		CSrchNear,
		CSrchSchoolEscort,
		CSrchSchoolsInArea,
		CSrchSubsidy,
		CSrchSpaceAvailable,
		CSrchTypeOfProgram
	FROM CIC_View vw
WHERE ViewType = @ViewType

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_CSrch] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_CSrch] TO [cioc_login_role]
GO
