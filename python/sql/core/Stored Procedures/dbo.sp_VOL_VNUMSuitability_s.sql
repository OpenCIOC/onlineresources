
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMSuitability_s]
	@MemberID int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT sb.SB_ID, CASE WHEN sbn.LangID=@@LANGID THEN sbn.Name ELSE '[' + sbn.Name + ']' END AS SuitableFor, 
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM VOL_Suitability sb
	INNER JOIN VOL_Suitability_Name sbn
		ON sb.SB_ID=sbn.SB_ID AND sbn.LangID=(SELECT TOP 1 LangID FROM VOL_Suitability_Name WHERE SB_ID=sbn.SB_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_SB pr
		ON sb.SB_ID=pr.SB_ID AND pr.VNUM=@VNUM
	LEFT JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_SB_ID IS NOT NULL
	OR sb.MemberID=vo.MemberID
	OR sb.MemberID=@MemberID
	OR (sb.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM VOL_Suitability_InactiveByMember WHERE SB_ID=sb.SB_ID AND MemberID=ISNULL(vo.MemberID, @MemberID))
	))
ORDER BY sb.DisplayOrder, sbn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSuitability_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSuitability_s] TO [cioc_vol_search_role]
GO
