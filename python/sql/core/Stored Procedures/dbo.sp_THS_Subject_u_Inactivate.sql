SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Subject_u_Inactivate]
	@Subj_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Inactive [bit],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 02-Jun-2012
	Action: NO ACTION REQUIRED
*/


DECLARE	@Error		int
SET @Error = 0

DECLARE	@SubjectObjectName nvarchar(100)

SET @SubjectObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Subject')


IF @Subj_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM THS_Subject WHERE Subj_ID=@Subj_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Subj_ID AS varchar), @SubjectObjectName)
END

IF EXISTS(SELECT * FROM CIC_BT_SBJ WHERE Subj_ID=@Subj_ID) BEGIN
	SET @Inactive=0
END

IF @Error = 0 BEGIN
	IF @Inactive = 0 BEGIN
		DELETE FROM THS_Subject_InactiveByMember 
		WHERE MemberID=@MemberID AND Subj_ID=@Subj_ID
	END ELSE IF NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember 
		WHERE MemberID=@MemberID AND Subj_ID=@Subj_ID) BEGIN
		INSERT INTO THS_Subject_InactiveByMember 
			(MemberID, Subj_ID) VALUES (@MemberID, @Subj_ID)
	END
END

RETURN @Error

SET NOCOUNT OFF
















GO
GRANT EXECUTE ON  [dbo].[sp_THS_Subject_u_Inactivate] TO [cioc_login_role]
GO
