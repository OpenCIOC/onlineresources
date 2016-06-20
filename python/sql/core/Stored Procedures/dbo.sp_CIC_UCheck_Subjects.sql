SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_UCheck_Subjects]
	@MemberID int,
	@NewTerms nvarchar(max),
	@BadTerms nvarchar(max) OUTPUT,
	@NewIDs varchar(max) OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@SubjectObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SubjectObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Subject')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END

DECLARE	@tmpSubjectTerms TABLE (SubjectTerm nvarchar(200) COLLATE Latin1_General_100_CI_AI)
DECLARE	@tmpGoodSubjectTerms TABLE (SubjectTerm nvarchar(200) COLLATE Latin1_General_100_CI_AI)

SET @NewTerms = RTRIM(LTRIM(@NewTerms))
IF @NewTerms = '' SET @NewTerms = NULL

IF @Error=0 AND @NewTerms IS NOT NULL BEGIN
	INSERT INTO @tmpSubjectTerms
	SELECT *
		FROM dbo.fn_GBL_ParseVarCharIDList(@NewTerms,';')
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		SELECT @NewIDs = COALESCE(@NewIDs + ',','') + CAST(sj.Subj_ID AS varchar)
			FROM @tmpSubjectTerms tm
			INNER JOIN THS_Subject_Name sjn
				ON tm.SubjectTerm=sjn.Name AND LangID=@@LANGID
			INNER JOIN THS_Subject sj
				ON sjn.Subj_ID=sj.Subj_ID
		WHERE sj.Used=1 AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg OUTPUT

		DELETE tm
			FROM @tmpSubjectTerms tm
			INNER JOIN THS_Subject_Name sjn
				ON tm.SubjectTerm=sjn.Name AND LangID=@@LANGID
			INNER JOIN THS_Subject sj
				ON sjn.Subj_ID=sj.Subj_ID
		WHERE sj.Used=1 AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg OUTPUT

		SELECT @NewIDs = COALESCE(@NewIDs + ',','') + CAST(sj.Subj_ID AS varchar)
			FROM @tmpSubjectTerms tm
			INNER JOIN THS_Subject_Name sjn
				ON tm.SubjectTerm=sjn.Name
			INNER JOIN THS_Subject sj
				ON sjn.Subj_ID=sj.Subj_ID
		WHERE sj.Used=1 AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg OUTPUT

		DELETE tm
			FROM @tmpSubjectTerms tm
			INNER JOIN THS_Subject_Name sjn
				ON tm.SubjectTerm=sjn.Name
			INNER JOIN THS_Subject sj
				ON sjn.Subj_ID=sj.Subj_ID
		WHERE sj.Used=1 AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg OUTPUT

		SELECT @BadTerms = COALESCE(@BadTerms + ' ; ','') + tm.SubjectTerm
			FROM @tmpSubjectTerms tm
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg OUTPUT
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_UCheck_Subjects] TO [cioc_login_role]
GO
