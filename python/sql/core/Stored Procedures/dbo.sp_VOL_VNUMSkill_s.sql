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

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT sk.SK_ID, skn.LangID, CASE WHEN skn.LangID=@@LANGID THEN skn.Name ELSE '[' + skn.Name + ']' END AS Skill, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM dbo.VOL_Skill sk
	INNER JOIN dbo.VOL_Skill_Name skn
		ON sk.SK_ID=skn.SK_ID AND skn.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Skill_Name WHERE SK_ID=skn.SK_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.VOL_OP_SK pr 
		ON sk.SK_ID = pr.SK_ID AND pr.VNUM=@VNUM
	LEFT JOIN dbo.VOL_OP_SK_Notes prn
		ON pr.OP_SK_ID=prn.OP_SK_ID AND prn.LangID=@@LANGID
	LEFT JOIN dbo.VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_SK_ID IS NOT NULL
	OR sk.MemberID=vo.MemberID
	OR sk.MemberID=@MemberID
	OR (sk.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM dbo.VOL_Skill_InactiveByMember WHERE SK_ID=sk.SK_ID AND MemberID=ISNULL(vo.MemberID,@MemberID))
	))
ORDER BY sk.DisplayOrder, skn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSkill_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSkill_s] TO [cioc_vol_search_role]
GO
