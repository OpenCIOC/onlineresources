SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_SharingProfile_s_Basic]
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
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT sp.*, spn.Name, ISNULL(smn.MemberNameCIC,smn.MemberName) AS SharingMemberName, ISNULL(rmn.MemberNameCIC,rmn.MemberName) AS ReceivingMemberName,
	(SELECT COUNT(*) FROM GBL_BT_SharingProfile WHERE ProfileID=sp.ProfileID) AS RecordCount
FROM GBL_SharingProfile sp
LEFT JOIN GBL_SharingProfile_Name spn
	ON sp.ProfileID=spn.ProfileID AND spn.LangID=(SELECT TOP 1 LangID FROM GBL_SharingProfile_Name WHERE ProfileID=spn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN STP_Member_Description smn
	ON sp.MemberID=smn.MemberID AND smn.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=smn.MemberID ORDER BY CASE WHEN MemberNameCIC IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN STP_Member_Description rmn
	ON sp.ShareMemberID=rmn.MemberID AND rmn.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=rmn.MemberID ORDER BY CASE WHEN MemberNameCIC IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (sp.MemberID=@MemberID OR ShareMemberID=@MemberID) AND sp.ProfileID=@ProfileID

RETURN @Error

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_CIC_SharingProfile_s_Basic] TO [cioc_login_role]
GO
