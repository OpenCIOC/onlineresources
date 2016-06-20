CREATE TABLE [dbo].[GBL_ExternalAPI_Description]
(
[API_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Description] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[HelpFileName] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExternalAPI_Description] ADD CONSTRAINT [PK_GBL_ExternalAPI_Description] PRIMARY KEY CLUSTERED  ([API_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExternalAPI_Description] ADD CONSTRAINT [FK_GBL_ExternalAPI_Description_GBL_ExternalAPI] FOREIGN KEY ([API_ID]) REFERENCES [dbo].[GBL_ExternalAPI] ([API_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_ExternalAPI_Description] ADD CONSTRAINT [FK_GBL_ExternalAPI_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
