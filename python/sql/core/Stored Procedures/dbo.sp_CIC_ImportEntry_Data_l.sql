SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Data_l]
	@ViewType int,
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 19-Dec-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

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

SELECT @Error AS Error, @ErrMsg AS ErrMsg

IF @Error=0 BEGIN
	SELECT	ied.ER_ID,
			ied.NUM,
			ied.EXTERNAL_ID,
			ied.IMPORTED,
			ied.OWNER + CASE WHEN bt.RECORD_OWNER IS NULL THEN '' WHEN bt.RECORD_OWNER=ied.OWNER THEN '' ELSE ' (' + bt.RECORD_OWNER + ')' END AS OWNER,
			dbo.fn_CIC_ImportEntry_Data_Languages(ied.ER_ID) AS LANGUAGES,
			CASE WHEN bt.NUM IS NULL
				THEN dbo.fn_GBL_DisplayFullOrgName_2(ied.NUM,
					DATA.value('/RECORD[1]/ORG_LEVEL_1[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/ORG_LEVEL_2[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/ORG_LEVEL_3[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/ORG_LEVEL_4[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/ORG_LEVEL_5[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/LOCATION_NAME[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/SERVICE_NAME_LEVEL_1[1]/@V','varchar(200)'),
					DATA.value('/RECORD[1]/SERVICE_NAME_LEVEL_2[1]/@V','varchar(200)'),
					1,1 -- TODO Should this come from the XML?
					)
				ELSE dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME)
				END AS ORG_NAME_FULL,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/ORG_LEVEL_2[1]/@V','varchar(200)')
				ELSE btd.ORG_LEVEL_2
				END AS ORG_LEVEL_2,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/ORG_LEVEL_3[1]/@V','varchar(200)')
				ELSE btd.ORG_LEVEL_3
				END AS ORG_LEVEL_3,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/ORG_LEVEL_4[1]/@V','varchar(200)')
				ELSE btd.ORG_LEVEL_4
				END AS ORG_LEVEL_4,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/ORG_LEVEL_5[1]/@V','varchar(200)')
				ELSE btd.ORG_LEVEL_5
				END AS ORG_LEVEL_5,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/SERVICE_NAME_LEVEL_1[1]/@V','varchar(200)')
				ELSE btd.SERVICE_NAME_LEVEL_1
				END AS SERVICE_NAME_LEVEL_1,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/SERVICE_NAME_LEVEL_2[1]/@V','varchar(200)')
				ELSE btd.SERVICE_NAME_LEVEL_2
				END AS SERVICE_NAME_LEVEL_2,
			CASE WHEN bt.NUM IS NULL
				THEN DATA.value('/RECORD[1]/LOCATION_NAME[1]/@V','varchar(200)')
				ELSE btd.LOCATION_NAME
				END AS LOCATION_NAME,
			CASE WHEN bt.NUM IS NULL THEN CAST(0 AS bit) ELSE dbo.fn_CIC_RecordInView(bt.NUM,@ViewType,@@LANGID,0,GETDATE()) END AS CAN_SEE,
			CAST(CASE WHEN bt.MemberID IS NULL THEN 1 WHEN bt.MemberID=@MemberID THEN 1 ELSE 0 END AS bit) AS CAN_IMPORT,
			bt.MemberID
		FROM CIC_ImportEntry_Data ied
		LEFT JOIN GBL_BaseTable bt
			ON ied.NUM=bt.NUM
		LEFT JOIN GBL_BaseTable_Description btd
			ON bt.NUM=btd.NUM
				AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE ied.EF_ID=@EF_ID
		AND ied.DATA IS NOT NULL
	ORDER BY ied.NUM
END

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Data_l] TO [cioc_login_role]
GO
