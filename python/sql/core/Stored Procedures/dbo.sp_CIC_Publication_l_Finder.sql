SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Publication_l_Finder]
	@MemberID int,
	@searchStr [varchar](100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT pb.PB_ID, pb.PubCode, pbn.Name, pb.NonPublic
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID
			AND pbn.LangID=(SELECT TOP 1 LangID FROM CIC_Publication_Name WHERE PB_ID=pb.PB_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (MemberID IS NULL OR MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
	AND (
		pb.PubCode LIKE '%' + @searchStr + '%'
		OR (pbn.Name IS NOT NULL AND pbn.Name LIKE '%' + @searchStr + '%')
	)
ORDER BY pb.PubCode

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Finder] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_l_Finder] TO [cioc_login_role]
GO
