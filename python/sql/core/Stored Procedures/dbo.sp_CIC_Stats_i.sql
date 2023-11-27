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

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

IF @Error=0 BEGIN
	INSERT INTO dbo.CIC_Stats_RSN_Accumulator (
		MemberID,
		AccessDate,
		IPAddress,
		RSN,
		LangID,
		[User_ID],
		ViewType,
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
		@API,
		@NUM
	)
END

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_i] TO [cioc_login_role]
GO
