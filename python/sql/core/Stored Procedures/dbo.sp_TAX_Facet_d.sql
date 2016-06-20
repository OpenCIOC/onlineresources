SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Facet_d]
	@FC_ID int,
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

DECLARE	@FacetObjectName nvarchar(100)

SET @FacetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Facet')

/* Identify errors that will prevent the record from being deleted */
IF @FC_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FacetObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM TAX_Facet WHERE FC_ID = @FC_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FC_ID AS varchar), @FacetObjectName)
END ELSE IF EXISTS(SELECT * FROM TAX_Term WHERE Facet=@FC_ID)BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FacetObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Taxonomy Term'))
/* No issues exist that prevent the deletion, so remove the Facet entry */
END ELSE BEGIN
	DELETE TAX_Facet WHERE (FC_ID = @FC_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FacetObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Facet_d] TO [cioc_login_role]
GO
