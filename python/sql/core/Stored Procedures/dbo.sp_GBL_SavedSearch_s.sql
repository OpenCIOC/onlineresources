SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SavedSearch_s]
	@User_ID int,
	@SSRCH_ID [int],
	@Domain int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 25-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int

SELECT @MemberID=MemberID_Cache
	FROM GBL_Users u
WHERE u.User_ID=@User_ID

SELECT * 
	FROM GBL_SavedSearch ss
WHERE SSRCH_ID=@SSRCH_ID
	AND ss.User_ID=@User_ID
	AND Domain=@Domain

IF @Domain=1 BEGIN
	SELECT sl.SL_ID, sln.SecurityLevel, CASE WHEN ss.SL_ID IS NULL THEN 0 ELSE 1 END AS Shared
		FROM CIC_SecurityLevel sl
		INNER JOIN CIC_SecurityLevel_Name sln
			ON sl.SL_ID=sln.SL_ID AND sln.LangID=(SELECT TOP 1 LangID FROM CIC_SecurityLevel_Name WHERE SL_ID=sln.SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		LEFT JOIN (SELECT SL_ID FROM  CIC_SecurityLevel_SavedSearch WHERE SSRCH_ID=@SSRCH_ID) ss
			ON sl.SL_ID=ss.SL_ID
	WHERE sl.MemberID=@MemberID
	ORDER BY sln.SecurityLevel
END ELSE IF @Domain=2 BEGIN
	SELECT sl.SL_ID, sln.SecurityLevel, CASE WHEN ss.SL_ID IS NULL THEN 0 ELSE 1 END AS Shared
		FROM VOL_SecurityLevel sl
		INNER JOIN VOL_SecurityLevel_Name sln
			ON sl.SL_ID=sln.SL_ID AND sln.LangID=(SELECT TOP 1 LangID FROM VOL_SecurityLevel_Name WHERE SL_ID=sln.SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		LEFT JOIN (SELECT SL_ID FROM VOL_SecurityLevel_SavedSearch WHERE SSRCH_ID=@SSRCH_ID) ss
			ON sl.SL_ID=ss.SL_ID
	WHERE sl.MemberID=@MemberID
	ORDER BY sln.SecurityLevel
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SavedSearch_s] TO [cioc_login_role]
GO
