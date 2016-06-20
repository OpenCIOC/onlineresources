SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Interest_u_Hide]
	@MemberID [int],
	@IDList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 19-Feb-2015
	Action: NO ACTION REQUIRED
*/

MERGE INTO VOL_Interest_InactiveByMember chk
USING (SELECT DISTINCT ItemID AS AI_ID FROM
		dbo.fn_GBL_ParseIntIDList(@IDList, ',') nt
		INNER JOIN VOL_Interest c
			ON c.AI_ID=nt.ItemID) nt
ON nt.AI_ID=chk.AI_ID AND chk.MemberID=@MemberID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (AI_ID, MemberID) VALUES (nt.AI_ID, @MemberID)
WHEN NOT MATCHED BY SOURCE AND chk.MemberID=@MemberID AND 
	NOT EXISTS(SELECT * FROM VOL_OP_AI voai INNER JOIN VOL_Opportunity vo ON vo.VNUM = voai.VNUM WHERE vo.MemberID=@MemberID AND chk.AI_ID=voai.AI_ID) THEN
	DELETE
	;

RETURN 0

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_u_Hide] TO [cioc_login_role]
GO
