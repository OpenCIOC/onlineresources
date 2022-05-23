CREATE TABLE [dbo].[CIC_ImportEntry_Description]
(
[EF_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[SourceDbName] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SourceDbURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Description] ADD CONSTRAINT [CK_CIC_ImportEntry_Description] CHECK (([SourceDbName] IS NOT NULL OR [SourceDbURL] IS NOT NULL))
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Description] ADD CONSTRAINT [PK_GBL_ImportEntry_Description] PRIMARY KEY CLUSTERED ([EF_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Description] ADD CONSTRAINT [FK_CIC_ImportEntry_Description_CIC_ImportEntry] FOREIGN KEY ([EF_ID]) REFERENCES [dbo].[CIC_ImportEntry] ([EF_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Description] ADD CONSTRAINT [FK_CIC_ImportEntry_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry_Description] TO [cioc_login_role]
GO
