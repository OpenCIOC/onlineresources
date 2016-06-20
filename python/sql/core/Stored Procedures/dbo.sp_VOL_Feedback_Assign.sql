SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Feedback_Assign]
	@IdList [varchar](max),
	@FEEDBACK_OWNER [varchar](3),
	@User_ID int,
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

DECLARE	@Error int
SET @Error = 0

DECLARE @MemberID int,
		@User_Agency char(3)

SELECT @MemberID=MemberID_Cache, @User_Agency=Agency FROM GBL_Users WHERE User_ID=@User_ID

DECLARE	@FeedbackObjectName nvarchar(100)
SET @FeedbackObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Feedback')

IF @IdList IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedbackObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Agency
		WHERE AgencyCode=@FEEDBACK_OWNER
			AND (RecordOwnerVOL=1 OR AgencyCode=@User_Agency)
			AND MemberID=@MemberID
		) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FEEDBACK_OWNER, cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency'))
END ELSE BEGIN
	UPDATE fb
		SET FEEDBACK_OWNER=@FEEDBACK_OWNER
	FROM VOL_Feedback fb
		INNER JOIN dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
			ON fb.FB_ID=tm.ItemID
	WHERE fb.MemberID=@MemberID AND fb.VNUM IS NULL
	SELECT @Error = @@ERROR
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FeedbackObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Feedback_Assign] TO [cioc_login_role]
GO
