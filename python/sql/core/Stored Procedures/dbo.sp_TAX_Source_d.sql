SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Source_d]
	@TAX_SRC_ID int,
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

DECLARE	@SourceObjectName nvarchar(60)

SET @SourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Source')

/* Identify errors that will prevent the record from being deleted */
IF @TAX_SRC_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SourceObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM TAX_Source WHERE TAX_SRC_ID = @TAX_SRC_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@TAX_SRC_ID AS varchar), @SourceObjectName)
END ELSE IF EXISTS(SELECT * FROM TAX_Term WHERE Source=@TAX_SRC_ID)
		OR EXISTS(SELECT * FROM TAX_Unused WHERE Source=@TAX_SRC_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SourceObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Taxonomy Term'))
END ELSE IF EXISTS(SELECT * FROM TAX_RelatedConcept WHERE Source=@TAX_SRC_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SourceObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Related Concept'))
/* No issues exist that prevent the deletion, so remove the Source entry */
END ELSE BEGIN
	DELETE TAX_Source
	WHERE (TAX_SRC_ID = @TAX_SRC_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Source_d] TO [cioc_login_role]
GO
