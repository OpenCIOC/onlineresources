SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_Offline_Machine_i]
	@SL_ID [int],
	@MachineName [nvarchar](255),
	@PublicKey [nvarchar](1000),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 04-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@UserTypeObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@ComputerObjectName nvarchar(100),
		@KeyObjectName nvarchar(100)

SET @UserTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Type')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @ComputerObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Computer')
SET @KeyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Key')


DECLARE @MemberID int
SELECT @MemberID=MemberID FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID


IF NOT EXISTS (SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SL_ID AS varchar), @UserTypeObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND ViewTypeOffline IS NOT NULL) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserTypeObjectName, NULL)
END ELSE IF @MachineName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ComputerObjectName)
END ELSE IF EXISTS(SELECT * FROM CIC_Offline_Machines WHERE MachineName=@MachineName) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MachineName AS varchar), @NameObjectName)
END ELSE IF @PublicKey IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @KeyObjectName, @ComputerObjectName)
END ELSE IF EXISTS(SELECT * FROM CIC_Offline_Machines WHERE MachineName=@MachineName) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MachineName AS varchar), @KeyObjectName)
END ELSE BEGIN

	DECLARE @MachineID int
	INSERT INTO CIC_Offline_Machines (
			MachineName, PublicKey, MemberID
		) VALUES (
			@MachineName, @PublicKey, @MemberID
		)
	SET @MachineID = SCOPE_IDENTITY()
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ComputerObjectName, @ErrMsg OUTPUT
	
	INSERT INTO CIC_SecurityLevel_Machine (SL_ID, MachineID) VALUES (@SL_ID, @MachineID)

END

RETURN @Error

SET NOCOUNT OFF














GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Offline_Machine_i] TO [cioc_login_role]
GO
