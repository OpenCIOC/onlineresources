SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_Assign]
	@IdList varchar(max),
	@FEEDBACK_OWNER varchar(3),
	@User_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-May-2012
	Action: NO ACTION REQUIRED
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
			AND (RecordOwnerCIC=1 OR AgencyCode=@User_Agency)
			AND MemberID=@MemberID
		) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FEEDBACK_OWNER, cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency'))
END ELSE BEGIN
	UPDATE fbe
		SET FEEDBACK_OWNER=@FEEDBACK_OWNER
	FROM GBL_FeedbackEntry fbe
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
		ON fbe.FB_ID=tm.ItemID
	WHERE fbe.MemberID=@MemberID AND fbe.NUM IS NULL
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FeedbackObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_Assign] TO [cioc_login_role]
GO
