CREATE TABLE [dbo].[GBL_AgeGroup_Name]
(
[AgeGroup_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_AgeGroup_Name] ADD CONSTRAINT [PK_GBL_AgeGroup_Name] PRIMARY KEY CLUSTERED  ([AgeGroup_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_AgeGroup_Name_UniqueName] ON [dbo].[GBL_AgeGroup_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_AgeGroup_Name] ADD CONSTRAINT [FK_GBL_AgeGroup_Name_GBL_AgeGroup] FOREIGN KEY ([AgeGroup_ID]) REFERENCES [dbo].[GBL_AgeGroup] ([AgeGroup_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_AgeGroup_Name] ADD CONSTRAINT [FK_GBL_AgeGroup_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_AgeGroup_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_AgeGroup_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_AgeGroup_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_AgeGroup_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_AgeGroup_Name] TO [cioc_login_role]
GO
