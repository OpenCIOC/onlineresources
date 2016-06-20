SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_PrintProfile_Fld_l]
	@MemberID int,
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=1) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT CASE WHEN ppd.LangID=@@LANGID THEN ppd.ProfileName ELSE '[' + ppd.ProfileName + ']' END AS ProfileName
	FROM GBL_PrintProfile pp
	INNER JOIN GBL_PrintProfile_Description ppd
		ON pp.ProfileID=ppd.ProfileID AND ppd.LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Description WHERE ProfileID=ppd.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE pp.MemberID=@MemberID
	AND pp.ProfileID=@ProfileID
	AND Domain=1

SELECT fo.FieldName, ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		ftn.FieldType, pf.*,
		(SELECT COUNT(*) FROM GBL_PrintProfile_Fld_FindReplace pfr WHERE pfr.PFLD_ID=pf.PFLD_ID) AS FindReplaceCount,
		(SELECT pfd.*, l.Culture
			FROM GBL_PrintProfile_Fld_Description pfd
			INNER JOIN STP_Language l
				ON pfd.LangID=l.LangID
			WHERE pfd.PFLD_ID=pf.PFLD_ID
			FOR XML PATH('DESC')
			) AS Descriptions
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN GBL_PrintProfile_Fld pf
		ON fo.FieldID=pf.GBLFieldID AND ProfileID=@ProfileID
	INNER JOIN GBL_PrintProfile_Fld_Type_Name ftn
		ON pf.FieldTypeID=ftn.FieldTypeID AND ftn.LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Fld_Type_Name WHERE ftn.FieldTypeID=FieldTypeID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_InactiveByMember fi WHERE fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID)
ORDER BY pf.DisplayOrder, fo.FieldName

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_PrintProfile_Fld_l] TO [cioc_login_role]
GO
