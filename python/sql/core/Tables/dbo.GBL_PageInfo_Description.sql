CREATE TABLE [dbo].[GBL_PageInfo_Description]
(
[PageName] [varchar] (255) COLLATE Latin1_General_100_CS_AS NOT NULL,
[LangID] [smallint] NOT NULL,
[PageTitle] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[HelpFileName] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[HelpFileRelease] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[TitleOverride] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Notes] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PageInfo_Description] ADD CONSTRAINT [PK_GBL_PageInfo_Description] PRIMARY KEY CLUSTERED  ([PageName], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PageInfo_Description] ADD CONSTRAINT [FK_GBL_PageInfo_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_PageInfo_Description] ADD CONSTRAINT [FK_GBL_PageInfo_Description_GBL_PageInfo] FOREIGN KEY ([PageName]) REFERENCES [dbo].[GBL_PageInfo] ([PageName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
