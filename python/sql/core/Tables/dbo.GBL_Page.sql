CREATE TABLE [dbo].[GBL_Page]
(
[PageID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Page_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Page_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[DM] [tinyint] NOT NULL,
[LangID] [smallint] NOT NULL,
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[Slug] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Title] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PageContent] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PublishAsArticle] [bit] NOT NULL CONSTRAINT [DF_GBL_Page_Article] DEFAULT ((0)),
[Author] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayPublishDate] [smalldatetime] NULL,
[Category] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[PreviewText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ThumbnailImageURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Page] ADD CONSTRAINT [PK_GBL_Page] PRIMARY KEY CLUSTERED ([PageID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Page] ADD CONSTRAINT [IX_GBL_Page] UNIQUE NONCLUSTERED ([MemberID], [DM], [LangID], [Slug]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Page] ADD CONSTRAINT [FK_GBL_Page_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
