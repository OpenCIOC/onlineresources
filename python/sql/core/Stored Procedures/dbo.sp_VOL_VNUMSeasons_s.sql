
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMSeasons_s]
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

SELECT ssn.SSN_ID, CASE WHEN ssnn.LangID=@@LANGID THEN ssnn.Name ELSE '[' + ssnn.Name + ']' END AS Season, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM VOL_Seasons ssn
	INNER JOIN VOL_Seasons_Name ssnn
		ON ssn.SSN_ID=ssnn.SSN_ID AND ssnn.LangID=(SELECT TOP 1 LangID FROM VOL_Seasons_Name WHERE SSN_ID=ssnn.SSN_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_SSN pr 
		ON ssn.SSN_ID = pr.SSN_ID AND pr.VNUM=@VNUM
	LEFT JOIN VOL_OP_SSN_Notes prn
		ON pr.OP_SSN_ID=prn.OP_SSN_ID AND prn.LangID=@@LANGID
	LEFT JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_SSN_ID IS NOT NULL
	OR ssn.MemberID=vo.MemberID
	OR ssn.MemberID=@MemberID
	OR (ssn.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM VOL_Seasons_InactiveByMember WHERE SSN_ID=ssn.SSN_ID AND MemberID=ISNULL(vo.MemberID, @MemberID))
	))
ORDER BY ssn.DisplayOrder, ssnn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSeasons_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSeasons_s] TO [cioc_vol_search_role]
GO
