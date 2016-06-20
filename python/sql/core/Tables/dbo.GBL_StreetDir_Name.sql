CREATE TABLE [dbo].[GBL_StreetDir_Name]
(
[Dir] [varchar] (2) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StreetDir_Name] ADD CONSTRAINT [PK_GBL_StreetDir_Name] PRIMARY KEY CLUSTERED  ([Dir], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_StreetDir_Name_UniqueName] ON [dbo].[GBL_StreetDir_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StreetDir_Name] ADD CONSTRAINT [FK_GBL_StreetDir_Name_GBL_StreetDir] FOREIGN KEY ([Dir]) REFERENCES [dbo].[GBL_StreetDir] ([Dir]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_StreetDir_Name] ADD CONSTRAINT [FK_GBL_StreetDir_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_StreetDir_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_StreetDir_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_StreetDir_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_StreetDir_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_StreetDir_Name] TO [cioc_login_role]
GO
