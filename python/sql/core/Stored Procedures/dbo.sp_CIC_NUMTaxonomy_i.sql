SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMTaxonomy_i]
	@MODIFIED_BY varchar(50),
	@NUM varchar(8),
	@CodeList varchar(max),
	@BT_TAX_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 09-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @CodeTable	TABLE (
	Code varchar(21) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY
)
DECLARE @CodeCount	int

/* Separate the list of Codes into a table of Terms,
   including only valid Codes that exist in TAX_Term */
INSERT INTO @CodeTable
	SELECT DISTINCT tm.Code
		FROM dbo.fn_GBL_ParseVarCharIDList(@CodeList,',') cl
		INNER JOIN TAX_Term tm
			ON cl.ItemID=tm.Code COLLATE Latin1_General_100_CI_AI
		WHERE tm.Active=1

/* Confirm that we have at least one valid Code in the list */
SELECT @CodeCount=COUNT(*) FROM @CodeTable

IF @CodeCount > 0 BEGIN
	/* Attempt to match the list with an existing link.
	   The match must be exact - all the given Terms, and no others. */
	SELECT @BT_TAX_ID=BT_TAX_ID
		FROM CIC_BT_TAX tl
	WHERE NUM=@NUM
		AND (SELECT COUNT(*)
			FROM CIC_BT_TAX_TM tlt
			INNER JOIN @CodeTable tm
				ON tlt.Code=tm.Code
			WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID) = @CodeCount
		AND NOT EXISTS(SELECT *
			FROM CIC_BT_TAX_TM tlt
			WHERE tlt.BT_TAX_ID=tl.BT_TAX_ID
				AND NOT EXISTS(SELECT * FROM @CodeTable tm WHERE tlt.Code=tm.Code))

	/* If we did not find a match, create a new link for the record and add the Term(s) to it */
	IF @BT_TAX_ID IS NULL BEGIN
		INSERT INTO CIC_BT_TAX (NUM) VALUES (@NUM)
		SELECT @BT_TAX_ID=SCOPE_IDENTITY() 
		INSERT INTO CIC_BT_TAX_TM (BT_TAX_ID, Code)
			SELECT @BT_TAX_ID, Code
				FROM @CodeTable
		UPDATE CIC_BaseTable SET
			TAX_MODIFIED_DATE = GETDATE(),
			TAX_MODIFIED_BY = @MODIFIED_BY
		WHERE NUM=@NUM
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMTaxonomy_i] TO [cioc_login_role]
GO
