
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_s_FormLists]
	@MemberID [int],
	@ProfileID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 05-Mar-2015
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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT mem.MemberID, ISNULL(memd.MemberNameVOL,memd.MemberName) AS MemberNameVOL
FROM STP_Member mem
INNER JOIN STP_Member_Description memd
	ON mem.MemberID=memd.MemberID AND LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=memd.MemberID ORDER BY CASE WHEN MemberNameVOL IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE mem.MemberID<>@MemberID AND UseVOL=1

/* get View list */
SELECT vw.ViewType, cioc_shared.dbo.fn_SHR_GBL_AnonString(vwd.ViewName) AS ViewName, MemberID
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType 
			AND vwd.LangID=(SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY MemberID, vwd.ViewType

/* get Field list */
SELECT fo.FieldID, ISNULL(FieldDisplay, FieldName) AS FieldDisplay, CanShare, CAST(0 AS bit) AS Generated
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
ORDER BY fo.CanShare, ISNULL(FieldDisplay, FieldName)

SELECT STUFF(
	   (SELECT	', ' + u.Email FROM (SELECT DISTINCT u.Email
			FROM	GBL_Users u
			INNER JOIN VOL_SecurityLevel sl
				ON sl.SL_ID = u.SL_ID_VOL
			WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
						AND sl.MemberID = m.MemberID AND u.Email IS NOT NULL
			) u ORDER BY u.Email
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, '') AS NotifyEmailAddresses
FROM STP_Member m
WHERE m.MemberID=@MemberID

RETURN @Error

SET NOCOUNT OFF










GO

GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_s_FormLists] TO [cioc_login_role]
GO
