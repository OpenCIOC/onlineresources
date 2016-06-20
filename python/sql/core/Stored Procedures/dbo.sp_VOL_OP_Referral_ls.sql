SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_ls]
	@MemberID int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT REF_ID, ReferralDate, 
		VolunteerName, VolunteerEmail, 
		MODIFIED_DATE, 
		FollowUpFlag, SuccessfulPlacement,
		l.LanguageName
	FROM VOL_OP_Referral rf
	INNER JOIN STP_Language l
		ON rf.LangID=l.LangID
WHERE rf.MemberID=@MemberID
	AND rf.VNUM=@VNUM
ORDER BY ReferralDate DESC

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_ls] TO [cioc_login_role]
GO
