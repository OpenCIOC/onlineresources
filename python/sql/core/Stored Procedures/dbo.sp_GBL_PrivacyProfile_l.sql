SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrivacyProfile_l]
	@MemberID int,
	@OverrideID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT pp.ProfileID, ProfileName
	FROM GBL_PrivacyProfile pp
	INNER JOIN GBL_PrivacyProfile_Name ppn
		ON pp.ProfileID=ppn.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_PrivacyProfile_Name WHERE ppn.ProfileID=ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (MemberID=@MemberID OR pp.ProfileID=@OverrideID)
ORDER BY ProfileName

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrivacyProfile_l] TO [cioc_login_role]
GO
