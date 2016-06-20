CREATE TABLE [dbo].[GBL_Community_AltName]
(
[CM_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[AltName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_AltName] ADD CONSTRAINT [PK_GBL_Community_AltName] PRIMARY KEY CLUSTERED  ([CM_ID], [LangID], [AltName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_AltName] ADD CONSTRAINT [FK_GBL_Community_AltName_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_AltName] ADD CONSTRAINT [FK_GBL_Community_AltName_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
