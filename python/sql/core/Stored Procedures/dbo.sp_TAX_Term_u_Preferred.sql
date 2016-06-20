SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_TAX_Term_u_Preferred]
	@MODIFIED_BY [varchar](50),
	@CodeList [nvarchar](max),
	@ResetList bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 03-Jul-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@TermObjectName nvarchar(100)

SET @TermObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Taxonomy Term')

DECLARE @CodeTable TABLE (
	Code varchar(21) NOT NULL PRIMARY KEY
)

INSERT INTO @CodeTable
SELECT DISTINCT tax.Code
	FROM dbo.fn_GBL_ParseVarCharIDList(@CodeList,',') tm
	INNER JOIN TAX_Term tax
		ON tm.ItemID=tax.Code COLLATE Latin1_General_100_CI_AI
			AND tax.CdLvl > 1

/* Identify errors that will prevent the record from being updated */
IF NOT EXISTS(SELECT * FROM @CodeTable) BEGIN
	SET @Error = 4
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TermObjectName, NULL)
END ELSE BEGIN
	UPDATE tm
		SET PreferredTerm	= 1,
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY
	FROM TAX_Term tm
	INNER JOIN @CodeTable ct
		ON tm.Code=ct.Code
	WHERE tm.PreferredTerm=0
	
	IF @ResetList=1 BEGIN
		UPDATE tm
			SET PreferredTerm	= 0,
				MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
		FROM TAX_Term tm
		WHERE tm.PreferredTerm=1
			AND NOT EXISTS(SELECT * FROM @CodeTable ct WHERE tm.Code=ct.Code)
	END
END

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_u_Preferred] TO [cioc_login_role]
GO
