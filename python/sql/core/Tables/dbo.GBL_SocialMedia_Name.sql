CREATE TABLE [dbo].[GBL_SocialMedia_Name]
(
[SM_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SocialMedia_Name] ADD CONSTRAINT [PK_GBL_SocialMedia_Name] PRIMARY KEY CLUSTERED  ([SM_ID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_SocialMedia_Name_UniqueName] ON [dbo].[GBL_SocialMedia_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SocialMedia_Name] ADD CONSTRAINT [FK_GBL_SocialMedia_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_SocialMedia_Name] ADD CONSTRAINT [FK_GBL_SocialMedia_Name_GBL_SocialMedia] FOREIGN KEY ([SM_ID]) REFERENCES [dbo].[GBL_SocialMedia] ([SM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_SocialMedia_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_SocialMedia_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_SocialMedia_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_SocialMedia_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_SocialMedia_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_SocialMedia_Name] TO [cioc_vol_search_role]
GO
