SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_Fld_l]
	@MemberID int,
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 06-Oct-2013
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

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CASE WHEN ef.FieldID IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN CIC_ExportProfile_Fld ef
		ON fo.FieldID=ef.FieldID AND ProfileID=@ProfileID
	LEFT JOIN GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE CanUseExport=1
	AND (fi.FieldID IS NULL OR ef.FieldID IS NOT NULL)
ORDER BY CASE WHEN ef.FieldID IS NOT NULL THEN 0 ELSE 1 END, fo.FieldName

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_Fld_l] TO [cioc_login_role]
GO
