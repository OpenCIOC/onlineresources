SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_d]
	@MemberID int,
	@Agency varchar(3),
	@IdList [varchar](max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Apr-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@OrganizationObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @OrganizationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')

SET @Agency = LTRIM(RTRIM(@Agency))
IF @Agency = '' SET @Agency = NULL

DECLARE	@tmpBTDIDs TABLE(
	BTD_ID int,
	NUM varchar(8) COLLATE Latin1_General_100_CI_AI,
	LangID int,
	OtherLangID bit DEFAULT (0) NOT NULL
)

INSERT INTO @tmpBTDIDs (
	BTD_ID,
	NUM,
	LangID
)
SELECT DISTINCT tm.ItemID, btd.NUM, btd.LangID
	FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
	INNER JOIN GBL_BaseTable_Description btd
		ON tm.ItemID = btd.BTD_ID

UPDATE tm
	SET OtherLangID = 1
FROM @tmpBTDIDs tm
WHERE EXISTS(SELECT * FROM GBL_BaseTable_Description btd
				WHERE btd.NUM = tm.NUM
				AND NOT EXISTS(SELECT * FROM @tmpBTDIDs tm2 WHERE tm2.NUM=btd.NUM AND tm2.LangID=btd.LangID)
			)

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- At least one valid record number given ?
END ELSE IF NOT EXISTS(SELECT * FROM @tmpBTDIDs) BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, NULL)
-- Records belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM GBL_BaseTable bt INNER JOIN @tmpBTDIDs tm ON bt.NUM=tm.NUM AND bt.MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Records belongs to Agency ?
END ELSE IF @Agency IS NOT NULL AND EXISTS(SELECT * FROM GBL_BaseTable bt INNER JOIN @tmpBTDIDs tm ON bt.NUM=tm.NUM AND bt.RECORD_OWNER<>@Agency) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
END ELSE IF EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN @tmpBTDIDs tm ON vo.NUM=tm.NUM AND tm.OtherLangID=0) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record'))
END ELSE IF EXISTS(SELECT * FROM VOL_Member vm INNER JOIN @tmpBTDIDs tm ON vm.NUM=tm.NUM AND tm.OtherLangID=0) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Centre Member'))
END ELSE IF EXISTS(SELECT * FROM GBL_Agency INNER JOIN @tmpBTDIDs tm ON NUM=AgencyNUMVOL OR NUM=AgencyNUMCIC AND tm.OtherLangID=0) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency'))
END ELSE IF EXISTS(SELECT * FROM GBL_BaseTable bt INNER JOIN @tmpBTDIDs tm ON bt.ORG_NUM=tm.NUM AND tm.OtherLangID=0) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Parent Agency'))
END ELSE IF EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE bt INNER JOIN @tmpBTDIDs tm ON bt.LOCATION_NUM=tm.NUM AND tm.OtherLangID=0) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Site'))
END ELSE BEGIN
	BEGIN TRAN DeleteBTTran

	DELETE tm
		FROM @tmpBTDIDs tm
		LEFT JOIN GBL_BaseTable_Description btd
			ON tm.BTD_ID=btd.BTD_ID
		WHERE btd.DELETION_DATE IS NULL
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg OUTPUT

	IF @Error = 0 BEGIN
		DELETE btd
			FROM GBL_BaseTable_Description btd
			INNER JOIN @tmpBTDIDs tm
				ON btd.BTD_ID=tm.BTD_ID
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg OUTPUT
	
	IF @Error <> 0 BEGIN
		ROLLBACK TRAN
	END ELSE BEGIN
		COMMIT TRAN DeleteBTTran
	END
END

IF EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.DISPLAY_ORG_NAME=1 AND NOT EXISTS(SELECT * FROM GBL_BaseTable obt WHERE obt.NUM=bt.ORG_NUM)) BEGIN
	UPDATE bt
		SET	DISPLAY_ORG_NAME = 0
	FROM GBL_BaseTable bt
	WHERE bt.DISPLAY_ORG_NAME = 1
		AND NOT EXISTS(SELECT * FROM GBL_BaseTable obt WHERE obt.NUM=bt.ORG_NUM)
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_d] TO [cioc_login_role]
GO
