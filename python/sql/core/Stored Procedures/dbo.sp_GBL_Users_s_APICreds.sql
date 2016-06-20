SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Users_s_APICreds]
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

SELECT u.UserName, u.User_ID, u.MemberID_Cache AS MemberID, u.Agency AS AgencyCode
FROM GBL_Users u
WHERE u.User_ID=@User_ID AND u.MemberID_Cache=@MemberID AND (@AgencyCode IS NULL OR u.Agency=@AgencyCode)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_APICreds] TO [cioc_login_role]
GO
