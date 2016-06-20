SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_d]
	@MemberID int,
	@Agency varchar(3),
	@IdList [varchar](max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@VolunteerOpportunityObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolunteerOpportunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')

SET @Agency = LTRIM(RTRIM(@Agency))
IF @Agency = '' SET @Agency = NULL

DECLARE	@tmpOPDIDs TABLE( 
	OPD_ID int,
	VNUM varchar(10) COLLATE Latin1_General_100_CI_AI,
	LangID int,
	OtherLangID bit DEFAULT (0) NOT NULL
)

INSERT INTO @tmpOPDIDs (
	OPD_ID,
	VNUM,
	LangID
)
 SELECT DISTINCT tm.ItemID, vod.VNUM, vod.LangID
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN VOL_Opportunity_Description vod 
		ON tm.ItemID = vod.OPD_ID
		
UPDATE tm
	SET OtherLangID = 1
FROM @tmpOPDIDs tm
WHERE EXISTS(SELECT * FROM VOL_Opportunity_Description vod
				WHERE vod.VNUM = tm.VNUM
				AND NOT EXISTS(SELECT * FROM @tmpOPDIDs tm2 WHERE tm2.VNUM=vod.VNUM AND tm2.LangID=vod.LangID)
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
END ELSE IF NOT EXISTS(SELECT * FROM @tmpOPDIDs) BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, NULL)
-- Records belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN @tmpOPDIDs tm ON vo.VNUM=tm.VNUM AND vo.MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Records belongs to Agency ?
END ELSE IF @Agency IS NOT NULL AND EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN @tmpOPDIDs tm ON vo.VNUM=tm.VNUM AND vo.RECORD_OWNER<>@Agency) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
END ELSE IF EXISTS(SELECT * FROM VOL_OP_Referral rf INNER JOIN @tmpOPDIDs tm ON rf.VNUM=tm.VNUM) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Referral'))
END ELSE BEGIN
	BEGIN TRAN DeleteBTTran
	
	DELETE tm
		FROM @tmpOPDIDs tm
		LEFT JOIN VOL_Opportunity_Description vod
			ON tm.OPD_ID=vod.OPD_ID
		WHERE vod.DELETION_DATE IS NULL
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerOpportunityObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
	DELETE vod
	FROM VOL_Opportunity_Description vod
	INNER JOIN @tmpOPDIDs tm
		ON vod.OPD_ID=tm.OPD_ID
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerOpportunityObjectName, @ErrMsg OUTPUT
	
	IF @Error <> 0 BEGIN
		ROLLBACK TRAN
	END ELSE BEGIN
		COMMIT TRAN DeleteBTTran
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_d] TO [cioc_login_role]
GO
