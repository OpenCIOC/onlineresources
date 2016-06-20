SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SavedSearch_l]
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

SELECT	ss.SSRCH_ID,
		ss.CREATED_DATE,
		ss.MODIFIED_DATE,
		ss.SearchName,
		ss.Notes,
		CASE
			WHEN @Domain=1 AND EXISTS(SELECT * FROM CIC_SecurityLevel_SavedSearch WHERE SSRCH_ID=ss.SSRCH_ID) THEN 1
			WHEN @Domain=2 AND EXISTS(SELECT * FROM VOL_SecurityLevel_SavedSearch WHERE SSRCH_ID=ss.SSRCH_ID) THEN 1
			ELSE 0
		END AS Shared
	FROM GBL_SavedSearch ss
WHERE User_ID=@User_ID
	AND Domain=@Domain
	AND LangID=@@LANGID
ORDER BY SearchName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SavedSearch_l] TO [cioc_login_role]
GO
