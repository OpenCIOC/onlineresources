SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_sf] (
	@MemberID [int]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 03-Jun-2012
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

SELECT	*
FROM STP_Member
WHERE MemberID=@MemberID

SELECT	memd.*, Culture	
FROM STP_Member_Description memd
INNER JOIN STP_Language sln
	ON memd.LangID=sln.LangID AND sln.Active=1
WHERE memd.MemberID=@MemberID

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_sf] TO [cioc_login_role]
GO
