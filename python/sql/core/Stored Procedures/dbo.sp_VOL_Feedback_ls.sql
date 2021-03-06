
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Feedback_ls]
	@VNUM varchar(10),
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@VolunteerOpportunityObjectName nvarchar(100)

SET @VolunteerOpportunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record')

DECLARE @MemberID int,
		@CanUpdateRecord int

SELECT @MemberID=MemberID
	FROM VOL_View
WHERE ViewType=@ViewType

SET @CanUpdateRecord = dbo.fn_VOL_CanUpdateRecord(@VNUM,@User_ID,@ViewType,@@LANGID,GETDATE())

-- ID given ?
IF @VNUM IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, NULL)
-- ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_Opportunity WHERE VNUM=@VNUM) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VNUM AS varchar), @VolunteerOpportunityObjectName)
	SET @VNUM = NULL
-- Record in View ?
END ELSE IF NOT dbo.fn_VOL_RecordInView(@VNUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, NULL)
	SET @VNUM = NULL
-- User can modify this record or View feedback ?
END ELSE IF NOT (
			@CanUpdateRecord<>0
			OR (
				EXISTS(SELECT * FROM VOL_SecurityLevel sl INNER JOIN GBL_Users u ON sl.SL_ID=u.SL_ID_CIC AND u.User_ID=@User_ID WHERE sl.FeedbackAlert=1)
				AND (
					EXISTS(SELECT * FROM VOL_Opportunity vo WHERE vo.MemberID=@MemberID
						OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos WHERE vos.VNUM=vo.VNUM AND vos.ShareMemberID_Cache=@MemberID
							AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=vos.ProfileID AND shp.CanViewFeedback=1)
							)
					OR EXISTS(SELECT * FROM VOL_Feedback fb WHERE fb.VNUM=@VNUM AND fb.MemberID=@MemberID)
					)
				)
			)
		) BEGIN
	SET @VNUM = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, NULL)
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

SELECT	fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE	(CanUseFeedback = 1)

DECLARE @ExtraFieldSQL	nvarchar(max)

SELECT @ExtraFieldSQL = COALESCE(@ExtraFieldSQL + ', ','')
		+ '(SELECT [Value] FROM VOL_Feedback_Extra fbex WHERE fbex.FB_ID=fb.FB_ID AND fbex.FieldName=''' + FieldName + ''') AS [' + FieldName + ']'
	FROM VOL_FieldOption fo
WHERE ExtraFieldType IN ('a','d','e','l','p','r','t','w')

IF @ExtraFieldSQL IS NOT NULL BEGIN
	SET @ExtraFieldSQL = @ExtraFieldSQL + ','
END ELSE BEGIN
	SET @ExtraFieldSQL = ''
END


SET @ExtraFieldSQL = 'SELECT fb.FB_ID,
	CASE WHEN fb.FBKEY IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(''NOT Specified'')
		WHEN fb.FBKEY=vo.FBKEY THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(''MATCH'')
		ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(''Does NOT MATCH'')
		END AS FEEDBACK_KEY_MATCH,
	CASE WHEN u.User_ID IS NULL
		THEN ISNULL(fb.SOURCE_NAME, ''['' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''Unknown'') + '']'')
		ELSE u.FirstName + '' '' + u.LastName + '' ('' + u.Agency + '')'' END AS SUBMITTED_BY, 
	CASE WHEN u.User_ID IS NULL THEN fb.SOURCE_EMAIL ELSE u.Email END AS SUBMITTED_BY_EMAIL,
	sl.LanguageName,
	fb.*,' + @ExtraFieldSQL + '
	vo.VNUM AS VNUM_FB,
	vod.POSITION_TITLE AS POSITION_TITLE_FB,
	bt.NUM AS NUM_FB, 
	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB
	FROM VOL_Feedback fb
	LEFT JOIN GBL_Users u
		ON fb.User_ID=u.User_ID
	LEFT JOIN VOL_Opportunity vo
		ON fb.VNUM=vo.VNUM
	LEFT JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)
	LEFT JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)
	INNER JOIN STP_Language sl
			ON fb.LangID=sl.LangID
WHERE fb.VNUM=@VNUM
	AND (
		fb.MemberID=@MemberID
		OR vo.MemberID=@MemberID
		OR @CanUpdateRecord<>1
		OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos WHERE vos.VNUM=vo.VNUM AND vos.ShareMemberID_Cache=@MemberID
					AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=vos.ProfileID AND shp.CanViewFeedback=1)
			)
	)
'

EXEC sp_executesql @ExtraFieldSQL, N'@VNUM varchar(10), @MemberID int, @CanUpdateRecord int', @VNUM, @MemberID, @CanUpdateRecord

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Feedback_ls] TO [cioc_login_role]
GO
