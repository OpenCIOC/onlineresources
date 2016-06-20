SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_Pub_l]
	@BT_PB_ID int,
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int

SET @Error = 0

DECLARE @MemberID int,
		@CanSeeNonPublicPub bit

SELECT @MemberID=MemberID, @CanSeeNonPublicPub=CanSeeNonPublicPub
	FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @NUM varchar(8), 
		@PB_ID int
		
SELECT @NUM = pr.NUM, @PB_ID=pr.PB_ID 
	FROM CIC_BT_PB pr 
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID=pb.PB_ID
WHERE BT_PB_ID=@BT_PB_ID

-- ID given ?
IF @BT_PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE BT_PB_ID=@BT_PB_ID) BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
-- View given ?
END ELSE IF @MemberID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
-- Publication in View ?
END ELSE IF @PB_ID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
END

SELECT 'SUBMITTED_BY' = CASE WHEN u.User_ID IS NULL
		THEN ISNULL(fbe.SOURCE_NAME, '[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']')
		ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, 
	'SUBMITTED_BY_EMAIL' = CASE WHEN u.User_ID IS NULL THEN fbe.SOURCE_EMAIL ELSE u.Email END,
	sl.LanguageName,
	fbe.LangID,
	pfb.[Description],
	pfb.GeneralHeadings,
	pb.PubCode
	FROM CIC_Feedback_Publication pfb
	INNER JOIN CIC_BT_PB pbr
		ON pfb.BT_PB_ID=pbr.BT_PB_ID
	INNER JOIN CIC_Publication pb
		ON pbr.PB_ID=pb.PB_ID
	INNER JOIN GBL_FeedbackEntry fbe
		ON pfb.FB_ID=fbe.FB_ID
	LEFT OUTER JOIN GBL_Users u
		ON fbe.User_ID=u.User_ID
	INNER JOIN STP_Language sl
			ON fbe.LangID=sl.LangID
WHERE pbr.BT_PB_ID=@BT_PB_ID
	AND (
			EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@NUM AND MemberID=@MemberID)
			OR fbe.MemberID=@MemberID
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
				AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanViewFeedback=1))
		)
		
RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_Pub_l] TO [cioc_login_role]
GO
