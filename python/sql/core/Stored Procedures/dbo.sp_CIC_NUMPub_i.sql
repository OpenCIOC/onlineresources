SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMPub_i]
	@MODIFIED_BY varchar(50),
	@NUM varchar(8),
	@PB_ID int,
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

DECLARE	@Error	int
SET @Error = 0

DECLARE	@OrganizationProgramObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@RecordNumberObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @RecordNumberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #')

DECLARE @MemberID int
		
SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

-- ID given ?
IF @PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- Publication exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_Publication pb WHERE pb.PB_ID = @PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
-- NUM given ?
END ELSE IF @NUM IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RecordNumberObjectName, NULL)
-- NUM exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=@NUM) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @RecordNumberObjectName)
-- View given ?
END ELSE IF @MemberID IS NULL BEGIN
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
	IF NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.NUM=@NUM) BEGIN
		INSERT INTO CIC_BaseTable (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			NUM
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@NUM
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	END
	IF NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE PB_ID=@PB_ID AND NUM=@NUM) BEGIN
		INSERT INTO CIC_BT_PB (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			NUM,
			PB_ID
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@NUM,
			@PB_ID
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMPub_i] TO [cioc_login_role]
GO
