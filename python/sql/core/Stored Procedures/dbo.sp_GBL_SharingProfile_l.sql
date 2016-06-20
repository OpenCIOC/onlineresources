
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_SharingProfile_l]
	@MemberID int,
	@Domain int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: KL
	Checked on: 15-Apr-2015
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

SELECT sp.ProfileID, sp.ShareMemberID, 
	(SELECT TOP 1 CASE WHEN @Domain = 1 THEN MemberNameCIC ELSE MemberNameVOL END FROM STP_Member_Description WHERE MemberID=sp.ShareMemberID AND CASE WHEN @Domain = 1 THEN MemberNameCIC ELSE MemberNameVOL END IS NOT NULL ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS MemberName,
	ReadyToAccept, AcceptedDate, RevokedDate, Active, spn.Name,
	(SELECT COUNT(*) FROM dbo.GBL_BT_SharingProfile shp
		WHERE shp.ProfileID=sp.ProfileID) AS RecordsInTotal,
	-- Records that don't exist in an active state in any language
	(SELECT COUNT(*) FROM dbo.GBL_BT_SharingProfile shp
		WHERE shp.ProfileID=sp.ProfileID
		AND NOT EXISTS(SELECT * FROM dbo.GBL_BaseTable_Description btd WHERE btd.NUM=shp.NUM AND btd.DELETION_DATE IS NULL)) AS RecordsInDeleted
FROM GBL_SharingProfile sp
LEFT JOIN GBL_SharingProfile_Name spn
	ON sp.ProfileID=spn.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_SharingProfile_Name WHERE ProfileID=spn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE MemberID=@MemberID AND Domain=@Domain
ORDER BY CASE WHEN RevokedDate IS NULL THEN 0 ELSE 1 END, CASE WHEN AcceptedDate IS NULL THEN 0 ELSE 1 END, ReadyToAccept, Name

SELECT sp.ProfileID, sp.MemberID,
	(SELECT TOP 1 CASE WHEN @Domain = 1 THEN MemberNameCIC ELSE MemberNameVOL END FROM STP_Member_Description WHERE MemberID=sp.MemberID AND CASE WHEN @Domain = 1 THEN MemberNameCIC ELSE MemberNameVOL END IS NOT NULL ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS MemberName,
	ReadyToAccept, AcceptedDate, RevokedDate, Active, spn.Name,
	(SELECT COUNT(*) FROM dbo.GBL_BT_SharingProfile shp
		WHERE shp.ProfileID=sp.ProfileID) AS RecordsInTotal,
	-- Records that don't exist in an active state in any language
	(SELECT COUNT(*) FROM dbo.GBL_BT_SharingProfile shp
		WHERE shp.ProfileID=sp.ProfileID
		AND NOT EXISTS(SELECT * FROM dbo.GBL_BaseTable_Description btd WHERE btd.NUM=shp.NUM AND btd.DELETION_DATE IS NULL)) AS RecordsInDeleted
FROM GBL_SharingProfile sp
LEFT JOIN GBL_SharingProfile_Name spn
	ON sp.ProfileID=spn.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_SharingProfile_Name WHERE ProfileID=spn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ShareMemberID=@MemberID AND Domain=@Domain AND (ReadyToAccept=1 OR AcceptedDate IS NOT NULL)
ORDER BY CASE WHEN RevokedDate IS NULL THEN 0 ELSE 1 END, CASE WHEN AcceptedDate IS NULL THEN 0 ELSE 1 END, Name

RETURN @Error

SET NOCOUNT OFF





GO



GRANT EXECUTE ON  [dbo].[sp_GBL_SharingProfile_l] TO [cioc_login_role]
GO
