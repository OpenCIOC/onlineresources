CREATE TABLE [dbo].[CIC_ServiceLevel_Name]
(
[SL_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel_Name] ADD CONSTRAINT [PK_CIC_ServiceLevel_Name] PRIMARY KEY CLUSTERED  ([SL_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_ServiceLevel_Name_UniqueName] ON [dbo].[CIC_ServiceLevel_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel_Name] ADD CONSTRAINT [FK_CIC_ServiceLevel_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_ServiceLevel_Name] ADD CONSTRAINT [FK_CIC_ServiceLevel_Name_CIC_ServiceLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_ServiceLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ServiceLevel_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ServiceLevel_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ServiceLevel_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ServiceLevel_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ServiceLevel_Name] TO [cioc_login_role]
GO
