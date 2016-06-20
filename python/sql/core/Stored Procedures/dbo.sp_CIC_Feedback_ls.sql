
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_ls]
	@NUM varchar(8),
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 28-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@OrganizationProgramObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')

DECLARE @MemberID int,
		@CanUpdateRecord int

SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

SET @CanUpdateRecord = dbo.fn_CIC_CanUpdateRecord(@NUM,@User_ID,@ViewType,@@LANGID,GETDATE())

-- ID given ?
IF @NUM IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
-- ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_BaseTable WHERE NUM=@NUM) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@NUM AS varchar), @OrganizationProgramObjectName)
	SET @NUM = NULL
-- Record in View ?
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
	SET @NUM = NULL
-- User can modify this record or View feedback ?
END ELSE IF NOT (
			@CanUpdateRecord<>0
			OR (
				EXISTS(SELECT * FROM CIC_SecurityLevel sl INNER JOIN GBL_Users u ON sl.SL_ID=u.SL_ID_CIC AND u.User_ID=@User_ID WHERE sl.FeedbackAlert=1)
				AND (
					EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.MemberID=@MemberID
						OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE bts.NUM=bt.NUM AND bts.ShareMemberID_Cache=@MemberID
							AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanViewFeedback=1)
							)
					OR EXISTS(SELECT * FROM GBL_FeedbackEntry fbe WHERE fbe.NUM=@NUM AND fbe.MemberID=@MemberID)
					)
				)
			)
		) BEGIN
	SET @NUM = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END

SET @NUM = ISNULL(@NUM,'')

SELECT @Error AS Error, @ErrMsg AS ErrMsg

SELECT	fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE	(CanUseFeedback = 1)

DECLARE @ExtraFieldSQL	nvarchar(max)

SELECT @ExtraFieldSQL = COALESCE(@ExtraFieldSQL + ', ','')
		+ '(SELECT [Value] FROM CIC_Feedback_Extra fbex WHERE fbex.FB_ID=fbe.FB_ID AND fbex.FieldName=''' + FieldName + ''') AS [' + FieldName + ']'
	FROM GBL_FieldOption fo
WHERE ExtraFieldType IN ('a','d','e','l','p','r','t','w')

IF @ExtraFieldSQL IS NOT NULL BEGIN
	SET @ExtraFieldSQL = @ExtraFieldSQL + ','
END ELSE BEGIN
	SET @ExtraFieldSQL = ''
END

SET @ExtraFieldSQL = 'SELECT fbe.FB_ID AS FBID,
	CASE WHEN fbe.FBKEY IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(''Not Specified'')
		WHEN fbe.FBKEY=bt.FBKEY THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(''Match'')
		ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(''Does Not Match'')
		END AS FEEDBACK_KEY_MATCH,
	CASE WHEN u.User_ID IS NULL
		THEN ISNULL(fbe.SOURCE_NAME, ''['' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''Unknown'') + '']'')
		ELSE u.FirstName + '' '' + u.LastName + '' ('' + u.Agency + '')'' END AS SUBMITTED_BY, 
	CASE WHEN u.User_ID IS NULL THEN fbe.SOURCE_EMAIL ELSE u.Email END AS SUBMITTED_BY_EMAIL,
	sl.LanguageName,
	fbe.*, fb.*, cfb.*, ccfb.*,' + @ExtraFieldSQL + '
	CASE WHEN bt.PRIVACY_PROFILE IS NOT NULL THEN 1 ELSE 0 END AS IS_PRIVATE,
	bt.NUM AS NUM_FB, 
	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB
FROM GBL_FeedbackEntry fbe
	LEFT JOIN GBL_Feedback fb
		ON fbe.FB_ID=fb.FB_ID
	LEFT JOIN CIC_Feedback cfb
		ON fbe.FB_ID=cfb.FB_ID
	LEFT JOIN CCR_Feedback ccfb
		ON fbe.FB_ID=ccfb.FB_ID
	LEFT JOIN GBL_Users u
		ON fbe.User_ID=u.User_ID
	LEFT JOIN GBL_BaseTable bt
		ON fbe.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN STP_Language sl
			ON fbe.LangID=sl.LangID
WHERE fbe.NUM=@NUM
	AND (
		fbe.MemberID=@MemberID
		OR bt.MemberID=@MemberID
		OR @CanUpdateRecord<>0
		OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE bts.NUM=bt.NUM AND bts.ShareMemberID_Cache=@MemberID
					AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanViewFeedback=1)
			)
	)
	AND (fb.FB_ID IS NOT NULL OR cfb.FB_ID IS NOT NULL OR ccfb.FB_ID IS NOT NULL)'

EXEC sp_executesql @ExtraFieldSQL, N'@NUM varchar(8), @MemberID int, @CanUpdateRecord int', @NUM, @MemberID, @CanUpdateRecord

SET NOCOUNT OFF









GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_ls] TO [cioc_login_role]
GO
