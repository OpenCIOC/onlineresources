
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_s_Review]
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

SELECT sp.*, spn.Name, ISNULL(memd.MemberNameVOL,memd.MemberName) AS MemberName
FROM GBL_SharingProfile sp
LEFT JOIN GBL_SharingProfile_Name spn
	ON sp.ProfileID=spn.ProfileID AND spn.LangID=(SELECT TOP 1 LangID FROM GBL_SharingProfile_Name WHERE ProfileID=spn.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN STP_Member_Description memd
	ON sp.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=memd.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ShareMemberID=@MemberID AND sp.ProfileID=@ProfileID

/* get View list */
SELECT vw.ViewType, vwd.ViewName
FROM GBL_SharingProfile_VOL_View svw
INNER JOIN VOL_View vw
	ON vw.ViewType=svw.ViewType AND ProfileID=@ProfileID
INNER JOIN VOL_View_Description vwd
	ON vw.ViewType=vwd.ViewType 
		AND vwd.LangID=(SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY vwd.ViewName

/* get Field list */
SELECT fo.FieldID, ISNULL(FieldDisplay, FieldName) AS FieldDisplay, CanShare, CAST(0 AS bit) AS Generated
FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE fo.CanShare=0 OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_Fld WHERE FieldID=fo.FieldID)
ORDER BY CanShare, ISNULL(FieldDisplay, FieldName)

SELECT l.Culture
FROM GBL_SharingProfile_EditLang el
INNER JOIN STP_Language l
	ON l.LangID = el.LangID
WHERE el.ProfileID=@ProfileID
ORDER BY l.Active DESC, l.LanguageName

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_s_Review] TO [cioc_login_role]
GO
