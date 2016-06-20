
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMFeeType_s]
	@MemberID int,
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
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

SELECT ft.FT_ID, ftn.LangID, CASE WHEN ftn.LangID=@@LANGID THEN ftn.Name ELSE '[' + ftn.Name + ']' END AS FeeType, prn.Notes,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM CIC_FeeType ft
	INNER JOIN CIC_FeeType_Name ftn
		ON ft.FT_ID=ftn.FT_ID
			AND ftn.LangID=(SELECT TOP 1 LangID FROM CIC_FeeType_Name WHERE FT_ID=ft.FT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_BT_FT pr 
		ON ft.FT_ID = pr.FT_ID AND pr.NUM=@NUM
	LEFT JOIN CIC_BT_FT_Notes prn
		ON pr.BT_FT_ID=prn.BT_FT_ID AND prn.LangID=@@LANGID
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
WHERE pr.BT_FT_ID IS NOT NULL
	OR ft.MemberID=bt.MemberID
	OR ft.MemberID=@MemberID
	OR (ft.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM CIC_FeeType_InactiveByMember WHERE FT_ID=ft.FT_ID AND MemberID=ISNULL(bt.MemberID,@MemberID))
	))
ORDER BY ft.DisplayOrder, ftn.Name

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_CIC_NUMFeeType_s] TO [cioc_login_role]
GO
