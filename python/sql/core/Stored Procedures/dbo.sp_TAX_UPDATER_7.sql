SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_7]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/* Delete invalid "See Also" references */
DELETE sa
	FROM dbo.TAX_SeeAlso sa
WHERE Authorized=1
	AND NOT EXISTS(SELECT * FROM dbo.TAX_U_SeeAlso WHERE Code=sa.Code AND SA_Code=sa.SA_Code)


/* Insert new "See Also" references */
INSERT INTO dbo.TAX_SeeAlso (CREATED_BY,MODIFIED_BY,Code,SA_Code,Authorized)
SELECT '(Import)','(Import)',Code,SA_Code,1
	FROM dbo.TAX_U_SeeAlso usa
WHERE NOT EXISTS(SELECT * FROM dbo.TAX_SeeAlso WHERE Code=usa.Code AND SA_Code=usa.SA_Code)


/* Update Authorization status of "See Also" references */
UPDATE sa
	SET Authorized		= 1,
		MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= '(Import)'
FROM dbo.TAX_SeeAlso sa
WHERE Authorized=0
AND EXISTS(SELECT * FROM dbo.TAX_U_SeeAlso usa WHERE Code=sa.Code AND SA_Code=sa.SA_Code)

SET NOCOUNT OFF

END

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_7] TO [cioc_login_role]
GO
