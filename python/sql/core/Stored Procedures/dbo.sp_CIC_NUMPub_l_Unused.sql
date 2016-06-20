SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMPub_l_Unused]
	@NUM varchar(8),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@CanSeeNonPublicPub bit

SELECT @MemberID=MemberID, @CanSeeNonPublicPub=CanSeeNonPublicPub
	FROM CIC_View
WHERE ViewType=@ViewType

SELECT pb.PB_ID, pb.PubCode, pb.NonPublic, pbn.Name AS PubName
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
WHERE NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE PB_ID=pb.PB_ID AND NUM=@NUM)
	AND (
		pb.MemberID=@MemberID
		OR (pb.MemberID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=pb.PB_ID AND pbi.MemberID=@MemberID))
	)
	AND (
		@CanSeeNonPublicPub=1
		OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=0)
		OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=pb.PB_ID))
	)
ORDER BY pb.PubCode

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMPub_l_Unused] TO [cioc_login_role]
GO
