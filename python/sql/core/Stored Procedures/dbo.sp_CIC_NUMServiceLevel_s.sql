
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMServiceLevel_s]
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

SELECT sl.SL_ID, '(' + CAST(sl.ServiceLevelCode AS varchar) + ')'
		+ CASE WHEN sln.Name IS NULL THEN '' ELSE ' ' + sln.Name END AS ServiceLevel,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM CIC_ServiceLevel sl
	LEFT JOIN CIC_ServiceLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND sln.LangID=@@LANGID
	LEFT JOIN CIC_BT_SL pr
		ON sl.SL_ID = pr.SL_ID AND pr.NUM=@NUM
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
WHERE pr.BT_SL_ID IS NOT NULL
	OR sl.MemberID=bt.MemberID
	OR sl.MemberID=@MemberID
	OR (sl.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM CIC_ServiceLevel_InactiveByMember WHERE SL_ID=sl.SL_ID AND MemberID=ISNULL(bt.MemberID, @MemberID))
	))
ORDER BY sl.ServiceLevelCode

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_CIC_NUMServiceLevel_s] TO [cioc_login_role]
GO
