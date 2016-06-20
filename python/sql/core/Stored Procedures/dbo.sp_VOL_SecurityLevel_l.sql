SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SecurityLevel_l]
	@MemberID int,
	@AgencyCode char(3),
	@OverrideIdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
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

SELECT sl.SL_ID, sl.Owner, SecurityLevel
	FROM VOL_SecurityLevel sl
	INNER JOIN VOL_SecurityLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND sln.LangID=(SELECT TOP 1 LangID FROM VOL_SecurityLevel_Name WHERE sln.SL_ID=SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.fn_GBL_ParseIntIDList(@OverrideIdList,',') tm
		ON sl.SL_ID=tm.ItemID
WHERE sl.MemberID=@MemberID
	AND (
		@AgencyCode IS NULL
		OR sl.Owner IS NULL
		OR sl.Owner=@AgencyCode
		OR tm.ItemID IS NOT NULL
	)
ORDER BY SecurityLevel

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SecurityLevel_l] TO [cioc_login_role]
GO
