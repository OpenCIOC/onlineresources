SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Users_APICreds_l]
	@MemberID int,
	@AgencyCode char(3),
	@User_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: CL
	Checked on: 15-May-2016
	Action: NO ACTION REQUIRED
*/

SELECT l.*
FROM GBL_Users_APICreds l
WHERE l.[User_ID]=@User_ID AND EXISTS(
	SELECT * FROM GBL_Users u WHERE l.User_ID=u.User_ID AND u.MemberID_Cache=@MemberID AND (@AgencyCode IS NULL OR u.Agency=@AgencyCode))

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_APICreds_l] TO [cioc_login_role]
GO
