SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_LoginCheck_Offline]
	@MemberID int,
	@MachineName nvarchar(500)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 21-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

SELECT om.MachineID, om.MachineName, om.PublicKey
	FROM CIC_Offline_Machines om
WHERE MachineName=@MachineName AND MemberID=@MemberID

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_LoginCheck_Offline] TO [cioc_login_role]
GO
