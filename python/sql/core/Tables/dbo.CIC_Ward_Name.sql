CREATE TABLE [dbo].[CIC_Ward_Name]
(
[WD_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Ward_Name] ADD CONSTRAINT [PK_CIC_Ward_Name] PRIMARY KEY CLUSTERED  ([WD_ID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Ward_Name_UniqueName] ON [dbo].[CIC_Ward_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Ward_Name] ADD CONSTRAINT [FK_CIC_Ward_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_Ward_Name] ADD CONSTRAINT [FK_CIC_Ward_Name_CIC_Ward] FOREIGN KEY ([WD_ID]) REFERENCES [dbo].[CIC_Ward] ([WD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Ward_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Ward_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Ward_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Ward_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Ward_Name] TO [cioc_login_role]
GO
