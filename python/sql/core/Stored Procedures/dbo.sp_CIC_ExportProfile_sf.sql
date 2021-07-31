SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_sf]
	@ProfileID int,
	@ViewType int,
	@SharingFormat bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE @MemberID int

SELECT	@MemberID=MemberID
	FROM CIC_View
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
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ProfileID = NULL
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
-- Profile ID available in the View ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_View_ExportProfile vp WHERE vp.ProfileID=@ProfileID AND vp.ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
END

DECLARE @FieldList varchar(max),
	@GenHeadingsFieldList varchar(max),
	@PubDescFieldList varchar(max)

SET @FieldList = NULL
SET @GenHeadingsFieldList = NULL
SET @PubDescFieldList = NULL

DECLARE @TmpFieldList TABLE (
	FieldData varchar(max),
	FieldOrder varchar(500)
)

INSERT INTO @TmpFieldList
        ( FieldData, FieldOrder )
SELECT
		CASE
		WHEN ExtraFieldType IN ('a','d','e','l','p','r','t','w') AND @SharingFormat=0 THEN REPLACE(REPLACE(fo.DisplayFM,'[MEMBER]',@MemberID),'btd.LangID','@@LANGID') + ' AS ''' + FieldName + ''''
		WHEN ExtraFieldType IN ('a','d') THEN '(SELECT REPLACE(''' + FieldName + ''',''EXTRA_DATE_'','''') "@FLD",(SELECT [Value] FROM CIC_BT_EXTRA_DATE WHERE NUM=bt.NUM AND FieldName=''' + FieldName + ''') "@V" FOR XML PATH(''EXTRA_DATE''),TYPE) AS ''' + FieldName + ''''
		WHEN ExtraFieldType = 'e' THEN '(SELECT REPLACE(''' + FieldName + ''',''EXTRA_EMAIL_'','''') "@FLD",(SELECT [Value] FROM CIC_BT_EXTRA_EMAIL WHERE NUM=bt.NUM AND LangID=0 AND FieldName=''' + FieldName + ''') "@V",(SELECT [Value] FROM CIC_BT_EXTRA_EMAIL WHERE NUM=bt.NUM AND LangID=2 AND FieldName=''' + FieldName + ''') "@VF" FOR XML PATH(''EXTRA_EMAIL''),TYPE) AS ''' + FieldName + ''''
		WHEN ExtraFieldType = 'l' THEN '(SELECT REPLACE(''' + FieldName + ''',''EXTRA_CHECKLIST_'','''') "@FLD",
				(SELECT exc.Code "@CD", excne.Name "@V", excnf.Name "@VF"
					FROM CIC_BT_EXC pr INNER JOIN CIC_ExtraCheckList exc ON pr.EXC_ID=exc.EXC_ID
					INNER JOIN CIC_ExtraCheckList_Name excne ON exc.EXC_ID=excne.EXC_ID AND excne.LangID=(SELECT TOP 1 LangID FROM CIC_ExtraCheckList_Name WHERE EXC_ID=excne.EXC_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
					LEFT JOIN CIC_ExtraCheckList_Name excnf ON exc.EXC_ID=excnf.EXC_ID AND excnf.LangID=2 AND bt.HAS_FRENCH=1
					WHERE pr.NUM=bt.NUM AND exc.FieldName=''' + FieldName + '''
					FOR XML PATH(''CHK''), TYPE)
			FOR XML PATH(''EXTRA_CHECKLIST''), TYPE) AS ''' + FieldName + ''''
		WHEN ExtraFieldType = 'p' THEN 'ISNULL((SELECT REPLACE(''' + FieldName + ''',''EXTRA_DROPDOWN_'','''') "@FLD", exd.Code "@CD", exdne.Name "@V", exdnf.Name "@VF"
				FROM CIC_BT_EXD pr INNER JOIN CIC_ExtraDropDown exd ON pr.EXD_ID=exd.EXD_ID
				INNER JOIN CIC_ExtraDropDown_Name exdne ON exd.EXD_ID=exdne.EXD_ID AND exdne.LangID=(SELECT TOP 1 LangID FROM CIC_ExtraDropDown_Name WHERE EXD_ID=exdne.EXD_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
				LEFT JOIN CIC_ExtraDropDown_Name exdnf ON exd.EXD_ID=exdnf.EXD_ID AND exdnf.LangID=2 AND bt.HAS_FRENCH=1
				WHERE pr.NUM=bt.NUM AND exd.FieldName=''' + FieldName + '''
			FOR XML PATH(''EXTRA_DROPDOWN''), TYPE),
			(SELECT REPLACE(''' + FieldName + ''',''EXTRA_DROPDOWN_'','''') "@FLD" FOR XML PATH(''EXTRA_DROPDOWN''), TYPE)) AS ''' + FieldName + ''''
		WHEN ExtraFieldType = 'r' THEN '(SELECT REPLACE(''' + FieldName + ''',''EXTRA_RADIO_'','''') "@FLD",(SELECT [Value] FROM CIC_BT_EXTRA_RADIO WHERE NUM=bt.NUM AND FieldName=''' + FieldName + ''') "@V" FOR XML PATH(''EXTRA_RADIO''),TYPE) AS ''' + FieldName + ''''
		WHEN ExtraFieldType = 't' THEN '(SELECT REPLACE(''' + FieldName + ''',''EXTRA_'','''') "@FLD",(SELECT [Value] FROM CIC_BT_EXTRA_TEXT WHERE NUM=bt.NUM AND LangID=0 AND FieldName=''' + FieldName + ''') "@V",(SELECT [Value] FROM CIC_BT_EXTRA_TEXT WHERE NUM=bt.NUM AND LangID=2 AND FieldName=''' + FieldName + ''') "@VF" FOR XML PATH(''EXTRA''),TYPE) AS ''' + FieldName + ''''
		WHEN ExtraFieldType = 'w' THEN '(SELECT REPLACE(''' + FieldName + ''',''EXTRA_WWW_'','''') "@FLD",(SELECT [Value] FROM CIC_BT_EXTRA_WWW WHERE NUM=bt.NUM AND LangID=0 AND FieldName=''' + FieldName + ''') "@V",(SELECT [Value] FROM CIC_BT_EXTRA_WWW WHERE NUM=bt.NUM AND LangID=2 AND FieldName=''' + FieldName + ''') "@VF" FOR XML PATH(''EXTRA_WWW''),TYPE) AS ''' + FieldName + ''''
		ELSE FieldName
		END AS FieldData,
		CASE WHEN fo.ExtraFieldType='t' THEN REPLACE(FieldName,'_',' ') ELSE FieldName END AS FieldOrder
	FROM GBL_FieldOption fo
	INNER JOIN CIC_ExportProfile_Fld epf
		ON fo.FieldID=epf.FieldID
	INNER JOIN CIC_ExportProfile ep
		ON ep.ProfileID=epf.ProfileID
WHERE CanUseExport=1
	AND ep.ProfileID=@ProfileID

SELECT @FieldList=COALESCE(@FieldList+',','') + FieldData
FROM @TmpFieldList
ORDER BY FieldOrder

IF @SharingFormat = 0 BEGIN
	IF EXISTS(SELECT * FROM CIC_ExportProfile_Dist WHERE ProfileID=@ProfileID) BEGIN
		SET @FieldList = CASE WHEN @FieldList IS NULL THEN '' ELSE @FieldList + ',' END
			+ 'dbo.fn_CIC_NUMToDistribution_Export(bt.NUM,' + CAST(@ProfileID AS varchar) + ') AS DISTRIBUTION'
	END

	IF EXISTS(SELECT * FROM CIC_ExportProfile_Pub WHERE ProfileID=@ProfileID) BEGIN
		SET @FieldList = CASE WHEN @FieldList IS NULL THEN '' ELSE @FieldList + ',' END
			+ 'dbo.fn_CIC_NUMToPublication_Export(bt.NUM,' + CAST(@ProfileID AS varchar) + ') AS PUBLICATION'
			
		SELECT @GenHeadingsFieldList = COALESCE(@GenHeadingsFieldList + ',','')
				+ 'dbo.fn_CIC_NUMToGeneralHeadings(' + CAST(@MemberID AS varchar) + ',bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1) AS HEADINGS_' + pb.PubCode
			FROM CIC_ExportProfile_Pub epp
			INNER JOIN CIC_Publication pb
				ON epp.PB_ID=pb.PB_ID
		WHERE ProfileID=111
			AND IncludeHeadings=1
			AND EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.PB_ID=pb.PB_ID
				AND EXISTS(SELECT * FROM CIC_BT_PB_GH WHERE GH_ID=gh.GH_ID)
			)
		
		IF @GenHeadingsFieldList IS NOT NULL BEGIN
			SET @FieldList = @FieldList + ',' + @GenHeadingsFieldList
		END
		
		SELECT @PubDescFieldList = COALESCE(@PubDescFieldList + ',','')
				+ 'dbo.fn_CIC_NUMToPublicationDescription(' + CAST(@MemberID AS varchar) + ',bt.NUM,' + CAST(pb.PB_ID AS varchar) + ') AS DESCRIPTION_' + pb.PubCode
			FROM CIC_ExportProfile_Pub epp
			INNER JOIN CIC_Publication pb
				ON epp.PB_ID=pb.PB_ID
		WHERE ProfileID=111
			AND IncludeDescription=1
			AND EXISTS(SELECT * FROM CIC_BT_PB pr WHERE pr.PB_ID=pb.PB_ID
				AND EXISTS(SELECT * FROM CIC_BT_PB_Description WHERE BT_PB_ID=pr.BT_PB_ID)
			)
		
		IF @PubDescFieldList IS NOT NULL BEGIN
			SET @FieldList = @FieldList + ',' + @PubDescFieldList
		END
	END
END

SET @FieldList = 'NUM,RECORD_OWNER' + CASE WHEN @FieldList IS NULL THEN '' ELSE ',' + @FieldList END

SELECT	IncludePrivacyProfiles,
		SubmitChangesToAccessURL,
		ep.ConvertLine1Line2Addresses,
		dbo.fn_CIC_ExportProfile_SSL_Source(SubmitChangesToAccessURL) AS SubmitChangesToAccessProtocol,
		@FieldList AS FieldList,
		CAST(CASE WHEN epne.ProfileID IS NULL THEN 0 ELSE 1 END AS bit) AS ExportEn,
		CAST(CASE WHEN epnf.ProfileID IS NULL THEN 0 ELSE 1 END AS bit) AS ExportFr,
		epne.SourceDbName AS SourceDbNameEn,
		epnf.SourceDbName AS SourceDbNameFr,
		epne.SourceDbURL AS SourceDbURLEn,
		epnf.SourceDbURL AS SourceDbURLFr
	FROM CIC_ExportProfile ep
	LEFT JOIN CIC_ExportProfile_Description epne
		ON ep.ProfileID=epne.ProfileID AND epne.LangID=0
	LEFT JOIN CIC_ExportProfile_Description epnf
		ON ep.ProfileID=epnf.ProfileID AND epnf.LangID=2
WHERE ep.ProfileID=@ProfileID

RETURN @Error

SET NOCOUNT OFF



GO


GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_sf] TO [cioc_login_role]
GO
