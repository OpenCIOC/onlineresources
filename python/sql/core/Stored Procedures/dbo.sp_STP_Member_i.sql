SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_i]
	@MODIFIED_BY [varchar](50),
	@DatabaseCode [varchar](15),
	@MemberName [nvarchar](255),
	@MemberNameCIC [nvarchar](255),
	@MemberNameVOL [nvarchar](255),
	@UseCIC [bit],
	@UseVOL [bit],
	@MemberID [int] OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2011
	Action:	NO ACTION REQUIRED
	Notes: Should create input for Base URL, default LangID, default agency code; should auto-generate a security level and account and create an entry in gbl_view_domainmap.
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

DECLARE @DefaultTemplate int,
		@DefaultViewCIC int,
		@DefaultViewVOL int

SET @UseCIC = ISNULL(@UseCIC,0)
SET @UseVOL = ISNULL(@UseVOL,0)
	
IF @UseCIC=0 AND @UseVOL=0 BEGIN
	SET @UseCIC=1
END

EXEC @Error = sp_GBL_Template_Default_Check @DefaultTemplate OUTPUT, @ErrMsg OUTPUT

IF EXISTS(SELECT * FROM STP_Member WHERE DatabaseCode=@DatabaseCode) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DatabaseCode, cioc_shared.dbo.fn_SHR_STP_ObjectName('Code'))
END ELSE IF EXISTS(SELECT * FROM STP_Member_Description WHERE MemberName=@MemberName) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
END

IF @Error = 0 BEGIN
	INSERT INTO STP_Member (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		DatabaseCode,
		DefaultTemplate,
		BaseURLCIC,
		BaseURLVOL,
		UseCIC,
		UseVOL
	) VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@DatabaseCode,
		@DefaultTemplate,
		'localhost',
		'localhost',
		@UseCIC,
		@UseVOL
	)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MemberObjectName, @ErrMsg
	SELECT @MemberID = SCOPE_IDENTITY()
	
	IF @MemberID IS NOT NULL BEGIN
		INSERT INTO STP_Member_Description (
			MemberID,
			LangID,
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberName,
			MemberNameCIC,
			MemberNameVOL
		) VALUES (
			@MemberID,
			0,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberName,
			CASE WHEN @UseCIC=1 THEN ISNULL(@MemberNameCIC,@MemberName) ELSE NULL END,
			CASE WHEN @UseVOL=1 THEN ISNULL(@MemberNameVOL,@MemberName) ELSE NULL END
		)
	END ELSE BEGIN
		SET @Error = 1 -- Unknown Error
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
	END
END

IF @Error = 0 BEGIN
	EXEC sp_CIC_View_i @MODIFIED_BY, @MemberID, 'Default', @DefaultViewCIC OUTPUT, @ErrMsg OUTPUT
	IF @UseVOL=1 BEGIN
		EXEC sp_VOL_View_i @MODIFIED_BY, @MemberID, 'Default', @DefaultViewVOL OUTPUT, @ErrMsg OUTPUT
	END
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MemberObjectName, @ErrMsg
END

IF @Error = 0 BEGIN
	UPDATE STP_Member
	SET DefaultViewCIC = @DefaultViewCIC,
		DefaultViewVOL = @DefaultViewVOL
	WHERE MemberID= @MemberID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MemberObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_i] TO [cioc_login_role]
GO
