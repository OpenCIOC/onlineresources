SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Offline_Machines_l]
	@MemberID int,
	@AgencyCode [char](3),
	@AllData bit = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT sl.SL_ID, SecurityLevel, CASE WHEN (@AgencyCode IS NULL OR sl.Owner IS NULL OR sl.Owner=@AgencyCode) THEN 1 ELSE 0 END AS CAN_ADD
	FROM CIC_SecurityLevel sl
	INNER JOIN CIC_SecurityLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND LangID=(SELECT TOP 1 LangID FROM CIC_SecurityLevel_Name WHERE sln.SL_ID=SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE sl.MemberID=@MemberID
	AND (@AgencyCode IS NULL OR sl.Owner IS NULL OR sl.Owner=@AgencyCode)
	AND sl.ViewTypeOffline IS NOT NULL
ORDER BY SecurityLevel

SELECT om.MachineID, om.MachineName,
	CASE WHEN @AllData = 1 THEN 
		(SELECT SL_ID 
			FROM CIC_SecurityLevel_Machine sl 
			WHERE om.MachineID=MachineID 
			ORDER BY (SELECT TOP 1 SecurityLevel a
						FROM CIC_SecurityLevel_Name 
						WHERE sl.SL_ID=SL_ID 
						ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) 
			FOR XML PATH(''), ROOT('LEVELS'),TYPE) ELSE NULL END AS SecurityLevels
	FROM CIC_Offline_Machines om
WHERE om.MemberID=@MemberID
ORDER BY MachineName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Offline_Machines_l] TO [cioc_login_role]
GO
