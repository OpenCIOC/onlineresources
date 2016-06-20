SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Subject_s]
	@Subj_ID int,
	@OnlyJoinedSubjects bit=0
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 10-May-2012
	Action: NO ACTION REQUIRED
*/

IF @OnlyJoinedSubjects=0 BEGIN
	SELECT sjn.*, l.Culture
	FROM THS_Subject_Name sjn
		INNER JOIN STP_Language l
			ON l.LangID=sjn.LangID 
	WHERE sjn.Subj_ID=@Subj_ID
END

SELECT UsedSubj_ID
	FROM THS_SBJ_UseInstead
WHERE Subj_ID=@Subj_ID

SELECT BroaderSubj_ID
	FROM THS_SBJ_BroaderTerm bsj
WHERE Subj_ID=@Subj_ID

SELECT RelatedSubj_ID 
	FROM THS_SBJ_RelatedTerm
WHERE Subj_ID=@Subj_ID

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_THS_Subject_s] TO [cioc_login_role]
GO
