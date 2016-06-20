SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_Pub_d]
	@PB_FB_ID int,
	@User_ID int,
	@ViewType int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

DECLARE	@FeedbackObjectName nvarchar(100)

SET @FeedbackObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Feedback')

DECLARE @MemberID int,
		@CanSeeNonPublicPub bit

SELECT @MemberID=MemberID
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
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedbackObjectName, NULL)
-- ID exists ?
END ELSE IF @PB_ID IS NULL OR NOT EXISTS (SELECT * FROM CIC_Feedback_Publication WHERE PB_FB_ID=@PB_FB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_FB_ID AS varchar), @FeedbackObjectName)
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @PB_FB_ID = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedbackObjectName, NULL)
END ELSE BEGIN
	DELETE CIC_Feedback_Publication WHERE PB_FB_ID=@PB_FB_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FeedbackObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_Pub_d] TO [cioc_login_role]
GO
