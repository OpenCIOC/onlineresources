CREATE TABLE [dbo].[CIC_View_TopicSearch_Description]
(
[TopicSearchID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[SearchTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SearchDescription] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Heading1Title] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Heading2Title] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Heading1Help] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[Heading2Help] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[CommunityHelp] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[AgeGroupHelp] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[LanguageHelp] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch_Description] ADD CONSTRAINT [PK_CIC_View_TopicSearch_Description] PRIMARY KEY CLUSTERED  ([TopicSearchID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch_Description] ADD CONSTRAINT [FK_CIC_View_TopicSearch_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch_Description] ADD CONSTRAINT [FK_CIC_View_TopicSearch_Description_CIC_View_TopicSearch] FOREIGN KEY ([TopicSearchID]) REFERENCES [dbo].[CIC_View_TopicSearch] ([TopicSearchID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
