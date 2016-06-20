SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_UCheck_NAICS]
	@NewCodes varchar(max),
	@BadCodes varchar(max) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE	@tmpNAICSCodes TABLE (
	Code varchar(20) COLLATE Latin1_General_100_CI_AI
)

SET @NewCodes = RTRIM(LTRIM(@NewCodes))
IF @NewCodes = '' SET @NewCodes = NULL

IF @NewCodes IS NOT NULL BEGIN
	INSERT INTO @tmpNAICSCodes SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@NewCodes,';')
	SET @Error = @@ERROR
	IF @Error = 0 BEGIN
		SELECT @BadCodes = COALESCE(@BadCodes + ' ; ','') + tm.Code
			FROM @tmpNAICSCodes tm LEFT JOIN NAICS nc ON tm.Code = nc.Code
		WHERE nc.Code IS NULL
		IF @BadCodes IS NOT NULL BEGIN
			SET @Error = -1
		END
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_UCheck_NAICS] TO [cioc_login_role]
GO
