SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SavedSearch_sr]
	@SSRCH_ID int,
	@User_ID int,
	@Domain int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

IF @Domain=1 BEGIN
	SELECT SearchName, WhereClause, IncludeDeleted
	FROM GBL_SavedSearch
	WHERE SSRCH_ID=@SSRCH_ID
		AND LangID=@@LANGID
		AND Domain = @Domain
		AND (
			[User_ID]=@User_ID
			OR EXISTS(SELECT *
				FROM CIC_SecurityLevel_SavedSearch ss
				INNER JOIN GBL_Users u
					ON u.SL_ID_CIC=ss.SL_ID
				WHERE [User_ID]=@User_ID)
		)
END ELSE IF @Domain=2 BEGIN
	SELECT SearchName, WhereClause, IncludeDeleted
	FROM GBL_SavedSearch
	WHERE SSRCH_ID=@SSRCH_ID
		AND LangID=@@LANGID
		AND Domain = @Domain
		AND (
			[User_ID]=@User_ID
			OR EXISTS(SELECT *
				FROM VOL_SecurityLevel_SavedSearch ss
				INNER JOIN GBL_Users u ON
					u.SL_ID_VOL=ss.SL_ID
				WHERE [User_ID]=@User_ID)
		)
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SavedSearch_sr] TO [cioc_login_role]
GO
