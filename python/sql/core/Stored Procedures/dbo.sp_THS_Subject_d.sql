SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Subject_d]
	@Subj_ID int,
	@MemberID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@SubjectObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SubjectObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Subject')

IF @Subj_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SubjectObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM THS_Subject WHERE Subj_ID = @Subj_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Subj_ID AS varchar), @SubjectObjectName)
END ELSE IF EXISTS (SELECT * FROM CIC_BT_SBJ WHERE Subj_ID=@Subj_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SubjectObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM THS_Subject WHERE MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DELETE THS_SBJ_RelatedTerm
		WHERE Subj_ID=@Subj_ID
	DELETE THS_Subject
		WHERE Subj_ID = @Subj_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_THS_Subject_d] TO [cioc_login_role]
GO
