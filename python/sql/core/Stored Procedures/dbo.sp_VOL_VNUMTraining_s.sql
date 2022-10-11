SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMTraining_s]
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

SELECT trn.TRN_ID, trnn.LangID, CASE WHEN trnn.LangID=@@LANGID THEN trnn.Name ELSE '[' + trnn.Name + ']' END AS TrainingType, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM dbo.VOL_Training trn
	INNER JOIN dbo.VOL_Training_Name trnn
		ON trn.TRN_ID=trnn.TRN_ID AND trnn.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Training_Name WHERE TRN_ID=trnn.TRN_ID ORDER BY CASE WHEN LangID=@@LangID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.VOL_OP_TRN pr 
		ON trn.TRN_ID = pr.TRN_ID AND pr.VNUM=@VNUM
	LEFT JOIN dbo.VOL_OP_TRN_Notes prn
		ON pr.OP_TRN_ID=prn.OP_TRN_ID AND prn.LangID=@@LANGID
	LEFT JOIN dbo.VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_TRN_ID IS NOT NULL
	OR trn.MemberID=vo.MemberID
	OR trn.MemberID=@MemberID
	OR (trn.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM dbo.VOL_Training_InactiveByMember WHERE TRN_ID=trn.TRN_ID AND MemberID=ISNULL(vo.MemberID,@MemberID))
	))
ORDER BY trn.DisplayOrder, trnn.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMTraining_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMTraining_s] TO [cioc_vol_search_role]
GO
