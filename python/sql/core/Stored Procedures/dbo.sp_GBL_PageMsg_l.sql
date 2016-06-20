SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PageMsg_l]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
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
END

SELECT pm.PageMsgID, pm.MsgTitle
	FROM GBL_PageMsg pm
	INNER JOIN STP_Language sl
		ON pm.LangID=sl.LangID
WHERE pm.MemberID=@MemberID
	AND sl.Active=1
ORDER BY pm.MsgTitle

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageMsg_l] TO [cioc_login_role]
GO
