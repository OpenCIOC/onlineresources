
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_Dist_l]
	@MemberID int,
	@ProfileID int
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
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT CASE WHEN epn.LangID=@@LANGID THEN epn.Name ELSE '[' + epn.Name + ']' END AS ProfileName
	FROM CIC_ExportProfile_Description epn
WHERE MemberID_Cache=@MemberID
	AND ProfileID=@ProfileID
	AND epn.LangID=(SELECT TOP 1 LangID FROM CIC_ExportProfile_Description WHERE ProfileID=epn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

SELECT dst.DST_ID, dst.DistCode, dstn.Name AS DistName,
	CASE WHEN ed.DST_ID IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM CIC_Distribution dst
	LEFT JOIN CIC_Distribution_Name dstn
		ON dst.DST_ID=dstn.DST_ID AND dstn.LangID=@@LANGID
	LEFT OUTER JOIN (SELECT DST_ID FROM CIC_ExportProfile_Dist WHERE ProfileID=@ProfileID) ed
		ON dst.DST_ID=ed.DST_ID
	WHERE (dst.MemberID IS NULL OR dst.MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_Distribution_InactiveByMember WHERE DST_ID=dst.DST_ID AND MemberID=@MemberID)
ORDER BY CASE WHEN ed.DST_ID IS NOT NULL THEN 0 ELSE 1 END, dst.DistCode

RETURN @Error

SET NOCOUNT OFF






GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_Dist_l] TO [cioc_login_role]
GO
