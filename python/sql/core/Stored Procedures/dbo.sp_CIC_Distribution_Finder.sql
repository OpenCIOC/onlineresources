
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Distribution_Finder]
	@MemberID int,
	@searchStr varchar(100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT dst.DistCode, dstn.Name, dst.DST_ID
	FROM CIC_Distribution dst
	LEFT JOIN CIC_Distribution_Name dstn
		ON dst.DST_ID=dstn.DST_ID
			AND dstn.LangID=(SELECT TOP 1 LangID FROM CIC_Distribution_Name WHERE DST_ID=dst.DST_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (dst.MemberID IS NULL OR dst.MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_Distribution_InactiveByMember WHERE DST_ID=dst.DST_ID AND MemberID=@MemberID)
	AND (
		dst.DistCode LIKE '%' + @searchStr + '%' OR 
		(dstn.Name IS NOT NULL AND dstn.Name LIKE '%' + @searchStr + '%')
	)
ORDER BY dst.DistCode

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Distribution_Finder] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Distribution_Finder] TO [cioc_login_role]
GO
