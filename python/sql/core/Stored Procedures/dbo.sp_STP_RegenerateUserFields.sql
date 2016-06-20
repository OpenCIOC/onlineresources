
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_RegenerateUserFields]
	@Domain tinyint = NULL,
	@FieldName varchar(100) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 22-Feb-2015
	Action: NO ACTION REQUIRED
*/
IF @Domain IS NULL SET @FieldName=NULL

IF @FieldName IS NULL BEGIN
-- PUBLICATION FIELDS

-- Remove Publication fields not allowed on display or forms
DELETE fo
	FROM GBL_FieldOption fo
	INNER JOIN CIC_Publication pb
		On fo.PB_ID=pb.PB_ID
	WHERE NOT (
			(fo.FieldName LIKE '%_DESC' AND pb.FieldDesc=1)
			OR (fo.FieldName LIKE '%_HEADINGS' AND pb.FieldHeadings=1)
			OR (fo.FieldName LIKE '%_HEADINGS_NP' AND pb.FieldHeadingsNP=1)
			OR (fo.FieldName LIKE '%_HEADINGGROUPS' AND pb.FieldHeadingGroups=1)
			OR (fo.FieldName LIKE '%_HEADINGGROUPS_NP' AND pb.FieldHeadingGroupsNP=1)
	)

-- Update Publication Description fields
UPDATE fo
	SET MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= '(Software Update)',
		FieldName		= REPLACE(PubCode,'-','_') + '_DESC',
		DisplayFM		= 'dbo.fn_CIC_NUMToPublicationDescription([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ')',
		DisplayFMWeb	= NULL,
		CanUseExport	= 0,
		CanShare		= 0
FROM GBL_FieldOption fo
INNER JOIN CIC_Publication pb
	ON fo.PB_ID=pb.PB_ID
WHERE fo.FieldName LIKE '%_DESC'

-- Insert missing Publication Description fields
INSERT INTO GBL_FieldOption (
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	FieldName,
	FieldType,
	FormFieldType,
	EquivalentSource,
	PB_ID,
	DisplayFM,
	DisplayFMWeb,
	UseDisplayForFeedback, UseDisplayForMailForm,
	CanUseResults, CanUseSearch, CanUseDisplay, CanUseUpdate, CanUseIndex, CanUseFeedback, CanUsePrivacy, CanUseExport,
	CanShare, MemberSpecific,
	CheckMultiLine, CheckHTML
)
SELECT
	MODIFIED_DATE,
	MODIFIED_BY,
	GETDATE(),
	'(Software Update)',
	REPLACE(PubCode,'-','_') + '_DESC',
	'CIC',
	'f',
	1,
	PB_ID,
	'dbo.fn_CIC_NUMToPublicationDescription([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ')',
	NULL,
	1,1,
	1,1,1,0,1,1,0,0,
	0,0,
	1,1
FROM CIC_Publication pb
WHERE pb.FieldDesc = 1
	AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE PB_ID=pb.PB_ID AND FieldName Like '%_DESC')

-- Update General Headings fields
UPDATE fo
SET MODIFIED_DATE	= GETDATE(),
	MODIFIED_BY		= '(Software Update)',
	FieldName		= REPLACE(PubCode,'-','_') + '_HEADINGS',
	DisplayFM		= 'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0)',
	DisplayFMWeb	= 'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0,[HTTP],[PTS])',
	CanUseResults	= 1,
	CanUseSearch	= 1,
	CanUseDisplay	= 1,
	CanUseUpdate	= 0,
	CanUseIndex		= 1,
	CanUseFeedback	= 1,
	CanUseExport	= 0,
	CanShare		= 0
FROM GBL_FieldOption fo
INNER JOIN CIC_Publication pb
	ON fo.PB_ID=pb.PB_ID
WHERE fo.FieldName LIKE '%_HEADINGS'

