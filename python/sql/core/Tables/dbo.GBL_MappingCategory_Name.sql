CREATE TABLE [dbo].[GBL_MappingCategory_Name]
(
[MapCatID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_MappingCategory_Name] ADD CONSTRAINT [PK_GBL_MappingCategory_Name] PRIMARY KEY CLUSTERED  ([MapCatID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_MappingCategory_Name_UniqueName] ON [dbo].[GBL_MappingCategory_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_MappingCategory_Name] ADD CONSTRAINT [FK_GBL_MappingCategory_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_MappingCategory_Name] ADD CONSTRAINT [FK_GBL_MappingCategory_Name_GBL_MappingCategory] FOREIGN KEY ([MapCatID]) REFERENCES [dbo].[GBL_MappingCategory] ([MapCatID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_MappingCategory_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_MappingCategory_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_MappingCategory_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_MappingCategory_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_MappingCategory_Name] TO [cioc_login_role]
GO
