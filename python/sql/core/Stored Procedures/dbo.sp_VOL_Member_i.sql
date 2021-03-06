
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_i]
	@VMEM_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@NUM [varchar](8),
	@MemberSince [smalldatetime],
	@NextRenewalDate [smalldatetime],
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 28-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberObjectName nvarchar(100),
		@VolMemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolMemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')

SET @NUM = RTRIM(LTRIM(@NUM))
IF @NUM = '' SET @NUM = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @VolMemberObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- NUM given ?
END ELSE IF @NUM IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #'), @VolMemberObjectName)
-- NUM exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@NUM) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
-- NUM already in use ?
END ELSE IF EXISTS(SELECT * FROM VOL_Member WHERE NUM=@NUM) BEGIN
	SET @Error = 6 -- Value In use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @VolMemberObjectName)
END ELSE BEGIN
	INSERT INTO VOL_Member (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		NUM,
		MemberSince,
		NextRenewalDate
	) VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@MemberID,
		@NUM,
		@MemberSince,
		@NextRenewalDate
	)
	SET @VMEM_ID = SCOPE_IDENTITY()
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolMemberObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Member_i] TO [cioc_login_role]
GO