-- Insert missing General Heading fields
INSERT INTO GBL_FieldOption (
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	FieldName,
	FieldType,
	FormFieldType,
	EquivalentSource,
	PB_ID,
	DisplayFM,
	DisplayFMWeb,
	UseDisplayForFeedback, UseDisplayForMailForm,
	CanUseResults, CanUseSearch, CanUseDisplay, CanUseUpdate, CanUseIndex, CanUseFeedback, CanUsePrivacy, CanUseExport,
	CanShare, MemberSpecific,
	CheckMultiLine, CheckHTML
)
SELECT
	MODIFIED_DATE,
	MODIFIED_BY,
	GETDATE(),
	'(Software Update)',
	REPLACE(PubCode,'-','_') + '_HEADINGS',
	'CIC',
	'f',
	1,
	PB_ID,
	'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',0)',
	'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',0,[HTTP],[PTS])',
	1,1,
	1,1,1,0,1,1,0,0,
	0,0,
	0,1
FROM CIC_Publication pb
WHERE pb.FieldHeadings = 1
	AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE PB_ID=pb.PB_ID AND FieldName Like '%_HEADINGS')

-- Update General Heading (with Non-Public) fields
UPDATE fo
SET MODIFIED_DATE	= GETDATE(),
	MODIFIED_BY		= '(Software Update)',
	FieldName		= REPLACE(PubCode,'-','_') + '_HEADINGS_NP',
	DisplayFM		= 'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1)',
	DisplayFMWeb	= 'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1,[HTTP],[PTS])',
	UpdateFieldList	= '(SELECT (SELECT gh.GH_ID AS ''@ID'',
				gh.Used AS ''@Used'',
				CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE ''['' + ghn.Name + '']'' END END AS ''@Name'',
				ghgn.Name AS ''@Group'',
				CAST(CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB_GH pr WHERE pr.GH_ID=gh.GH_ID AND pr.NUM_Cache=bt.NUM) THEN 1 ELSE 0 END AS bit) AS ''@Selected''
				FROM CIC_GeneralHeading gh
				LEFT JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
				LEFT JOIN CIC_GeneralHeading_Group ghg ON gh.HeadingGroup=ghg.GroupID
				LEFT JOIN CIC_GeneralHeading_Group_Name ghgn ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghg.GroupID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
				WHERE (gh.Used=1 OR (gh.Used IS NULL AND EXISTS(SELECT * FROM CIC_BT_PB_GH pr INNER JOIN CIC_BT_PB prp ON prp.BT_PB_ID=pr.BT_PB_ID AND prp.NUM=bt.NUM WHERE pr.GH_ID=gh.GH_ID))) AND gh.PB_ID=' + CAST(pb.PB_ID AS varchar) + '
				ORDER BY ghg.DisplayOrder, ghgn.Name, gh.DisplayOrder, ghn.Name FOR XML PATH(''GH''), TYPE) FOR XML PATH(''HEADINGS''),TYPE) AS [' + REPLACE(pb.PubCode,'-','_') + '_HEADINGS_NP]',
	
	CanUseResults	= 1,
	CanUseSearch	= 1,
	CanUseDisplay	= 1,
	CanUseUpdate	= 1,
	CanUseIndex		= 1,
	CanUseFeedback	= 1,
	CanUseExport	= 0,
	CanShare		= 0
FROM GBL_FieldOption fo
INNER JOIN CIC_Publication pb
	ON fo.PB_ID=pb.PB_ID
WHERE fo.FieldName LIKE '%_HEADINGS_NP'
	AND pb.FieldHeadingsNP = 1

