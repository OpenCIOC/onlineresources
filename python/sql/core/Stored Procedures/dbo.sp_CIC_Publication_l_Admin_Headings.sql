SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Publication_l_Admin_Headings]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, Name AS PubName
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID AND (gh.Used=1 OR gh.Used IS NULL))
	AND (MemberID IS NULL OR MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
ORDER BY pb.PubCode

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Admin_Headings] TO [cioc_login_role]
GO
