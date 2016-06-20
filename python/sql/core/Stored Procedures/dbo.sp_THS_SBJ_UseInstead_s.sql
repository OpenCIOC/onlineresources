SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_SBJ_UseInstead_s]
	@Subj_ID int,
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 24-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT ui.UsedSubj_ID as Subj_ID, sjn.Name AS SubjectTerm
	FROM THS_Subject sj
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND LangID=@@LANGID
	INNER JOIN THS_SBJ_UseInstead ui
		ON ui.UsedSubj_ID = sj.Subj_ID
WHERE ui.Subj_ID = @Subj_ID
	AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
ORDER BY sjn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_UseInstead_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_UseInstead_s] TO [cioc_login_role]
GO
