SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Report_l]
	@ViewType int,
	@EF_ID INT
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
		@ErrMsg nvarchar(500),
		@IsIcarolImport bit

SET @Error = 0
SET @ErrMsg = NULL
SET @IsIcarolImport = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

-- View given ?
IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END

SELECT @IsIcarolImport = CASE WHEN SourceDbCode = 'ICAROL' THEN 1 ELSE 0 END FROM dbo.CIC_ImportEntry WHERE EF_ID=@EF_ID

SELECT @Error AS Error, @ErrMsg AS ErrMsg, @IsIcarolImport AS IsIcarolImport

IF @Error = 0 BEGIN

	SELECT	ied.ER_ID,
			ied.NUM,
			ied.EXTERNAL_ID,
			ied.OWNER,
			ied.REPORT,
			CAST(CASE WHEN DATA IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS CAN_RETRY,
			dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
			dbo.fn_CIC_RecordInView(bt.NUM,@ViewType,@@LANGID,0,GETDATE()) AS CAN_SEE,
			CAST(CASE WHEN DATA IS NOT NULL AND @IsIcarolImport=1 THEN 1 ELSE 0 END AS BIT) AS CAN_ICAROL_RESCHED
		FROM CIC_ImportEntry_Data ied
		LEFT JOIN GBL_BaseTable bt
			ON ied.NUM=bt.NUM
		LEFT JOIN GBL_BaseTable_Description btd
			ON bt.NUM=btd.NUM
				AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE ied.EF_ID=@EF_ID
		AND (ied.DATA IS NULL OR ied.IMPORTED=1)
	ORDER BY ied.NUM
END

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Report_l] TO [cioc_login_role]
GO
