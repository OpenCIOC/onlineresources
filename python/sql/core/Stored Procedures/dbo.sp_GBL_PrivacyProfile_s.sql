SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrivacyProfile_s]
	@MemberID int,
	@ProfileID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
-- Profile belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrivacyProfile WHERE MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT *, (SELECT COUNT(*) FROM GBL_BaseTable bt WHERE bt.PRIVACY_PROFILE=@ProfileID) AS RecordCount,
		(SELECT ppn.ProfileName AS [@ProfileName], l.Culture AS [@Culture]
		FROM GBL_PrivacyProfile_Name ppn
		INNER JOIN STP_Language l
			ON ppn.LangID=l.LangID
		WHERE pp.ProfileID=ppn.ProfileID
		FOR XML PATH('DESC'), TYPE) AS Names,
		(SELECT TOP 1 ProfileName FROM GBL_PrivacyProfile_Name WHERE pp.ProfileID=ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ProfileName
	FROM GBL_PrivacyProfile pp
WHERE MemberID=@MemberID
	AND ProfileID=@ProfileID

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CAST(CASE WHEN ef.FieldID IS NULL THEN 0 ELSE 1 END AS bit) AS IS_SELECTED
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN GBL_PrivacyProfile_Fld ef
		ON fo.FieldID=ef.FieldID AND ProfileID=@ProfileID
	WHERE fo.CanUsePrivacy=1
ORDER BY CASE WHEN ef.FieldID IS NOT NULL THEN 0 ELSE 1 END, fo.DisplayOrder, fo.FieldName

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrivacyProfile_s] TO [cioc_login_role]
GO
