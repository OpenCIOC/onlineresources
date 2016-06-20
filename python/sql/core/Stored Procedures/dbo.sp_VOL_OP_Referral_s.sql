SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_s]
	@MemberID int,
	@REF_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Referral ID given ?
END ELSE IF @REF_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Referral ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_OP_Referral WHERE REF_ID=@REF_ID) BEGIN
	SET @Error = 3 -- No Such Record
-- Referral ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_OP_Referral WHERE REF_ID=@REF_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT rf.*, l.LanguageName
	FROM VOL_OP_Referral rf
	INNER JOIN STP_Language l
		ON rf.LangID=l.LangID
WHERE rf.MemberID=@MemberID
	AND rf.REF_ID=@REF_ID

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_s] TO [cioc_login_role]
GO
