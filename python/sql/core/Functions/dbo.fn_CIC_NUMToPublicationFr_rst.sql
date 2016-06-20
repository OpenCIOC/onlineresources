SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToPublicationFr_rst](
	@MemberID int,
	@NUM varchar(8)
)
RETURNS @PubNames TABLE (
	[PB_ID] int NULL,
	[PubName] nvarchar(255) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @PubNames 
	SELECT pb.PB_ID, ISNULL(pbn.Name,pb.PubCode) AS PubName
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID = pb.PB_ID
			AND (MemberID IS NULL OR @MemberID IS NULL OR MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
WHERE NUM = @NUM
ORDER BY ISNULL(pbn.Name,pb.PubCode)

RETURN

END
GO
