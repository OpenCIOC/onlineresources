SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_InclusionPolicy_u]
	@InclusionPolicyID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@LangID smallint,
	@PolicyTitle nvarchar(50),
	@PolicyText nvarchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@InclusionPolicyObjectName nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @InclusionPolicyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Inclusion Policy')

SET @PolicyTitle = RTRIM(LTRIM(@PolicyTitle))
IF @PolicyTitle = '' SET @PolicyTitle = NULL
SET @PolicyText = RTRIM(LTRIM(@PolicyText))
IF @PolicyText = '' SET @PolicyText = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Inclusion Policy exists ?
END ELSE IF @InclusionPolicyID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_InclusionPolicy WHERE InclusionPolicyID=@InclusionPolicyID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@InclusionPolicyID AS varchar), @InclusionPolicyObjectName)
-- Inclusion Policy belongs to Member ?
END ELSE IF @InclusionPolicyID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_InclusionPolicy WHERE InclusionPolicyID=@InclusionPolicyID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Policy Title given ?
END ELSE IF @PolicyTitle IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'), @InclusionPolicyObjectName)
-- Policy Title is unique ?
END ELSE IF EXISTS (SELECT * FROM GBL_InclusionPolicy WHERE (@InclusionPolicyID IS NULL OR InclusionPolicyID<>@InclusionPolicyID) AND PolicyTitle=@PolicyTitle AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PolicyTitle, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'))
-- Policy content given ?
END ELSE IF @PolicyText IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Policy Content'), @InclusionPolicyObjectName)
-- Language given ?
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'), @InclusionPolicyObjectName)
-- Language exists ?
END ELSE IF @LangID IS NOT NULL AND NOT EXISTS (SELECT * FROM STP_Language WHERE LangID = @LangID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'))
END

IF @Error = 0 BEGIN
	IF @InclusionPolicyID IS NOT NULL BEGIN
		UPDATE GBL_InclusionPolicy
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			PolicyTitle		= @PolicyTitle,
			LangID			= @LangID,
			PolicyText		= @PolicyText
		WHERE (InclusionPolicyID = @InclusionPolicyID)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InclusionPolicyObjectName, @ErrMsg
	END ELSE BEGIN
		INSERT INTO GBL_InclusionPolicy (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			PolicyTitle,
			LangID,
			PolicyText
		) 
 		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@PolicyTitle,
			@LangID,
			@PolicyText
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InclusionPolicyObjectName, @ErrMsg
		SET @InclusionPolicyID = SCOPE_IDENTITY()
	END
END

RETURN @Error


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_InclusionPolicy_u] TO [cioc_login_role]
GO
