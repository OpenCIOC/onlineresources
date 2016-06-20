CREATE TABLE [dbo].[CIC_Publication]
(
[PB_ID] [int] NOT NULL IDENTITY(1, 1),
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[PubCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[NonPublic] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_NonPublic] DEFAULT ((0)),
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_Publication_DisplayOrder] DEFAULT ((0)),
[FieldHeadings] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_FieldHeadings] DEFAULT ((0)),
[FieldHeadingsNP] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_FieldHeadingsNP] DEFAULT ((0)),
[FieldDesc] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_FieldDesc] DEFAULT ((0)),
[FieldHeadingGroups] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_FieldHeadingGroups] DEFAULT ((0)),
[FieldHeadingGroupsNP] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_FieldHeadingGroupsNP] DEFAULT ((0)),
[CanEditHeadingsShared] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_CanEditHeadingsShared] DEFAULT ((0)),
[GlobalPublication] [bit] NOT NULL CONSTRAINT [DF_CIC_Publication_GlobalPublication] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Publication_FieldOption] ON [dbo].[CIC_Publication] 
FOR INSERT, UPDATE AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 15-Sep-2013
	Action: TESTING REQUIRED
*/

IF UPDATE(FieldDesc) BEGIN
	DELETE fo
		FROM GBL_FieldOption fo
		INNER JOIN Inserted i
			ON fo.PB_ID = i.PB_ID
		WHERE fo.FieldName LIKE '%_DESC'
			AND i.FieldDesc = 0
		
	UPDATE fo
	SET MODIFIED_DATE = GETDATE(),
		MODIFIED_BY = i.MODIFIED_BY,
		DisplayFM = 'dbo.fn_CIC_NUMToPublicationDescription([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ')',
		DisplayFMWeb = NULL
	FROM GBL_FieldOption fo
	INNER JOIN CIC_Publication pb
		ON fo.PB_ID=pb.PB_ID
	INNER JOIN inserted i
		ON pb.PB_ID=i.PB_ID
	WHERE fo.FieldName LIKE '%_DESC'
		AND i.FieldDesc = 1

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
		GETDATE(),
		MODIFIED_BY,
		GETDATE(),
		MODIFIED_BY,
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
	FROM Inserted i
	WHERE i.FieldDesc = 1 AND
		NOT EXISTS(SELECT * FROM GBL_FieldOption
			WHERE PB_ID=i.PB_ID AND FieldName Like '%_DESC')

END

IF UPDATE(FieldHeadings) BEGIN
	DELETE fo
		FROM GBL_FieldOption fo
		INNER JOIN Inserted i
			ON fo.PB_ID = i.PB_ID
		WHERE fo.FieldName LIKE '%_HEADINGS'
			AND i.FieldHeadings = 0

	UPDATE fo
	SET MODIFIED_DATE = GETDATE(),
		MODIFIED_BY = i.MODIFIED_BY,
		DisplayFM = 'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0)',
		DisplayFMWeb = 'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0,[HTTP],[PTS])'
	FROM GBL_FieldOption fo
	INNER JOIN CIC_Publication pb
		ON fo.PB_ID=pb.PB_ID
	INNER JOIN inserted i
		ON pb.PB_ID=i.PB_ID
	WHERE fo.FieldName LIKE '%_HEADINGS'
		AND i.FieldHeadings = 1

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
		GETDATE(),
		MODIFIED_BY,
		GETDATE(),
		MODIFIED_BY,
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
	FROM Inserted i
	WHERE i.FieldHeadings = 1 AND
		NOT EXISTS(SELECT * FROM GBL_FieldOption
			WHERE PB_ID=i.PB_ID AND FieldName Like '%_HEADINGS')
END

