SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMPub_d]
	@BT_PB_ID int,
	@User_ID int,
	@ViewType int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@OrganizationProgramObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @NUM varchar(8), 
		@PB_ID int
		
SELECT @NUM = pr.NUM, @PB_ID=pr.PB_ID 
FROM CIC_BT_PB pr 
WHERE BT_PB_ID=@BT_PB_ID

-- ID given ?
IF @BT_PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE BT_PB_ID=@BT_PB_ID) BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @PublicationObjectName)
-- View given ?
END ELSE IF @MemberID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- Record in View ?
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END ELSE BEGIN
	DELETE CIC_BT_PB
	WHERE (BT_PB_ID = @BT_PB_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMPub_d] TO [cioc_login_role]
GO
