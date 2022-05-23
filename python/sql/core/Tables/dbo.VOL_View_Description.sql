CREATE TABLE [dbo].[VOL_View_Description]
(
[ViewType] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[ViewName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Notes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Title] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_VOL_View_Description_Title] DEFAULT ('Volunteer Database'),
[BottomMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MenuMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MenuTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[MenuGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[FeedbackBlurb] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_VOL_View_Description_FeedbackBlurb] DEFAULT ('Note that any submissions made from this page are <B>''suggested''</B> changes. These suggestions are sent to our office where they are reviewed and processed. Upon completion of this form, you will be taken to the existing view of your record (prior to any of your changes). You will be notified once your suggestions have been processed.'),
[TermsOfUseURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
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
[SearchPromptOverride] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[KeywordSearchTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[KeywordSearchGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[OtherSearchTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OtherSearchGlyph] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[PDFBottomMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PDFBottomMargin] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_VOL_View_Description_PDFBottomMargin] DEFAULT ('1cm'),
[HighlightOpportunity] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleTranslateDisclaimer] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[TagLine] [nvarchar] (300) COLLATE Latin1_General_100_CI_AI NULL,
[NoResultsMsg] [nvarchar] (2000) COLLATE Latin1_General_100_CI_AI NULL,
[OtherSearchMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_Description] ADD CONSTRAINT [PK_VOL_View_Description] PRIMARY KEY CLUSTERED ([ViewType], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VOL_View_Description_ViewTypeInclLangID] ON [dbo].[VOL_View_Description] ([ViewType]) INCLUDE ([LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_View_Description_ViewTypeLangIDInclName] ON [dbo].[VOL_View_Description] ([ViewType], [LangID]) INCLUDE ([ViewName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_Description] ADD CONSTRAINT [FK_VOL_View_Description_GBL_InclusionPolicy] FOREIGN KEY ([InclusionPolicy]) REFERENCES [dbo].[GBL_InclusionPolicy] ([InclusionPolicyID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_Description] ADD CONSTRAINT [FK_VOL_View_Description_GBL_SearchTips] FOREIGN KEY ([SearchTips]) REFERENCES [dbo].[GBL_SearchTips] ([SearchTipsID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[VOL_View_Description] ADD CONSTRAINT [FK_VOL_View_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_View_Description] ADD CONSTRAINT [FK_VOL_View_Description_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT INSERT ON  [dbo].[VOL_View_Description] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_View_Description] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[VOL_View_Description] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_View_Description] TO [cioc_vol_search_role]
GO
