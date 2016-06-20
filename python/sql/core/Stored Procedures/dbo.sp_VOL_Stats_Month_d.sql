SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats_Month_d]
	@MemberID int,
	@ToDate smalldatetime
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

IF @ToDate IS NOT NULL BEGIN
	DELETE FROM VOL_Stats_OPID
	WHERE MemberID=@MemberID
		AND AccessDate < @ToDate
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats_Month_d] TO [cioc_login_role]
GO
