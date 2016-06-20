CREATE TABLE [dbo].[CIC_View_TopicSearch]
(
[TopicSearchID] [int] NOT NULL IDENTITY(1, 1),
[TopicSearchTag] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ViewType] [int] NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_DisplayOrder] DEFAULT ((0)),
[PB_ID1] [int] NOT NULL,
[Heading1Step] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_Heading1Step] DEFAULT ((1)),
[Heading1ListType] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_Heading1ListType] DEFAULT ((0)),
[PB_ID2] [int] NULL,
[Heading2Step] [tinyint] NULL,
[Heading2ListType] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_Heading2ListType] DEFAULT ((0)),
[Heading2Required] [bit] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_Heading2Required] DEFAULT ((0)),
[CommunityStep] [tinyint] NULL,
[CommunityRequired] [bit] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_CommunityRequired] DEFAULT ((0)),
[CommunityListType] [bit] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_CommunityListType] DEFAULT ((0)),
[AgeGroupStep] [tinyint] NULL,
[AgeGroupRequired] [bit] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_AgeGroupRequired] DEFAULT ((0)),
[LanguageStep] [tinyint] NULL,
[LanguageRequired] [bit] NOT NULL CONSTRAINT [DF_CIC_View_TopicSearch_LanguageRequired] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch] ADD CONSTRAINT [PK_CIC_View_TopicSearch] PRIMARY KEY CLUSTERED  ([TopicSearchID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_TopicSearch] ON [dbo].[CIC_View_TopicSearch] ([ViewType], [TopicSearchTag]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch] ADD CONSTRAINT [FK_CIC_View_TopicSearch_CIC_Publication1] FOREIGN KEY ([PB_ID1]) REFERENCES [dbo].[CIC_Publication] ([PB_ID])
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch] ADD CONSTRAINT [FK_CIC_View_TopicSearch_CIC_Publication2] FOREIGN KEY ([PB_ID2]) REFERENCES [dbo].[CIC_Publication] ([PB_ID])
GO
ALTER TABLE [dbo].[CIC_View_TopicSearch] ADD CONSTRAINT [FK_CIC_View_TopicSearch_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
