SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_5]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/* Delete invalid Terms that are not in use */
DECLARE @DeleteTable TABLE (
	Code varchar(21) NOT NULL
)

INSERT INTO @DeleteTable
SELECT Code
	FROM dbo.TAX_Term tm
WHERE Authorized=1
	AND NOT EXISTS(SELECT * FROM dbo.TAX_U_Term utt WHERE utt.Code=tm.Code)
	AND NOT EXISTS(SELECT * FROM dbo.CIC_BT_TAX_TM tt WHERE tt.Code=tm.Code)
	AND NOT EXISTS(SELECT * FROM dbo.CIC_GeneralHeading_TAX_TM ghtm WHERE ghtm.Code=tm.Code)

DELETE sa
	FROM dbo.TAX_SeeAlso sa
WHERE EXISTS(SELECT * FROM @DeleteTable WHERE Code=sa.Code or Code=sa.SA_Code)

DELETE tm
	FROM dbo.TAX_Term tm
WHERE EXISTS(SELECT * FROM @DeleteTable WHERE Code=tm.Code)
	AND NOT EXISTS(SELECT * FROM dbo.TAX_Term tmx WHERE ParentCode=tm.Code AND NOT EXISTS(SELECT * FROM @DeleteTable WHERE Code=tmx.Code))

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_5] TO [cioc_login_role]
GO
