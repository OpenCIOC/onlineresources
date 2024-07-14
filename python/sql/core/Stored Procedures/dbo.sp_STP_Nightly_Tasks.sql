SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_STP_Nightly_Tasks]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 22-Apr-2012
	Action:	NO ACTION REQUIRED
*/

EXEC sp_CIC_Stats_RSN_i_FromAccumulator
EXEC sp_CIC_Stats_RSN_u_Cache
EXEC sp_VOL_Stats_OPID_i_FromAccumulator
EXEC sp_VOL_Stats_OPID_u_Cache
EXEC sp_GBL_SharingProfile_Nightly

SET NOCOUNT OFF









GO

GRANT EXECUTE ON  [dbo].[sp_STP_Nightly_Tasks] TO [cioc_maintenance_role]
GO
