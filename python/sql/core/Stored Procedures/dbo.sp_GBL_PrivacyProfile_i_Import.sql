SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrivacyProfile_i_Import]
	@MemberID int,
	@ER_ID int,
	@MODIFIED_BY varchar(50),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@ProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')

DECLARE @UsedNames nvarchar(max),
		@FieldNames varchar(max)
		
SELECT @FieldNames = FieldNames
	FROM CIC_ImportEntry_PrivacyProfile
WHERE ER_ID=@ER_ID

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ProfileName
	FROM CIC_ImportEntry_PrivacyProfile_Name nt
WHERE ER_ID=@ER_ID
	AND EXISTS(SELECT * FROM GBL_PrivacyProfile_Name WHERE ProfileName=nt.ProfileName AND LangID=nt.LangID)

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Import Entry Privacy Profile exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_ImportEntry_PrivacyProfile WHERE ER_ID=@ER_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ER_ID AS varchar), @ProfileObjectName)
-- Name(s) already exist?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @ProfileObjectName)
END ELSE BEGIN
	DECLARE @ProfileID int
	
	INSERT INTO GBL_PrivacyProfile (
		MemberID,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY
	)
	VALUES (
		@MemberID,
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY
	)
			
	SET @ProfileID = SCOPE_IDENTITY()
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT

	IF @ProfileID IS NOT NULL BEGIN
		INSERT INTO GBL_PrivacyProfile_Name
		SELECT @ProfileID, LangID, ProfileName
			FROM CIC_ImportEntry_PrivacyProfile_Name
		WHERE ER_ID=@ER_ID

		INSERT INTO GBL_PrivacyProfile_Fld (ProfileID, FieldID)
		SELECT DISTINCT @ProfileID AS ProfileID, FieldID
			FROM dbo.fn_GBL_ParseVarCharIDList(@FieldNames,',') tm
			INNER JOIN GBL_FieldOption fo
				ON tm.ItemID=fo.FieldName COLLATE Latin1_General_100_CI_AI
		WHERE fo.CanUsePrivacy=1
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrivacyProfile_i_Import] TO [cioc_login_role]
GO
