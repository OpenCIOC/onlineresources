CREATE TABLE [dbo].[CIC_Distribution_Name]
(
[DST_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Distribution_Name] ADD CONSTRAINT [PK_CIC_Distribution_Name] PRIMARY KEY CLUSTERED  ([DST_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Distribution_Name_UniqueName] ON [dbo].[CIC_Distribution_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Distribution_Name] ADD CONSTRAINT [FK_CIC_Distribution_Name_CIC_Distribution] FOREIGN KEY ([DST_ID]) REFERENCES [dbo].[CIC_Distribution] ([DST_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Distribution_Name] ADD CONSTRAINT [FK_CIC_Distribution_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_Distribution_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Distribution_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Distribution_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Distribution_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Distribution_Name] TO [cioc_login_role]
GO
