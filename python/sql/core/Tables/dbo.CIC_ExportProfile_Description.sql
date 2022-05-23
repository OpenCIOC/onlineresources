CREATE TABLE [dbo].[CIC_ExportProfile_Description]
(
[ProfileID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[MemberID_Cache] [int] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SourceDbName] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SourceDbURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Description] ADD CONSTRAINT [PK_CIC_ExportProfile_Description] PRIMARY KEY CLUSTERED ([ProfileID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_ExportProfile_Description_UniqueName] ON [dbo].[CIC_ExportProfile_Description] ([MemberID_Cache], [LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Description] ADD CONSTRAINT [FK_CIC_ExportProfile_Description_CIC_ExportProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[CIC_ExportProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Description] ADD CONSTRAINT [FK_CIC_ExportProfile_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Description] ADD CONSTRAINT [FK_CIC_ExportProfile_Description_STP_Member] FOREIGN KEY ([MemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
