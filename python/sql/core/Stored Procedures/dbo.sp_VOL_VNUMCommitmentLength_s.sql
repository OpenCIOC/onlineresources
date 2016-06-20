
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMCommitmentLength_s]
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

SELECT cl.CL_ID, CASE WHEN cln.LangID=@@LANGID THEN cln.Name ELSE '[' + cln.Name + ']' END AS CommitmentLength, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM VOL_CommitmentLength cl
	INNER JOIN VOL_CommitmentLength_Name cln
		ON cl.CL_ID=cln.CL_ID AND cln.LangID=(SELECT TOP 1 LangID FROM VOL_CommitmentLength_Name WHERE CL_ID=cln.CL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_CL pr 
		ON cl.CL_ID = pr.CL_ID AND pr.VNUM=@VNUM
	LEFT JOIN VOL_OP_CL_Notes prn
		ON pr.OP_CL_ID=prn.OP_CL_ID AND prn.LangID=@@LANGID
	LEFT JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_CL_ID IS NOT NULL
	OR cl.MemberID=vo.MemberID
	OR cl.MemberID=@MemberID
	OR (cl.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM VOL_CommitmentLength_InactiveByMember WHERE CL_ID=cl.CL_ID AND MemberID=ISNULL(vo.MemberID,@MemberID))
	))
ORDER BY cl.DisplayOrder, cln.Name

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMCommitmentLength_s] TO [cioc_login_role]
GO
