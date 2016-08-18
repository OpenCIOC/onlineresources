
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_VNUMSkill_s]
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

SELECT sk.SK_ID, CASE WHEN skn.LangID=@@LANGID THEN skn.Name ELSE '[' + skn.Name + ']' END AS Skill, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM VOL_Skill sk
	INNER JOIN VOL_Skill_Name skn
		ON sk.SK_ID=skn.SK_ID AND skn.LangID=(SELECT TOP 1 LangID FROM VOL_Skill_Name WHERE SK_ID=skn.SK_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_SK pr 
		ON sk.SK_ID = pr.SK_ID AND pr.VNUM=@VNUM
	LEFT JOIN VOL_OP_SK_Notes prn
		ON pr.OP_SK_ID=prn.OP_SK_ID AND prn.LangID=@@LANGID
	LEFT JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_SK_ID IS NOT NULL
	OR sk.MemberID=vo.MemberID
	OR sk.MemberID=@MemberID
	OR (sk.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM VOL_Skill_InactiveByMember WHERE SK_ID=sk.SK_ID AND MemberID=ISNULL(vo.MemberID,@MemberID))
	))
ORDER BY sk.DisplayOrder, skn.Name

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSkill_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSkill_s] TO [cioc_vol_search_role]
GO
