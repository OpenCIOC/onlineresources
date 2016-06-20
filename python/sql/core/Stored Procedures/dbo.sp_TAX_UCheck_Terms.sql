SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UCheck_Terms]
	@NewTerms [varchar](max),
	@BadTerms [varchar](max) OUTPUT,
	@NewTCs [varchar](max) OUTPUT,
	@AllowInactive [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 09-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@tmpTerms TABLE (
	Term varchar(255) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY
)

/* Trim incoming data for all text-valued fields */
SET @NewTerms = RTRIM(LTRIM(@NewTerms))
IF @NewTerms = '' SET @NewTerms = NULL

/* If we have data to process... */
IF @NewTerms IS NOT NULL BEGIN

	/* Create a table of Names/Codes to process */
	INSERT INTO @tmpTerms
		SELECT DISTINCT ItemID
			FROM dbo.fn_GBL_ParseVarCharIDList(@NewTerms,';')
	SET @Error = @@ERROR

	IF @Error = 0 BEGIN
		/* Create a list of valid Terms */
		SELECT @NewTCs = COALESCE(@NewTCs + ',','') + 
			(SELECT TOP 1 tm.Code 
				FROM TAX_Term tm
				INNER JOIN TAX_Term_Description tmd
					ON tm.Code=tmd.Code
				WHERE (tm.Active=1 OR @AllowInactive=1)
					AND (tm.Code=tl.Term OR tmd.Term=tl.Term)
				ORDER BY CASE WHEN tm.Code=tl.Term THEN 0 ELSE 1 END,
					CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			FROM @tmpTerms tl 
		SET @Error = @@ERROR
	END

	IF @Error = 0 BEGIN
		/* Delete from the list of Terms to process the ones we have identified as valid */
		DELETE tl
			FROM @tmpTerms tl 
			WHERE EXISTS(SELECT * 
				FROM TAX_Term tm
				INNER JOIN TAX_Term_Description tmd
					ON tm.Code=tmd.Code
				WHERE (tm.Active=1 OR @AllowInactive=1)
					AND (tm.Code=tl.Term OR tmd.Term=tl.Term)
				)
		SET @Error = @@ERROR
	END

	IF @Error = 0 BEGIN
		/* Any Terms left in the list to process are not valid */
		SELECT @BadTerms = COALESCE(@BadTerms + ' ; ','') + tl.Term
			FROM @tmpTerms tl
		SET @Error = @@ERROR
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UCheck_Terms] TO [cioc_login_role]
GO