IF UPDATE(FieldHeadingsNP) BEGIN
	DELETE fo
		FROM GBL_FieldOption fo
		INNER JOIN Inserted i
			ON fo.PB_ID = i.PB_ID
		WHERE fo.FieldName LIKE '%_HEADINGS_NP'
			AND i.FieldHeadingsNP = 0

	UPDATE fo
	SET MODIFIED_DATE = GETDATE(),
		MODIFIED_BY = i.MODIFIED_BY,
		DisplayFM = 'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1)',
		DisplayFMWeb = 'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1,[HTTP],[PTS])',
		UpdateFieldList = '(SELECT (SELECT gh.GH_ID AS ''@ID'',
				gh.Used AS ''@Used'',
				CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE ''['' + ghn.Name + '']'' END END AS ''@Name'',
				ghgn.Name AS ''@Group'',
				CAST(CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB_GH pr WHERE pr.NUM_Cache=bt.NUM AND pr.GH_ID=gh.GH_ID) THEN 1 ELSE 0 END AS bit) AS ''@Selected''
				FROM CIC_GeneralHeading gh
				LEFT JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
				LEFT JOIN CIC_GeneralHeading_Group ghg ON gh.HeadingGroup=ghg.GroupID
				LEFT JOIN CIC_GeneralHeading_Group_Name ghgn ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghg.GroupID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
				WHERE (gh.Used=1 OR (gh.Used IS NULL AND EXISTS(SELECT * FROM CIC_BT_PB_GH pr INNER JOIN CIC_BT_PB prp ON prp.BT_PB_ID=pr.BT_PB_ID AND prp.NUM=bt.NUM WHERE pr.GH_ID=gh.GH_ID))) AND gh.PB_ID=' + CAST(pb.PB_ID AS varchar) + '
				ORDER BY ghg.DisplayOrder, ghgn.Name, gh.DisplayOrder, ghn.Name FOR XML PATH(''GH''), TYPE) FOR XML PATH(''HEADINGS''),TYPE) AS [' + REPLACE(i.PubCode,'-','_') + '_HEADINGS_NP]'
	FROM GBL_FieldOption fo
	INNER JOIN CIC_Publication pb
		ON fo.PB_ID=pb.PB_ID
	INNER JOIN inserted i
		ON pb.PB_ID=i.PB_ID
	WHERE fo.FieldName LIKE '%_HEADINGS_NP'
		AND i.FieldHeadingsNP = 1

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
		GETDATE(),
		MODIFIED_BY,
		GETDATE(),
		MODIFIED_BY,
		REPLACE(PubCode,'-','_') + '_HEADINGS_NP',
		'CIC',
		'f',
		1,
		PB_ID,
		'dbo.fn_CIC_NUMToGeneralHeadings([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',1)',
		'dbo.fn_CIC_NUMToGeneralHeadings_Web([MEMBER],bt.NUM,' + CAST(PB_ID AS varchar) + ',1,[HTTP],[PTS])',
		UpdateFieldList = '(SELECT (SELECT gh.GH_ID AS ''@ID'', ghn.Name AS ''@Name'', ghgn.Name AS ''@Group'', CAST(CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB_GH pr INNER JOIN CIC_BT_PB prp ON prp.BT_PB_ID=pr.BT_PB_ID AND prp.NUM=bt.NUM WHERE pr.GH_ID=gh.GH_ID) THEN 1 ELSE 0 END AS bit) AS ''@Selected'' FROM CIC_GeneralHeading gh INNER JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID) LEFT JOIN CIC_GeneralHeading_Group ghg ON gh.HeadingGroup=ghg.GroupID LEFT JOIN CIC_GeneralHeading_Group_Name ghgn ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghg.GroupID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID) WHERE gh.PB_ID='
			+ CAST(i.PB_ID AS varchar) + ' ORDER BY ghg.DisplayOrder, ghgn.Name, gh.DisplayOrder, ghn.Name FOR XML PATH(''GH''), TYPE) FOR XML PATH(''HEADINGS''),TYPE) AS [' + REPLACE(i.PubCode,'-','_') + '_HEADINGS_NP]',
		1,1,
		1,1,1,1,1,1,0,0,
		0,0,
		0,1
	FROM Inserted i
	WHERE i.FieldHeadingsNP = 1 AND
		NOT EXISTS(SELECT * FROM GBL_FieldOption
			WHERE PB_ID=i.PB_ID AND FieldName Like '%_HEADINGS_NP')
END

IF UPDATE(FieldHeadings) BEGIN
	DELETE fo
		FROM GBL_FieldOption fo
		INNER JOIN Inserted i
			ON fo.PB_ID = i.PB_ID
		WHERE fo.FieldName LIKE '%_HEADINGGROUPS'
			AND i.FieldHeadingGroups = 0

	UPDATE fo
	SET MODIFIED_DATE = GETDATE(),
		MODIFIED_BY = i.MODIFIED_BY,
		DisplayFM = 'dbo.fn_CIC_NUMToGeneralHeadings_Groups([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0)',
		DisplayFMWeb = 'dbo.fn_CIC_NUMToGeneralHeadings_Groups_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',0,[HTTP],[PTS])'
	FROM GBL_FieldOption fo
	INNER JOIN CIC_Publication pb
		ON fo.PB_ID=pb.PB_ID
	INNER JOIN inserted i
		ON pb.PB_ID=i.PB_ID
	WHERE fo.FieldName LIKE '%_HEADINGGROUPS'
		AND i.FieldHeadingGroups = 1

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
		GETDATE(),
		MODIFIED_BY,
		GETDATE(),
		MODIFIED_BY,
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
	FROM Inserted i
	WHERE i.FieldHeadingGroups = 1 AND
		NOT EXISTS(SELECT * FROM GBL_FieldOption
			WHERE PB_ID=i.PB_ID AND FieldName Like '%_HEADINGGROUPS')
