
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_SecurityLevel_s]
	@MemberID int,
	@AgencyCode char(3),
	@SL_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 28-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND @SL_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND MemberID=@MemberID AND (Owner=@AgencyCode OR Owner IS NULL)) BEGIN
	SET @Error = 8 -- Security Failure
END

DECLARE @DefaultView int
SELECT @DefaultView = ViewType
	FROM CIC_SecurityLevel sl
WHERE SL_ID=@SL_ID

SELECT *, (SELECT SecurityLevel AS [@SecurityLevel], l.Culture AS [@Culture]
			FROM CIC_SecurityLevel_Name sln
			INNER JOIN STP_Language l
				ON l.LangID=sln.LangID
			WHERE sln.SL_ID=sl.SL_ID
		 FOR XML PATH('DESC'), TYPE) AS Descriptions,
		 (SELECT TOP 1 SecurityLevel FROM CIC_SecurityLevel_Name sln WHERE sln.SL_ID=sl.SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS SecurityLevelName,
		STUFF((SELECT ',' + l.Culture FROM CIC_SecurityLevel_EditLang el INNER JOIN STP_Language l ON l.LangID=el.LangID WHERE el.SL_ID=sl.SL_ID FOR XML PATH(''), TYPE).value('.', 'nvarchar(1000)'), 1, 1, '') AS EditLangs
	FROM CIC_SecurityLevel sl
WHERE MemberID=@MemberID
	AND (Owner=@AgencyCode OR Owner IS NULL)
	AND SL_ID=@SL_ID
	
SELECT api.*, apid.Name, apid.HelpFileName, apid.Description,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_ExternalAPI WHERE api.API_ID=API_ID AND SL_ID=@SL_ID) THEN 1 ELSE 0 END AS BIT) AS SELECTED
	FROM GBL_ExternalAPI api
	INNER JOIN GBL_ExternalAPI_Description apid
		ON api.API_ID=apid.API_ID AND apid.LangID=(SELECT TOP 1 LangID FROM GBL_ExternalAPI_Description WHERE apid.API_ID=API_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE api.CIC=1
ORDER BY apid.Name

SELECT vw.ViewType, CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		CAST(CASE WHEN slev.SL_ID IS NULL THEN 0 ELSE 1 END AS bit) AS SELECTED,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_VacancyEditView WHERE SL_ID=@SL_ID AND ViewType=vw.ViewType) THEN 1 ELSE 0 END AS bit) AS VacancySelected
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID=(SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_SecurityLevel_EditView slev
		ON slev.ViewType=vw.ViewType AND slev.SL_ID=@SL_ID
WHERE vw.MemberID=@MemberID
	AND vw.ViewType=@DefaultView OR EXISTS(SELECT * FROM CIC_View_Recurse vwr WHERE vwr.ViewType=@DefaultView AND vwr.CanSee=vw.ViewType)
ORDER BY CASE WHEN vw.ViewType=@DefaultView THEN 0 ELSE 1 END,
	vwd.ViewName
	
SELECT a.AgencyCode,
		CAST(CASE WHEN slea.SL_ID IS NULL THEN 0 ELSE 1 END AS bit) AS SELECTED,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_VacancyEditAgency WHERE AgencyCode=a.AgencyCode AND SL_ID=@SL_ID) THEN 1 ELSE 0 END AS bit) AS VacancySelected
	FROM GBL_Agency a
	LEFT JOIN STP_Member_ListForeignAgency memf
		ON a.AgencyID=memf.AgencyID AND memf.MemberID=@MemberID
	LEFT JOIN CIC_SecurityLevel_EditAgency slea
		ON slea.AgencyCode=a.AgencyCode AND slea.SL_ID=@SL_ID
WHERE slea.SL_ID IS NOT NULL OR (a.RecordOwnerCIC=1 AND (a.MemberID=@MemberID OR memf.AgencyID IS NOT NULL))
ORDER BY a.AgencyCode

SELECT rt.RT_ID, rt.RecordType, rtn.Name AS RecordTypeName,
		CAST(CASE WHEN srt.RT_ID IS NULL THEN 0 ELSE 1 END AS bit) AS LIMITED
	FROM CIC_RecordType rt
	LEFT JOIN CIC_RecordType_Name rtn
		ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
	LEFT JOIN CIC_SecurityLevel_RecordType srt
		ON rt.RT_ID=srt.RT_ID AND srt.SL_ID=@SL_ID
	LEFT JOIN CIC_RecordType_InactiveByMember ri
		ON rt.RT_ID=ri.RT_ID AND ri.MemberID=@MemberID
WHERE srt.RT_ID IS NOT NULL OR ri.RT_ID IS NULL

SELECT UserName
	FROM GBL_Users
WHERE SL_ID_CIC=@SL_ID

RETURN @Error

SET NOCOUNT OFF






GO


GRANT EXECUTE ON  [dbo].[sp_CIC_SecurityLevel_s] TO [cioc_login_role]
GO
