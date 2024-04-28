SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_ls]
    @MemberID int,
    @VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @Error int;
SET @Error = 0;

-- Member ID given ?
IF @MemberID IS NULL BEGIN
    SET @Error = 10; -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS (SELECT  * FROM  dbo.STP_Member WHERE MemberID = @MemberID) BEGIN
    SET @Error = 3; -- No Such Record
END

SELECT
    rf.REF_ID,
    rf.ReferralDate,
    rf.VolunteerName,
    rf.VolunteerEmail,
	rf.VolunteerCity,
    rf.MODIFIED_DATE,
    rf.FollowUpFlag,
    rf.SuccessfulPlacement,
    l.LanguageName
FROM    dbo.VOL_OP_Referral rf
    INNER JOIN dbo.STP_Language l
        ON rf.LangID = l.LangID
WHERE   rf.MemberID = @MemberID AND rf.VNUM = @VNUM
ORDER BY rf.ReferralDate DESC;

RETURN @Error;

SET NOCOUNT OFF;


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_ls] TO [cioc_login_role]
GO
