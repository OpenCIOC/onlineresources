SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Offline_Machines_u]
	@AgencyCode [char](3),
	@Data xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 10-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @DataTable TABLE (
	MachineID int,
	SL_ID int
)

DECLARE @MemberID int

SELECT @MemberID=MemberID FROM GBL_Agency WHERE AgencyCode=@AgencyCode

INSERT INTO @DataTable (MachineID, SL_ID)
SELECT DISTINCT N.value('@MachineID', 'int'), N.value('@SL_ID', 'int')
FROM @Data.nodes('Data/MachineSL') AS T(N)

DELETE dt FROM @DataTable dt
WHERE NOT EXISTS(SELECT * FROM CIC_Offline_Machines WHERE MachineID=dt.MachineID AND MemberID=@MemberID) 
	OR NOT EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=dt.SL_ID AND ViewTypeOffline IS NOT NULL)

MERGE INTO CIC_SecurityLevel_Machine dst
USING @DataTable src
ON src.MachineID=dst.MachineID AND src.SL_ID=dst.SL_ID
WHEN NOT MATCHED BY TARGET AND 
	EXISTS(SELECT * FROM CIC_SecurityLevel 
		WHERE src.SL_ID=SL_ID AND (Owner IS NULL OR @AgencyCode IS NULL OR @AgencyCode=Owner))
	THEN
		INSERT (MachineID, SL_ID)
			VALUES (src.MachineID, src.SL_ID)
		
WHEN NOT MATCHED BY SOURCE AND
	EXISTS(SELECT * FROM CIC_Offline_Machines WHERE MachineID=dst.MachineID AND MemberID=@MemberID)
	AND EXISTS(SELECT * FROM CIC_SecurityLevel 
		WHERE dst.SL_ID=SL_ID AND (Owner IS NULL OR @AgencyCode IS NULL OR @AgencyCode=Owner))
	THEN 
		DELETE
	;

RETURN 0

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Offline_Machines_u] TO [cioc_login_role]
GO
