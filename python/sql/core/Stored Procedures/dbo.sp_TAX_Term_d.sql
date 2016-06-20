SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_d]
	@Code varchar(21),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@TaxonomyTermObjectName nvarchar(60)

SET @TaxonomyTermObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Taxonomy Term')

/* Identify errors that will prevent the record from being deleted */
IF @Code IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TaxonomyTermObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM TAX_Term WHERE Code = @Code) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @TaxonomyTermObjectName)
END ELSE IF EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=@Code)BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TaxonomyTermObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
/* No issues exist that prevent the deletion, so remove the Term entry */
END ELSE BEGIN
	DELETE sa
	FROM TAX_SeeAlso sa
		WHERE sa.Code=@Code
	DELETE TAX_Term
	WHERE (Code = @Code)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TaxonomyTermObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_d] TO [cioc_login_role]
GO
