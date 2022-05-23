SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_s_Staff]
	@MemberID int,
	@Email [varchar](100),
	@ProfileID uniqueidentifier,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(60),
		@VolunteerProfileObjectName	nvarchar(50)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')
	
IF @ProfileID IS NULL BEGIN
	SELECT @ProfileID=ProfileID FROM VOL_Profile WHERE Email=@Email AND MemberID=@MemberID
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL AND @Email IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 14 -- No Such Login
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, ISNULL(@Email,CAST(@ProfileID AS varchar(38))), NULL)
END ELSE BEGIN
	DECLARE @OrgCanContact bit
	SELECT @OrgCanContact=OrgCanContact FROM VOL_Profile WHERE ProfileID=@ProfileID

	IF @OrgCanContact=1 BEGIN
		SELECT	ProfileID,
				cioc_shared.dbo.fn_SHR_GBL_DateString(vp.CREATED_DATE) AS CREATED_DATE,
				cioc_shared.dbo.fn_SHR_GBL_DateString(vp.MODIFIED_DATE) AS MODIFIED_DATE,
				Active, Blocked, OrgCanContact, NotifyNew, NotifyUpdated,
				(SELECT COUNT(*) FROM VOL_OP_Referral rf WHERE rf.ProfileID=vp.ProfileID) AS REFERRAL_REQUESTS,
				FirstName, LastName, Email, Phone, Address, City, PostalCode, Province,
				cioc_shared.dbo.fn_SHR_GBL_DateString(vp.BirthDate) AS BirthDate,
				NotifyNew, NotifyUpdated
			FROM VOL_Profile vp
		WHERE vp.ProfileID=@ProfileID

		SELECT cmn.Name AS Community
			FROM VOL_Profile_CM vpc
			INNER JOIN GBL_Community cm
				ON vpc.CM_ID=cm.CM_ID
			INNER JOIN GBL_Community_Name cmn
				ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE vpc.ProfileID=@ProfileID
		ORDER BY cmn.Name

		SELECT CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName
			FROM VOL_Profile_AI pai
			INNER JOIN VOL_Interest ai
				ON pai.AI_ID=ai.AI_ID
			INNER JOIN VOL_Interest_Name ain
				ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM VOL_Interest_Name WHERE AI_ID=ain.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE pai.ProfileID=@ProfileID
		ORDER BY ain.Name
	END ELSE BEGIN
		SELECT	ProfileID,
				cioc_shared.dbo.fn_SHR_GBL_DateString(vp.CREATED_DATE) AS CREATED_DATE,
				cioc_shared.dbo.fn_SHR_GBL_DateString(vp.MODIFIED_DATE) AS MODIFIED_DATE,
				Active, Blocked, OrgCanContact, NotifyNew, NotifyUpdated,
				(SELECT COUNT(*) FROM VOL_OP_Referral rf WHERE rf.ProfileID=vp.ProfileID) AS REFERRAL_REQUESTS,
				CASE WHEN OrgCanContact=1 THEN FirstName ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(FirstName) END AS FirstName,
				CASE WHEN OrgCanContact=1 THEN LastName ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(LastName) END AS LastName,
				CASE WHEN OrgCanContact=1 THEN Email ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(Email) END AS Email
			FROM VOL_Profile vp
		WHERE vp.ProfileID=@ProfileID
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_s_Staff] TO [cioc_login_role]
GO
