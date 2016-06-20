
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMFunding_s]
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

SELECT fd.FD_ID, fdn.LangID, CASE WHEN fdn.LangID=@@LANGID THEN fdn.Name ELSE '[' + fdn.Name + ']' END AS FundingType, prn.Notes,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM CIC_Funding fd
	INNER JOIN CIC_Funding_Name fdn
		ON fd.FD_ID=fdn.FD_ID
			AND fdn.LangID=(SELECT TOP 1 LangID FROM CIC_Funding_Name WHERE FD_ID=fd.FD_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_BT_FD pr 
		ON fd.FD_ID = pr.FD_ID AND pr.NUM=@NUM
	LEFT JOIN CIC_BT_FD_Notes prn
		ON pr.BT_FD_ID=prn.BT_FD_ID AND prn.LangID=@@LANGID
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
WHERE pr.BT_FD_ID IS NOT NULL
	OR fd.MemberID=bt.MemberID
	OR fd.MemberID=@MemberID
	OR (fd.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM CIC_Funding_InactiveByMember WHERE FD_ID=fd.FD_ID AND MemberID=ISNULL(bt.MemberID,@MemberID))
	))
ORDER BY fd.DisplayOrder, fdn.Name

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_CIC_NUMFunding_s] TO [cioc_login_role]
GO
