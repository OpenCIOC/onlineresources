SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_u_WWW_ADDRESS]
	@MemberID INT,
	@NUM VARCHAR(8),
	@MODIFIED_BY nvarchar(50),
	@WWW_ADDRESS_PROTOCOL VARCHAR(8),
	@WWW_ADDRESS NVARCHAR(255),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE	@Error	int
	SET @Error = 0
	
	DECLARE	@MemberObjectName nvarchar(100),
		@RecordObjectName NVARCHAR(100)
	SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
	SET @RecordObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
	
	-- Member ID given ?
	IF @MemberID IS NULL BEGIN
		SET @Error = 2 -- No ID Given
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
	-- Member ID exists ?
	END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	-- View given ?
	END ELSE IF @NUM IS NULL BEGIN
		SET @Error = 2 -- No ID Given
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RecordObjectName, NULL)
	-- View exists ?
	END ELSE IF NOT EXISTS (SELECT * FROM dbo.GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @RecordObjectName)
	-- View belongs to Member ?
	END ELSE IF @NUM IS NOT NULL AND NOT EXISTS (SELECT * FROM dbo.GBL_BaseTable WHERE MemberID=@MemberID AND NUM=@NUM) BEGIN
		SET @Error = 8 -- Security Failure
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RecordObjectName, NULL)
	END ELSE BEGIN
	
		UPDATE dbo.GBL_BaseTable_Description SET WWW_ADDRESS_PROTOCOL=@WWW_ADDRESS_PROTOCOL, WWW_ADDRESS=@WWW_ADDRESS, MODIFIED_BY=@MODIFIED_BY, MODIFIED_DATE=GETDATE()
		WHERE NUM=@NUM AND LangID=@@LANGID 
		
		DECLARE @MODIFIED_DATE SMALLDATETIME = GETDATE()
		EXEC dbo.sp_GBL_BaseTable_History_i @MODIFIED_BY=@MODIFIED_BY, @MODIFIED_DATE=@MODIFIED_DATE, @NUM=@NUM, @FieldList='WWW_ADDRESS,WWW_ADDRESS_PROTOCOL', @Names=1, @LangID=@@LANGID
	
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @RecordObjectName, @ErrMsg
	END
	RETURN @Error
	
	SET NOCOUNT OFF
END




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_u_WWW_ADDRESS] TO [cioc_login_role]
GO