-- Insert missing General Heading (with Non-Public) fields
INSERT INTO GBL_FieldOption (
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	FieldName,
	FieldType,
	FormFieldType,
	EquivalentSource,
	PB_ID,
	DisplayFM,
	DisplayFMWeb,
	UpdateFieldList,
	UseDisplayForFeedback, UseDisplayForMailForm,
	CanUseResults, CanUseSearch, CanUseDisplay, CanUseUpdate, CanUseIndex, CanUseFeedback, CanUsePrivacy, CanUseExport,
	CanShare, MemberSpecific,
	CheckMultiLine, CheckHTML
)
SELECT
	MODIFIED_DATE,
	MODIFIED_BY,
	GETDATE(),
	'(Software Update)',
	REPLACE(PubCode,'-','_') + '_HEADINGS_NP',
	'CIC',
	'f',
	1,
	PB_ID,
	'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',1)',
	'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',1,[HTTP],[PTS])',
	'(SELECT (SELECT gh.GH_ID AS ''@ID'', ghn.Name AS ''@Name'', ghgn.Name AS ''@Group'', CAST(CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB_GH pr INNER JOIN CIC_BT_PB prp ON prp.BT_PB_ID=pr.BT_PB_ID AND prp.NUM=bt.NUM WHERE pr.GH_ID=gh.GH_ID) THEN 1 ELSE 0 END AS bit) AS ''@Selected'' FROM CIC_GeneralHeading gh INNER JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID) LEFT JOIN CIC_GeneralHeading_Group ghg ON gh.HeadingGroup=ghg.GroupID LEFT JOIN CIC_GeneralHeading_Group_Name ghgn ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghg.GroupID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID) WHERE gh.PB_ID='
		+ CAST(pb.PB_ID AS varchar) + ' ORDER BY ghg.DisplayOrder, ghgn.Name, gh.DisplayOrder, ghn.Name FOR XML PATH(''GH''), TYPE) FOR XML PATH(''HEADINGS''),TYPE) AS [' + REPLACE(pb.PubCode,'-','_') + '_HEADINGS_NP]',
	1,1,
	1,1,1,1,1,1,0,0,
	0,0,
	0,1
FROM CIC_Publication pb
WHERE pb.FieldHeadingsNP = 1
	AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE PB_ID=pb.PB_ID AND FieldName Like '%_HEADINGS_NP')

-- Update General Heading Groups fields
UPDATE fo
SET MODIFIED_DATE	= GETDATE(),
	MODIFIED_BY		= '(Software Update)',
	FieldName		= REPLACE(PubCode,'-','_') + '_HEADINGGROUPS',
	DisplayFM		= 'dbo.fn_CIC_NUMToGeneralHeadings_Groups([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0)',
	DisplayFMWeb	= 'dbo.fn_CIC_NUMToGeneralHeadings_Groups_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0,[HTTP],[PTS])',
	CanUseResults	= 1,
	CanUseSearch	= 1,
	CanUseDisplay	= 1,
	CanUseUpdate	= 0,
	CanUseIndex		= 0,
	CanUseFeedback	= 0,
	CanUseExport	= 0,
	CanShare		= 0
FROM GBL_FieldOption fo
INNER JOIN CIC_Publication pb
	ON fo.PB_ID=pb.PB_ID
WHERE fo.FieldName LIKE '%_HEADINGGROUPS'

-- Insert missing General Heading Groups fields
INSERT INTO GBL_FieldOption (
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	FieldName,
	FieldType,
	FormFieldType,
	EquivalentSource,
	PB_ID,
	DisplayFM,
	DisplayFMWeb,
	UseDisplayForFeedback, UseDisplayForMailForm,
	CanUseResults, CanUseSearch, CanUseDisplay, CanUseUpdate, CanUseIndex, CanUseFeedback, CanUsePrivacy, CanUseExport,
	CanShare, MemberSpecific,
	CheckMultiLine, CheckHTML
)
SELECT
	MODIFIED_DATE,
	MODIFIED_BY,
	GETDATE(),
	'(Software Update)',
	REPLACE(PubCode,'-','_') + '_HEADINGGROUPS',
	'CIC',
	'f',
	1,
	PB_ID,
	'dbo.fn_CIC_NUMToGeneralHeadings_Groups([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',0)',
	'dbo.fn_CIC_NUMToGeneralHeadings_Groups_Web([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',0,[HTTP],[PTS])',
	1,1,
	1,1,1,0,0,0,0,0,
	0,0,
	0,1
