SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_SharingProfile_l_RecordAddable]
	@MemberID int,
	@Domain int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT sp.ProfileID, sp.ShareMemberID, spn.Name,
	(SELECT TOP 1 ISNULL(CASE WHEN @Domain=1 THEN MemberNameCIC ELSE MemberNameVOL END,MemberName) AS MemberName FROM STP_Member_Description WHERE MemberID=sp.ShareMemberID ORDER BY CASE WHEN ((@Domain=1 AND MemberNameCIC IS NOT NULL) OR (@Domain=2 AND MemberNameVOL IS NOT NULL)) THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS MemberName
FROM GBL_SharingProfile sp
LEFT JOIN GBL_SharingProfile_Name spn
	ON sp.ProfileID=spn.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_SharingProfile_Name WHERE ProfileID=spn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE MemberID=@MemberID AND Domain=@Domain AND (RevokedDate IS NULL OR RevokedDate > GETDATE())
ORDER BY Name

RETURN @Error

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SharingProfile_l_RecordAddable] TO [cioc_login_role]
GO
