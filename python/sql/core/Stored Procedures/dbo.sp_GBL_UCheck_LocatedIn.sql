
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_UCheck_LocatedIn]
	@LocatedIn nvarchar(200),
	@CM_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

SET @LocatedIn = RTRIM(LTRIM(@LocatedIn))
IF @LocatedIn = '' SET @LocatedIn = NULL

IF @LocatedIn IS NOT NULL BEGIN
	IF @CM_ID IS NULL BEGIN
		SELECT @CM_ID=cmn.CM_ID
			FROM GBL_Community_Name cmn
		WHERE cmn.Name=@LocatedIn AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	END ELSE BEGIN
		SELECT @CM_ID=CM_ID FROM GBL_Community WHERE CM_ID=@CM_ID
	END
	IF @CM_ID IS NULL
		SET @Error = 3 -- No Such Record
END
	
RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_GBL_UCheck_LocatedIn] TO [cioc_login_role]
GO
