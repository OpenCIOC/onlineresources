SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMInteractionLevel_s]
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

SELECT il.IL_ID, iln.LangID, CASE WHEN iln.LangID=@@LANGID THEN iln.Name ELSE '[' + iln.Name + ']' END AS InteractionLevel, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM dbo.VOL_InteractionLevel il
	INNER JOIN dbo.VOL_InteractionLevel_Name iln
		ON il.IL_ID=iln.IL_ID AND iln.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_InteractionLevel_Name WHERE IL_ID=iln.IL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.VOL_OP_IL pr 
		ON il.IL_ID = pr.IL_ID AND pr.VNUM=@VNUM
	LEFT JOIN dbo.VOL_OP_IL_Notes prn
		ON pr.OP_IL_ID = prn.OP_IL_ID AND prn.LangID=@@LANGID
	LEFT JOIN dbo.VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_IL_ID IS NOT NULL
	OR il.MemberID=vo.MemberID
	OR il.MemberID=@MemberID
	OR (il.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM dbo.VOL_InteractionLevel_InactiveByMember WHERE IL_ID=il.IL_ID AND MemberID=ISNULL(vo.MemberID,@MemberID))
	))
ORDER BY il.DisplayOrder, iln.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMInteractionLevel_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMInteractionLevel_s] TO [cioc_vol_search_role]
GO
