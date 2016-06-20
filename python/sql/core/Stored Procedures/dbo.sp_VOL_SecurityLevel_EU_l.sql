SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SecurityLevel_EU_l]
	@MemberID int,
	@User_ID [int],
	@Old_SL [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE	@SuperUser bit,
		@SuperUserGlobal bit,
		@AgencyCode char(3)

SELECT @SuperUser = SuperUser, @SuperUserGlobal=SuperUserGlobal, @AgencyCode=Agency
	FROM GBL_Users u
	INNER JOIN VOL_SecurityLevel cs
		ON u.SL_ID_VOL = cs.SL_ID
WHERE [User_ID]=@User_ID

SELECT sl.SL_ID, sln.SecurityLevel
	FROM VOL_SecurityLevel sl
	INNER JOIN VOL_SecurityLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND sln.LangID=(SELECT TOP 1 LangID FROM VOL_SecurityLevel_Name WHERE sln.SL_ID=SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE MemberID=@MemberID
	AND (@SuperUser=1 OR SuperUser=0 OR sl.SL_ID=@Old_SL)
	AND (@SuperUserGlobal = 1 OR SuperUserGlobal = 0 OR sl.SL_ID=@Old_SL)
	AND (Owner IS NULL OR Owner=@AgencyCode OR sl.SL_ID=@Old_SL)
ORDER BY SecurityLevel

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SecurityLevel_EU_l] TO [cioc_login_role]
GO
