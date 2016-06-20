SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_Pub_s]
	@PB_FB_ID int,
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 03-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@OrganizationProgramObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

DECLARE @MemberID int,
		@CanSeeNonPublicPub bit

SELECT @MemberID=MemberID, @CanSeeNonPublicPub=CanSeeNonPublicPub
	FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @NUM varchar(8), 
		@PB_ID int
		
SELECT @NUM = pr.NUM, @PB_ID=pr.PB_ID 
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Feedback_Publication fp
		ON pr.BT_PB_ID=fp.BT_PB_ID
WHERE fp.PB_FB_ID=@PB_FB_ID

-- ID given ?
IF @PB_FB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_Feedback_Publication WHERE PB_FB_ID=@PB_FB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_FB_ID AS varchar), @PublicationObjectName)
	SET @PB_FB_ID = NULL
-- Record in View ?
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @PB_FB_ID = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @PB_FB_ID = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
END

-- Errors
SELECT @Error AS Error, @ErrMsg AS ErrMsg

SELECT fbe.FB_ID AS FBID, 
	CASE WHEN fbe.FBKEY IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Not Specified')
		WHEN fbe.FBKEY=bt.FBKEY THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Match')
		ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Does Not Match')
		END AS FEEDBACK_KEY_MATCH,
	CASE WHEN u.User_ID IS NULL
		THEN ISNULL(fbe.SOURCE_NAME, '[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']')
		ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END AS SUBMITTED_BY, 
	CASE WHEN u.User_ID IS NULL THEN fbe.SOURCE_EMAIL ELSE u.Email END AS SUBMITTED_BY_EMAIL,
	sl.LanguageName,
	pb.PubCode, pfb.*, fbe.*,
	bt.NUM AS NUM_FB, 
	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB
FROM CIC_Feedback_Publication pfb
	INNER JOIN CIC_BT_PB pbr
		ON pfb.BT_PB_ID=pbr.BT_PB_ID
	INNER JOIN CIC_Publication pb
		ON pbr.PB_ID=pb.PB_ID
	INNER JOIN GBL_FeedbackEntry fbe
		ON pfb.FB_ID=fbe.FB_ID
	INNER JOIN STP_Language sl
		ON fbe.LangID=sl.LangID
	LEFT JOIN GBL_Users u
		ON fbe.User_ID=u.User_ID
	LEFT JOIN GBL_BaseTable bt
		ON fbe.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE PB_FB_ID=@PB_FB_ID

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_Pub_s] TO [cioc_login_role]
GO
