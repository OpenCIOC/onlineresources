SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_PrintProfile_sf]
	@ProfileID [int],
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM VOL_View
WHERE ViewType=@ViewType

-- ViewType given ?
IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=2) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ProfileID = NULL
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=2 AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
-- Profile ID available in the View ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_View_PrintProfile vp WHERE vp.ProfileID=@ProfileID AND vp.ViewType=@ViewType) AND NOT EXISTS(SELECT * FROM VOL_View WHERE DefaultPrintProfile=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
END

SELECT	pp.StyleSheet,
		ppd.PageTitle,
		ppd.Header,
		ppd.Footer,
		pp.Separator,
		pp.PageBreak,
		pp.TableClass,
		pp.MsgBeforeRecord,
		pp.IncludeCiocBasicStyleSheet
	FROM GBL_PrintProfile pp
	LEFT JOIN GBL_PrintProfile_Description ppd
		ON pp.ProfileID=ppd.ProfileID AND ppd.LangID=@@LANGID
WHERE pp.ProfileID=@ProfileID

SELECT	fr.PFLD_ID,
		fr.LookFor,
		fr.ReplaceWith,
		fr.RegEx,
		fr.MatchCase,
		fr.MatchAll
	FROM GBL_PrintProfile_Fld pf
	INNER JOIN GBL_PrintProfile_Fld_FindReplace fr
		ON pf.PFLD_ID = fr.PFLD_ID
	INNER JOIN GBL_PrintProfile_Fld_FindReplace_Lang frl
		ON fr.PFLD_RP_ID = frl.PFLD_RP_ID AND frl.LangID=@@LANGID
WHERE pf.ProfileID=@ProfileID
ORDER BY fr.PFLD_ID, fr.RunOrder

SELECT	pf.PFLD_ID,
		fo.FieldName,
		pf.FieldTypeID,
		pf.HeadingLevel,
		Label,
		pf.LabelStyle,
		pf.ContentStyle, 
		pf.Separator,
		Prefix,
		Suffix,
		pf.DisplayOrder,
		CASE WHEN EXISTS(SELECT * FROM GBL_PrintProfile_Fld_FindReplace fr WHERE fr.PFLD_ID=pf.PFLD_ID) THEN 1 ELSE 0 END AS HAS_FIND,
		dbo.fn_GBL_FieldOption_Display_Print(@MemberID,NULL,1,fo.FieldID,ContentIfEmpty)+ ' AS ''' + FieldName + '''' AS FieldSelect
	FROM GBL_PrintProfile_Fld pf
	INNER JOIN GBL_FieldOption fo
		ON pf.GBLFieldID = fo.FieldID
	LEFT JOIN GBL_PrintProfile_Fld_Description pfd
		ON pf.PFLD_ID=pfd.PFLD_ID AND pfd.LangID=@@LANGID
WHERE	(pf.ProfileID=@ProfileID)
		AND fo.FieldType='GBL'
UNION SELECT pf.PFLD_ID,
		fo.FieldName,
		pf.FieldTypeID,
		pf.HeadingLevel,
		Label,
		pf.LabelStyle,
		pf.ContentStyle, 
		pf.Separator,
		Prefix,
		Suffix,
		pf.DisplayOrder,
		CASE WHEN EXISTS(SELECT * FROM GBL_PrintProfile_Fld_FindReplace fr WHERE fr.PFLD_ID=pf.PFLD_ID) THEN 1 ELSE 0 END AS HAS_FIND,
		dbo.fn_VOL_FieldOption_Display_Print(@MemberID,@ViewType,fo.FieldID,ContentIfEmpty) + ' AS ''' + FieldName + '''' AS FieldSelect
	FROM GBL_PrintProfile_Fld pf
	INNER JOIN VOL_FieldOption fo
		ON pf.VOLFieldID = fo.FieldID
	LEFT JOIN GBL_PrintProfile_Fld_Description pfd
		ON pf.PFLD_ID=pfd.PFLD_ID AND pfd.LangID=@@LANGID
WHERE	(pf.ProfileID=@ProfileID)
ORDER BY pf.DisplayOrder, fo.FieldName

SET NOCOUNT OFF

RETURN @Error





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_PrintProfile_sf] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_PrintProfile_sf] TO [cioc_vol_search_role]
GO
