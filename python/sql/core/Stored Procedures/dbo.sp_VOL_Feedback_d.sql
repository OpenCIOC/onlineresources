SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Feedback_d]
	@MemberID int,
	@FB_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@FeedbackObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @FeedbackObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Feedback')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Feedback ID given ?
END ELSE IF @FB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedbackObjectName, NULL)
-- Feedback ID exists ?
END ELSE IF NOT (EXISTS (SELECT * FROM VOL_Feedback WHERE FB_ID=@FB_ID)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FB_ID AS varchar), @FeedbackObjectName)
-- Feedback or Record belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Feedback fb WHERE FB_ID=@FB_ID AND MemberID=@MemberID
		OR EXISTS(SELECT * FROM VOL_Opportunity vo WHERE vo.VNUM=fb.VNUM AND vo.MemberID=@MemberID)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DELETE VOL_Feedback WHERE FB_ID = @FB_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FeedbackObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Feedback_d] TO [cioc_login_role]
GO