FROM CIC_Publication pb
WHERE pb.FieldHeadingGroups = 1
	AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE PB_ID=pb.PB_ID AND FieldName Like '%_HEADINGGROUPS')

-- Update General Heading Groups (with Non-Public) fields
UPDATE fo
SET MODIFIED_DATE	= GETDATE(),
	MODIFIED_BY		= '(Software Update)',
	FieldName		= REPLACE(PubCode,'-','_') + '_HEADINGGROUPS_NP',
	DisplayFM		= 'dbo.fn_CIC_NUMToGeneralHeadings_Groups([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1)',
	DisplayFMWeb	= 'dbo.fn_CIC_NUMToGeneralHeadings_Groups_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1,[HTTP],[PTS])',
	CanUseResults	= 1,
	CanUseSearch	= 1,
	CanUseDisplay	= 1,
	CanUseUpdate	= 0,
	CanUseIndex		= 0,
	CanUseFeedback	= 0,
	CanUseExport	= 0,
	CanShare		= 0
FROM GBL_FieldOption fo
INNER JOIN CIC_Publication pb
	ON fo.PB_ID=pb.PB_ID
WHERE fo.FieldName LIKE '%_HEADINGGROUPS_NP'

-- Insert missing General Heading Groups (with Non-Public) fields
INSERT INTO GBL_FieldOption (
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	FieldName,
	FieldType,
	FormFieldType,
	EquivalentSource,
	PB_ID,
	DisplayFM,
	DisplayFMWeb,
	UseDisplayForFeedback, UseDisplayForMailForm,
	CanUseResults, CanUseSearch, CanUseDisplay, CanUseUpdate, CanUseIndex, CanUseFeedback, CanUsePrivacy, CanUseExport,
	CanShare, MemberSpecific,
	CheckMultiLine, CheckHTML
)
SELECT
	MODIFIED_DATE,
	MODIFIED_BY,
	GETDATE(),
	'(Software Update)',
	REPLACE(PubCode,'-','_') + '_HEADINGGROUPS_NP',
	'CIC',
	'f',
	1,
	PB_ID,
	'dbo.fn_CIC_NUMToGeneralHeadings_Groups([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',1)',
	'dbo.fn_CIC_NUMToGeneralHeadings_Groups_Web([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',1,[HTTP],[PTS])',
	1,1,
	1,1,1,0,0,0,0,0,
	0,0,
	0,1
FROM CIC_Publication pb
WHERE pb.FieldHeadingGroupsNP = 1
	AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE PB_ID=pb.PB_ID AND FieldName LIKE '%_HEADINGGROUPS_NP')
	
END

-- EXTRA FIELDS
DECLARE @CheckListUpdate varchar(MAX)

IF @Domain IS NULL OR @Domain = 1 BEGIN
	
SET @CheckListUpdate = '(SELECT (SELECT exc.EXC_ID AS ''@ID'',
		ISNULL(CASE WHEN excn.LangID=btd.LangID THEN excn.Name ELSE ''['' + excn.Name + '']'' END,exc.Code) AS ''@Name'',
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS ''@SELECTED''
	FROM CIC_ExtraCheckList exc
	LEFT JOIN CIC_ExtraCheckList_Name excn
		ON exc.EXC_ID=excn.EXC_ID AND excn.LangID=CASE WHEN Code IS NOT NULL THEN btd.LangID ELSE (SELECT TOP 1 LangID FROM CIC_ExtraCheckList_Name excn WHERE excn.EXC_ID=exc.EXC_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID) END
	LEFT JOIN dbo.CIC_ExtraCheckList_InactiveByMember eibm ON eibm.EXC_ID = exc.EXC_ID AND eibm.MemberID=[MEMBER]
	LEFT JOIN CIC_BT_EXC pr ON pr.EXC_ID=exc.EXC_ID AND pr.NUM=bt.NUM
	WHERE exc.FieldName=''[CHECKLIST]'' AND (pr.NUM IS NOT NULL OR (ISNULL(excn.Name,exc.Code) IS NOT NULL AND eibm.EXC_ID IS NULL))
	ORDER BY exc.DisplayOrder, ISNULL(excn.Name,exc.Code)
	FOR XML PATH(''CHK''), TYPE)
