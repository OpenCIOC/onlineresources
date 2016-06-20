SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_SBJ_UseInstead_For_sl_Admin]
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

SELECT sj.Subj_ID,
		CAST(CASE WHEN EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID) THEN 1 ELSE 0 END AS bit) AS Inactive,
		CASE WHEN sjn.LangID=@@LANGID THEN sjn.Name ELSE '[' + sjn.Name + ']' END AS SubjectTerm,
		dbo.fn_THS_UsedWith(@MemberID, sj.Subj_ID, @Subj_ID, 1) AS UsedWith
	FROM THS_Subject sj
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN THS_SBJ_UseInstead ui
		ON ui.Subj_ID=sj.Subj_ID
			AND ui.UsedSubj_ID=@Subj_ID
ORDER BY sjn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_THS_SBJ_UseInstead_For_sl_Admin] TO [cioc_login_role]
GO
