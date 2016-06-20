
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Transportation_l]
	@MemberID [int],
	@ShowHidden [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT trp.TRP_ID, trpn.Name AS TransportationType
	FROM VOL_Transportation trp
	INNER JOIN VOL_Transportation_Name trpn
		ON trp.TRP_ID=trpn.TRP_ID AND trpn.LangID=@@LANGID
WHERE (trp.MemberID IS NULL OR @MemberID IS NULL OR trp.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_Transportation_InactiveByMember WHERE TRP_ID=trp.TRP_ID AND MemberID=@MemberID)
	)
ORDER BY trp.DisplayOrder, trpn.Name

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Transportation_l] TO [cioc_login_role]
GO
