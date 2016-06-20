SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SavedSearch_l_Shared]
	@User_ID int,
	@Domain tinyint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @userSLID int

SELECT	@userSLID = CASE
			WHEN @Domain=1 THEN SL_ID_CIC 
			WHEN @Domain=2 THEN SL_ID_VOL
		END
	FROM GBL_Users u
WHERE User_ID=@User_ID

SELECT	u.UserName,
		ss.SSRCH_ID,
		ss.CREATED_DATE,
		ss.MODIFIED_DATE,
		ss.SearchName,
		ss.Notes
	FROM GBL_SavedSearch ss
	INNER JOIN GBL_Users u
		ON ss.User_ID=u.User_ID
WHERE Domain=@Domain
	AND LangID=@@LANGID
	AND (
		(@Domain=1 AND EXISTS(SELECT * FROM CIC_SecurityLevel_SavedSearch WHERE SSRCH_ID=ss.SSRCH_ID AND SL_ID=@userSLID))
		OR (@Domain=2 AND EXISTS(SELECT * FROM VOL_SecurityLevel_SavedSearch WHERE SSRCH_ID=ss.SSRCH_ID AND SL_ID=@userSLID))
	)
ORDER BY SearchName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SavedSearch_l_Shared] TO [cioc_login_role]
GO
