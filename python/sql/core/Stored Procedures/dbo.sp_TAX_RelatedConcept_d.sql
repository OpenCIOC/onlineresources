SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_RelatedConcept_d]
	@RC_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@RelatedConceptObjectName nvarchar(60)

SET @RelatedConceptObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Related Concept')

/* Identify errors that will prevent the record from being deleted */
IF @RC_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RelatedConceptObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM TAX_RelatedConcept WHERE RC_ID = @RC_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@RC_ID AS varchar), @RelatedConceptObjectName)
/* No issues exist that prevent the deletion, so remove the Concept entry */
END ELSE BEGIN
	DELETE TAX_RelatedConcept
	WHERE (RC_ID = @RC_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @RelatedConceptObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_RelatedConcept_d] TO [cioc_login_role]
GO
