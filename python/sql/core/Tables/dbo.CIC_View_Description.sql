CREATE TABLE [dbo].[CIC_View_Description]
(
[ViewType] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[ViewName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Notes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Title] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_CIC_View_Description_Title] DEFAULT ('Community Information Database'),
[BottomMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MenuMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MenuTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[MenuGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[CSrchText] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[QuickListName] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_CIC_View_Description_QuickListName] DEFAULT ('Quick&nbsp;List'),
[FeedbackBlurb] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_CIC_View_Description_FeedbackBlurb] DEFAULT ('Note that any submissions made from this page are <B>''suggested''</B> changes. These suggestions are sent to our office where they are reviewed and processed. Upon completion of this form, you will be taken to the existing view of your record (prior to any of your changes). You will be notified once your suggestions have been processed.'),
[TermsOfUseURL] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[InclusionPolicy] [int] NULL,
[SearchTips] [int] NULL,
[SearchLeftTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SearchLeftGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SearchLeftMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SearchCentreTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SearchCentreGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SearchCentreMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SearchRightTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SearchRightGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SearchRightMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SearchAlertTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SearchAlertGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SearchAlertMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[KeywordSearchTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[KeywordSearchGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[OtherSearchTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OtherSearchGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SearchTitleOverride] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[OrganizationNames] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OrganizationsWithWWW] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OrganizationsWithVolOps] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[BrowseByOrg] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[FindAnOrgBy] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ViewProgramsAndServices] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ClickToViewDetails] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OrgProgramNames] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Organization] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[MultipleOrgWithSimilarMap] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OrgLevel1Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OrgLevel2Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OrgLevel3Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[QuickSearchTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[QuickSearchGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[PDFBottomMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PDFBottomMargin] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_CIC_View_Description_PDFBottomMargin] DEFAULT ('1cm'),
[GoogleTranslateDisclaimer] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[TagLine] [nvarchar] (300) COLLATE Latin1_General_100_CI_AI NULL,
[NoResultsMsg] [nvarchar] (2000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[CIC_View_Description] ADD 
CONSTRAINT [PK_CIC_View_Description] PRIMARY KEY CLUSTERED  ([ViewType], [LangID]) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_CIC_View_Description_ViewTypeInclLangID] ON [dbo].[CIC_View_Description] ([ViewType]) INCLUDE ([LangID]) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_Description_ViewTypeLangIDInclName] ON [dbo].[CIC_View_Description] ([ViewType], [LangID]) INCLUDE ([ViewName]) ON [PRIMARY]


























GO

ALTER TABLE [dbo].[CIC_View_Description] ADD CONSTRAINT [FK_CIC_View_Description_GBL_InclusionPolicy] FOREIGN KEY ([InclusionPolicy]) REFERENCES [dbo].[GBL_InclusionPolicy] ([InclusionPolicyID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_Description] ADD CONSTRAINT [FK_CIC_View_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_View_Description] ADD CONSTRAINT [FK_CIC_View_Description_GBL_SearchTips] FOREIGN KEY ([SearchTips]) REFERENCES [dbo].[GBL_SearchTips] ([SearchTipsID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_Description] ADD CONSTRAINT [FK_CIC_View_Description_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_Description] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_View_Description] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_Description] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_Description] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_View_Description] TO [cioc_login_role]
GO
