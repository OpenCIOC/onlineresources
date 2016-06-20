SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_Pub_l]
	@MemberID int,
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
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

SELECT ep.ExportPubID, pb.PubCode, ep.IncludeDescription, ep.IncludeHeadings
	FROM CIC_Publication pb
	INNER JOIN CIC_ExportProfile_Pub ep
		ON pb.PB_ID=ep.PB_ID
	WHERE ProfileID=@ProfileID
ORDER BY pb.PubCode

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_Pub_l] TO [cioc_login_role]
GO
