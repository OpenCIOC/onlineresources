SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToPublicationView](
	@NUM varchar(8),
	@ViewType int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
	Notes: IS THIS EVEN USED??
*/

DECLARE	@returnStr	varchar(max),
		@MemberID int,
		@CanSeeNonPublicPub bit,
		@UsePubNamesOnly bit

SELECT	@MemberID=MemberID,
		@CanSeeNonPublicPub=CanSeeNonPublicPub,
		@UsePubNamesOnly=UsePubNamesOnly
	FROM CIC_View
WHERE ViewType=@ViewType

IF @CanSeeNonPublicPub IS NULL BEGIN
	SELECT @returnStr =  COALESCE(@returnStr + ' ; ','')
			+ CASE WHEN @UsePubNamesOnly=0 THEN pb.PubCode ELSE ISNULL(pbn.Name,pb.PubCode) END
		FROM CIC_BT_PB pr
		INNER JOIN CIC_Publication pb
			ON pr.PB_ID=pb.PB_ID
				AND (MemberID IS NULL OR @MemberID IS NULL OR MemberID=@MemberID)
				AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
		LEFT JOIN CIC_Publication_Name pbn
			ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
		INNER JOIN CIC_View_QuickListPub qlp
			ON pb.PB_ID=qlp.PB_ID
	WHERE NUM=@NUM
		AND ViewType=@ViewType
	ORDER BY CASE WHEN @UsePubNamesOnly=0 THEN pb.PubCode ELSE ISNULL(pbn.Name,pb.PubCode) END
END ELSE BEGIN
	SELECT @returnStr =  COALESCE(@returnStr + ' ; ','')
			+ CASE WHEN @UsePubNamesOnly=0 THEN pb.PubCode ELSE ISNULL(pbn.Name,pb.PubCode) END
		FROM CIC_BT_PB pr
		INNER JOIN CIC_Publication pb
			ON pr.PB_ID=pb.PB_ID
				AND (MemberID IS NULL OR @MemberID IS NULL OR MemberID=@MemberID)
				AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
		LEFT JOIN CIC_Publication_Name pbn
			ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
	WHERE NUM=@NUM
	ORDER BY CASE WHEN @UsePubNamesOnly=0 THEN pb.PubCode ELSE ISNULL(pbn.Name,pb.PubCode) END
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