END

IF UPDATE(FieldHeadingsNP) BEGIN
	DELETE fo
		FROM GBL_FieldOption fo
		INNER JOIN Inserted i
			ON fo.PB_ID = i.PB_ID
		WHERE fo.FieldName LIKE '%_HEADINGGROUPS_NP'
			AND i.FieldHeadingGroupsNP = 0

	UPDATE fo
	SET MODIFIED_DATE = GETDATE(),
		MODIFIED_BY = i.MODIFIED_BY,
		DisplayFM = 'dbo.fn_CIC_NUMToGeneralHeadings_Groups([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1)',
		DisplayFMWeb = 'dbo.fn_CIC_NUMToGeneralHeadings_Groups_Web([MEMBER],bt.NUM,' + CAST(pb.PB_ID AS varchar) + ',1,[HTTP],[PTS])'
	FROM GBL_FieldOption fo
	INNER JOIN CIC_Publication pb
		ON fo.PB_ID=pb.PB_ID
	INNER JOIN inserted i
		ON pb.PB_ID=i.PB_ID
	WHERE fo.FieldName LIKE '%_HEADINGGROUPS_NP'
		AND i.FieldHeadingGroupsNP = 1

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
		GETDATE(),
		MODIFIED_BY,
		GETDATE(),
		MODIFIED_BY,
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
	FROM Inserted i
	WHERE i.FieldHeadingGroupsNP = 1 AND
		NOT EXISTS(SELECT * FROM GBL_FieldOption
			WHERE PB_ID=i.PB_ID AND FieldName Like '%_HEADINGGROUPS_NP')
END

IF UPDATE(PubCode) BEGIN
	UPDATE fo
	SET FieldName = REPLACE(PubCode,'-','_') + '_DESC'
	FROM GBL_FieldOption fo
	INNER JOIN Inserted i
		ON fo.PB_ID=i.PB_ID
	WHERE fo.FieldName Like '%_DESC'

	UPDATE fo
	SET FieldName = REPLACE(PubCode,'-','_') + '_HEADINGS'
	FROM GBL_FieldOption fo
	INNER JOIN Inserted i
		ON fo.PB_ID=i.PB_ID
	WHERE fo.FieldName Like '%_HEADINGS'

	UPDATE fo
	SET FieldName = REPLACE(PubCode,'-','_') + '_HEADINGS_NP'
	FROM GBL_FieldOption fo
	INNER JOIN Inserted i
		ON fo.PB_ID=i.PB_ID
	WHERE fo.FieldName Like '%_HEADINGS_NP'
	
	UPDATE fo
	SET FieldName = REPLACE(PubCode,'-','_') + '_HEADINGGROUPS'
	FROM GBL_FieldOption fo
	INNER JOIN Inserted i
		ON fo.PB_ID=i.PB_ID
	WHERE fo.FieldName Like '%_HEADINGGROUPS'

	UPDATE fo
	SET FieldName = REPLACE(PubCode,'-','_') + '_HEADINGGROUPS_NP'
	FROM GBL_FieldOption fo
	INNER JOIN Inserted i
		ON fo.PB_ID=i.PB_ID
	WHERE fo.FieldName Like '%_HEADINGGROUPS_NP'
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Publication] ADD CONSTRAINT [PK_CIC_Publication] PRIMARY KEY CLUSTERED  ([PB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Publication] ADD CONSTRAINT [IX_CIC_Publication] UNIQUE NONCLUSTERED  ([PubCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Publication] ADD CONSTRAINT [FK_CIC_Publication_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Publication] WITH NOCHECK ADD CONSTRAINT [FK_CIC_Publication_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[CIC_Publication] NOCHECK CONSTRAINT [FK_CIC_Publication_GBL_Agency]
GO
GRANT SELECT ON  [dbo].[CIC_Publication] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Publication] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Publication] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Publication] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Publication] TO [cioc_login_role]
GO
