SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Stats_i]
	@MemberID int,
	@AccessDate datetime,
	@IPAddress varchar(20),
	@RSN int,
	@User_ID int,
	@ViewType int,
	@API bit = 0,
	@NUM varchar(8) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

IF @Error=0 BEGIN
	INSERT INTO CIC_Stats_RSN_Accumulator (
		MemberID,
		AccessDate,
		IPAddress,
		RSN,
		LangID,
		[User_ID],
		ViewType,
		RobotID,
		API,
		NUM
	) 
	 
	VALUES (
		@MemberID,
		@AccessDate,
		@IPAddress,
		@RSN,
		@@LANGID,
		@User_ID,
		@ViewType,
		(SELECT TOP 1 RobotID FROM GBL_Robot_IPPattern WHERE @IPAddress LIKE IPPattern),
		@API,
		@NUM
	)
END

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_i] TO [cioc_login_role]
GO
