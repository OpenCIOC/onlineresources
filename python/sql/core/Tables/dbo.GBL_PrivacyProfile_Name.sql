CREATE TABLE [dbo].[GBL_PrivacyProfile_Name]
(
[ProfileID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[ProfileName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Name] ADD CONSTRAINT [PK_GBL_PrivacyProfile_Name] PRIMARY KEY CLUSTERED  ([ProfileID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_PrivacyProfile_Name] ON [dbo].[GBL_PrivacyProfile_Name] ([LangID], [ProfileName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Name] ADD CONSTRAINT [FK_GBL_PrivacyProfile_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Name] ADD CONSTRAINT [FK_GBL_PrivacyProfile_Name_GBL_PrivacyProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_PrivacyProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_PrivacyProfile_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_PrivacyProfile_Name] TO [cioc_login_role]
GO