FOR XML PATH(''EXTRA_CHECKLIST''),TYPE) AS [CHECKLIST]_XML'

UPDATE fo SET
		FormFieldType = CASE
				WHEN fo.ExtraFieldType IN ('e','w') OR (fo.ExtraFieldType = 't' AND fo.MaxLength <= 255) THEN 't'
				WHEN fo.ExtraFieldType IN ('a','d') THEN 'd'
				WHEN fo.ExtraFieldType IN ('l','p') THEN 'f'
				WHEN fo.ExtraFieldType = 'r' THEN 'c'
				ELSE 'm'
			END,
		EquivalentSource = CASE WHEN fo.ExtraFieldType IN ('d','c','l','p') THEN 0 ELSE 1 END,
		MaxLength = CASE
				WHEN fo.ExtraFieldType IN ('a','d') THEN 25
				WHEN fo.ExtraFieldType = 'e' THEN 60
				WHEN fo.ExtraFieldType IN ('l','r') THEN NULL
				WHEN fo.ExtraFieldType IN ('p','w') THEN 200
				WHEN fo.ExtraFieldType = 't' THEN CASE WHEN fo.MaxLength < 1 THEN 1 WHEN fo.MaxLength IS NULL OR fo.MaxLength > 8000 THEN 8000 ELSE fo.MaxLength END
			END,
		DisplayFM = CASE
				WHEN fo.ExtraFieldType = 'a' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DayMonthString([Value]) FROM CIC_BT_EXTRA_DATE WHERE NUM=bt.NUM AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'd' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString([Value]) FROM CIC_BT_EXTRA_DATE WHERE NUM=bt.NUM AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'e' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_EMAIL WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'l' THEN 'dbo.fn_CIC_NUMToExtraCheckList(''' + fo.FieldName + ''',bt.NUM,btd.LangID)'
				WHEN fo.ExtraFieldType = 'p' THEN 'dbo.fn_CIC_NUMToExtraDropDown(''' + fo.FieldName + ''',bt.NUM,btd.LangID)'
				WHEN fo.ExtraFieldType = 'r' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_RADIO WHERE NUM=bt.NUM AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 't' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_TEXT WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'w' THEN '(SELECT ISNULL(CASE WHEN [Protocol] = ''https://'' THEN [Protocol] ELSE '''' END, '''') + [Value] FROM CIC_BT_EXTRA_WWW WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''')'
			END,
		DisplayFMWeb = CASE
				WHEN fo.ExtraFieldType IN ('d','r','t') THEN NULL
				WHEN fo.ExtraFieldType = 'e' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_Link_Email([Value]) FROM CIC_BT_EXTRA_EMAIL WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'l' THEN 'dbo.fn_CIC_NUMToExtraCheckList_Web(''' + fo.FieldName + ''',bt.NUM,btd.LangID,[HTTP],[PTS])'
				WHEN fo.ExtraFieldType = 'p' THEN 'dbo.fn_CIC_NUMToExtraDropDown_Web(''' + fo.FieldName + ''',bt.NUM,btd.LangID,[HTTP],[PTS])'
				WHEN fo.ExtraFieldType = 'w' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_Link_WebsiteWithProtocol([Value],0,[Protocol]) FROM CIC_BT_EXTRA_WWW WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''')'
			END,
		UpdateFieldList = CASE
				WHEN fo.ExtraFieldType = 'a' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DayMonthString([Value]) FROM CIC_BT_EXTRA_DATE WHERE NUM=bt.NUM AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'd' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString([Value]) FROM CIC_BT_EXTRA_DATE WHERE NUM=bt.NUM AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'e' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_EMAIL WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'l' THEN REPLACE(@CheckListUpdate,'[CHECKLIST]',fo.FieldName)
				WHEN fo.ExtraFieldType = 'p' THEN '(SELECT EXD_ID FROM CIC_BT_EXD pr WHERE pr.NUM=bt.NUM AND FieldName_Cache=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'r' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_RADIO WHERE NUM=bt.NUM AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 't' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_TEXT WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'w' THEN '(SELECT [Value] FROM CIC_BT_EXTRA_WWW WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName + ', (SELECT [Protocol] FROM CIC_BT_EXTRA_WWW WHERE NUM=bt.NUM and LangID=btd.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName + '_PROTOCOL'
			END,
		FeedbackFieldList = CASE
				WHEN fo.ExtraFieldType = 'l' THEN 'dbo.fn_CIC_NUMToExtraCheckList(''' + fo.FieldName + ''',bt.NUM,btd.LangID) AS ''' + fo.FieldName + ''',' + REPLACE(@CheckListUpdate,'[CHECKLIST]',fo.FieldName)
				ELSE NULL
			END,
		UseDisplayForFeedback = CASE WHEN fo.ExtraFieldType IN ('a','d','e','t','w') THEN 1 ELSE 0 END,
		UseDisplayForMailForm = 1,
		CanUseResults = 1,
		CanUseSearch = 1,
		CheckListSearch = CASE
				WHEN fo.ExtraFieldType = 'l' THEN 'exc' + LOWER(REPLACE(FieldName,'EXTRA_CHECKLIST_',''))
				WHEN fo.ExtraFieldType = 'p' THEN 'exd' + LOWER(REPLACE(FieldName,'EXTRA_DROPDOWN_',''))
				ELSE NULL
			END,
		CanUseDisplay = 1,
		CanUseUpdate = 1,
		CanUseIndex = CASE WHEN fo.ExtraFieldType = 't' THEN 1 ELSE 0 END,
		CanUseFeedback = 1,
		CanUsePrivacy = CASE WHEN fo.ExtraFieldType IN ('e','t') THEN 1 ELSE 0 END,
		CheckMultiLine = CASE WHEN fo.ExtraFieldType = 't' THEN 1 ELSE 0 END,
		CheckHTML = CASE WHEN fo.ExtraFieldType = 't' THEN 1 ELSE 0 END,
		ValidateType = CASE
				WHEN fo.ExtraFieldType = 'a' THEN 'a'
				WHEN fo.ExtraFieldType = 'd' THEN 'd'
				WHEN fo.ExtraFieldType = 'e' THEN 'e'
				WHEN fo.ExtraFieldType = 'w' THEN 'w'
				ELSE NULL
			END,
		FullTextIndex = CASE WHEN fo.ExtraFieldType = 't' THEN fo.FullTextIndex ELSE 0 END,
		CanShare = 1,
		ChangeHistory = 5
	FROM GBL_FieldOption fo
WHERE fo.ExtraFieldType IN ('a','d','e','l','p','r','t','w') AND (@FieldName IS NULL OR FieldName=@FieldName)


END

IF @Domain IS NULL OR @Domain = 2 BEGIN
	
SET @CheckListUpdate = '(SELECT (SELECT exc.EXC_ID AS ''@ID'',
		ISNULL(CASE WHEN excn.LangID=vod.LangID THEN excn.Name ELSE ''['' + excn.Name + '']'' END,exc.Code) AS ''@Name'',
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS ''@SELECTED''
	FROM VOL_ExtraCheckList exc
	LEFT JOIN VOL_ExtraCheckList_Name excn
		ON exc.EXC_ID=excn.EXC_ID AND excn.LangID=CASE WHEN Code IS NOT NULL THEN vod.LangID ELSE (SELECT TOP 1 LangID FROM VOL_ExtraCheckList_Name excn WHERE excn.EXC_ID=exc.EXC_ID ORDER BY CASE WHEN LangID=vod.LangID THEN 0 ELSE 1 END, LangID) END
	LEFT JOIN dbo.VOL_ExtraCheckList_InactiveByMember eibm ON eibm.EXC_ID = exc.EXC_ID AND eibm.MemberID=[MEMBER]
	LEFT JOIN VOL_OP_EXC pr ON pr.EXC_ID=exc.EXC_ID AND pr.VNUM=vo.VNUM
	WHERE exc.FieldName=''[CHECKLIST]'' AND (pr.VNUM IS NOT NULL OR (ISNULL(excn.Name,exc.Code) IS NOT NULL AND eibm.EXC_ID IS NULL))
	ORDER BY exc.DisplayOrder, ISNULL(excn.Name,exc.Code)
	FOR XML PATH(''CHK''), TYPE)
FOR XML PATH(''EXTRA_CHECKLIST''),TYPE) AS [CHECKLIST]_XML'

UPDATE fo SET
		FormFieldType = CASE
				WHEN fo.ExtraFieldType IN ('e','w') OR (fo.ExtraFieldType = 't' AND fo.MaxLength <= 255) THEN 't'
				WHEN fo.ExtraFieldType IN ('a','d') THEN 'd'
				WHEN fo.ExtraFieldType IN ('l','p') THEN 'f'
				WHEN fo.ExtraFieldType = 'r' THEN 'c'
				ELSE 'm'
			END,
		EquivalentSource = CASE WHEN fo.ExtraFieldType IN ('d','c','l','p') THEN 0 ELSE 1 END,
		MaxLength = CASE
				WHEN fo.ExtraFieldType IN ('a','d') THEN 25
				WHEN fo.ExtraFieldType = 'e' THEN 60
				WHEN fo.ExtraFieldType IN ('l','r') THEN NULL
				WHEN fo.ExtraFieldType IN ('p','w') THEN 200
				WHEN fo.ExtraFieldType = 't' THEN CASE WHEN fo.MaxLength < 1 THEN 1 WHEN fo.MaxLength IS NULL OR fo.MaxLength > 8000 THEN 8000 ELSE fo.MaxLength END
			END,
		DisplayFM = CASE
				WHEN fo.ExtraFieldType = 'a' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DayMonthString([Value]) FROM VOL_OP_EXTRA_DATE WHERE VNUM=vo.VNUM AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'd' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString([Value]) FROM VOL_OP_EXTRA_DATE WHERE VNUM=vo.VNUM AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'e' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_EMAIL WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'l' THEN 'dbo.fn_VOL_VNUMToExtraCheckList(''' + fo.FieldName + ''',vo.VNUM,vod.LangID)'
				WHEN fo.ExtraFieldType = 'p' THEN 'dbo.fn_VOL_VNUMToExtraDropDown(''' + fo.FieldName + ''',vo.VNUM,vod.LangID)'
				WHEN fo.ExtraFieldType = 'r' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_RADIO WHERE VNUM=vo.VNUM AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 't' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_TEXT WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'w' THEN '(SELECT ISNULL(CASE WHEN [Protocol] = ''https://'' THEN [Protocol] ELSE '''' END, '''') + [Value] FROM VOL_OP_EXTRA_WWW WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''')'
			END,
		DisplayFMWeb = CASE
				WHEN fo.ExtraFieldType IN ('d','r','t') THEN NULL
				WHEN fo.ExtraFieldType = 'e' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_Link_Email([Value]) FROM VOL_OP_EXTRA_EMAIL WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''')'
				WHEN fo.ExtraFieldType = 'l' THEN 'dbo.fn_VOL_VNUMToExtraCheckList_Web(''' + fo.FieldName + ''',vo.VNUM,vod.LangID,[HTTP],[PTS])'
				WHEN fo.ExtraFieldType = 'p' THEN 'dbo.fn_VOL_VNUMToExtraDropDown_Web(''' + fo.FieldName + ''',vo.VNUM,vod.LangID,[HTTP],[PTS])'
				WHEN fo.ExtraFieldType = 'w' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_Link_WebsiteWithProtocol([Value],0,[Protocol]) FROM VOL_OP_EXTRA_WWW WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''')'
			END,
		UpdateFieldList = CASE
				WHEN fo.ExtraFieldType = 'a' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DayMonthString([Value]) FROM VOL_OP_EXTRA_DATE WHERE VNUM=vo.VNUM AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'd' THEN '(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString([Value]) FROM VOL_OP_EXTRA_DATE WHERE VNUM=vo.VNUM AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'e' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_EMAIL WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'l' THEN REPLACE(@CheckListUpdate,'[CHECKLIST]',fo.FieldName)
				WHEN fo.ExtraFieldType = 'p' THEN '(SELECT EXD_ID FROM VOL_OP_EXD pr WHERE pr.VNUM=vo.VNUM AND FieldName_Cache=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'r' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_RADIO WHERE VNUM=vo.VNUM AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 't' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_TEXT WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName
				WHEN fo.ExtraFieldType = 'w' THEN '(SELECT [Value] FROM VOL_OP_EXTRA_WWW WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName + ', (SELECT [Protocol] FROM VOL_OP_EXTRA_WWW WHERE VNUM=vo.VNUM and LangID=vod.LangID AND FieldName=''' + fo.FieldName + ''') AS ' + fo.FieldName + '_PROTOCOL'
			END,
		FeedbackFieldList = CASE
				WHEN fo.ExtraFieldType = 'l' THEN 'dbo.fn_VOL_VNUMToExtraCheckList(''' + fo.FieldName + ''',vo.VNUM,vod.LangID) AS ''' + fo.FieldName + ''',' + REPLACE(@CheckListUpdate,'[CHECKLIST]',fo.FieldName)
				ELSE NULL
			END,
		UseDisplayForFeedback = CASE WHEN fo.ExtraFieldType IN ('a','d','e','t','w') THEN 1 ELSE 0 END,
		CanUseResults = 1,
		CanUseSearch = 1,
		CheckListSearch = CASE
				WHEN fo.ExtraFieldType = 'l' THEN 'vxc' + LOWER(REPLACE(FieldName,'EXTRA_CHECKLIST_',''))
				WHEN fo.ExtraFieldType = 'p' THEN 'vxd' + LOWER(REPLACE(FieldName,'EXTRA_DROPDOWN_',''))
				ELSE NULL
			END,
		CanUseDisplay = 1,
		CanUseUpdate = 1,
		CanUseFeedback = 1,
		CheckMultiLine = CASE WHEN fo.ExtraFieldType = 't' THEN 1 ELSE 0 END,
		CheckHTML = CASE WHEN fo.ExtraFieldType = 't' THEN 1 ELSE 0 END,
		ValidateType = CASE
				WHEN fo.ExtraFieldType = 'a' THEN 'a'
				WHEN fo.ExtraFieldType = 'd' THEN 'd'
				WHEN fo.ExtraFieldType = 'e' THEN 'e'
				WHEN fo.ExtraFieldType = 'w' THEN 'w'
				ELSE NULL
			END,
		FullTextIndex = CASE WHEN fo.ExtraFieldType = 't' THEN fo.FullTextIndex ELSE 0 END,
		CanShare = 1,
		ChangeHistory = 5
	FROM VOL_FieldOption fo
WHERE fo.ExtraFieldType IN ('a','d','e','l','p','r','t','w') AND (@FieldName IS NULL OR FieldName=@FieldName)


END


SET NOCOUNT OFF










GO






GRANT EXECUTE ON  [dbo].[sp_STP_RegenerateUserFields] TO [cioc_login_role]
GO
