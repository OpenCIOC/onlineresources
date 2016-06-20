SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_l]
	@ViewType int,
	@HasHeadings bit,
	@UsedHeadings bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublicPub bit,
		@UsePubNamesOnly bit
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublicPub=CanSeeNonPublicPub,
		@UsePubNamesOnly=UsePubNamesOnly
FROM CIC_View
WHERE ViewType=@ViewType

SELECT pb.PB_ID, pb.NonPublic, pb.PubCode, 
	CASE
		WHEN @UsePubNamesOnly=1 THEN ISNULL(pbn.Name, pb.PubCode)
		ELSE Name
	END AS PubName
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE (
		@CanSeeNonPublicPub=1
		OR (@CanSeeNonPublicPub=0 AND NonPublic=0)
		OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub qlp WHERE ViewType=@ViewType AND qlp.PB_ID=pb.PB_ID))
		)
	AND (@HasHeadings = 0 OR EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID AND (@UsedHeadings=0 OR Used=1 OR (@UsedHeadings IS NULL AND (Used=1 OR Used IS NULL)))))
	AND (MemberID IS NULL OR MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
ORDER BY CASE WHEN @UsePubNamesOnly=1 THEN ISNULL(pbn.Name, pb.PubCode) ELSE pb.PubCode END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l] TO [cioc_login_role]
GO
