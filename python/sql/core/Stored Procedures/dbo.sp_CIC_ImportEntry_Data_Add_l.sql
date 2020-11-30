SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Data_Add_l]
	@MemberID int,
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@MemberObjectName	nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

IF @Error=0 BEGIN
	SELECT	ied.ER_ID,
			ied.NUM,
			ied.EXTERNAL_ID,
			ied.OWNER,
			dbo.fn_CIC_ImportEntry_Data_Languages(ied.ER_ID) AS LANGUAGES,
			dbo.fn_GBL_DisplayFullOrgName_2(ied.NUM,
				DATA.value('/RECORD[1]/ORG_LEVEL_1[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/ORG_LEVEL_2[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/ORG_LEVEL_3[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/ORG_LEVEL_4[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/ORG_LEVEL_5[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/LOCATION_NAME[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/SERVICE_NAME_LEVEL_1[1]/@V','varchar(200)'),
				DATA.value('/RECORD[1]/SERVICE_NAME_LEVEL_2[1]/@V','varchar(200)'),
				1, 1 -- TODO Should this come from the XML?
				) AS ORG_NAME_FULL,
			CAST(0 AS bit) AS CAN_SEE,
			CAST(1 AS bit) AS CAN_IMPORT,
			IMPORTED
		FROM CIC_ImportEntry_Data ied
	WHERE ied.EF_ID=@EF_ID
		AND ied.DATA IS NOT NULL
		AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)
	ORDER BY ied.NUM
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Data_Add_l] TO [cioc_login_role]
GO
