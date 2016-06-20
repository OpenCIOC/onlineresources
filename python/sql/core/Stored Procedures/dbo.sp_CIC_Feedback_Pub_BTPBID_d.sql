SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_Pub_BTPBID_d]
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

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @NUM varchar(8), 
		@PB_ID int
		
SELECT @NUM = pr.NUM, @PB_ID=pr.PB_ID 
	FROM CIC_BT_PB pr
WHERE BT_PB_ID=@BT_PB_ID

-- View given ?
IF @MemberID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 10 -- Required Field
-- Record in View ?
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
-- Publication in View ?
END ELSE IF @PB_ID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
END

IF @BT_PB_ID IS NOT NULL BEGIN
	DELETE CIC_Feedback_Publication
	WHERE BT_PB_ID=@BT_PB_ID
		AND (
			EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@NUM AND MemberID=@MemberID)
			OR EXISTS(SELECT * FROM GBL_FeedbackEntry fbe WHERE CIC_Feedback_Publication.FB_ID=fbe.FB_ID AND fbe.MemberID=@MemberID)
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
				AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanViewFeedback=1))
		)
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_Pub_BTPBID_d] TO [cioc_login_role]
GO
