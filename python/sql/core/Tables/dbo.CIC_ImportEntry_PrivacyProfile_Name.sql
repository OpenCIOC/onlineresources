CREATE TABLE [dbo].[CIC_ImportEntry_PrivacyProfile_Name]
(
[ER_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[ProfileName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_PrivacyProfile_Name] ADD CONSTRAINT [PK_CIC_ImportEntry_PrivacyProfile_Name] PRIMARY KEY CLUSTERED  ([ER_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_PrivacyProfile_Name] ADD CONSTRAINT [FK_CIC_ImportEntry_PrivacyProfile_Name_CIC_ImportEntry_PrivacyProfile] FOREIGN KEY ([ER_ID]) REFERENCES [dbo].[CIC_ImportEntry_PrivacyProfile] ([ER_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ImportEntry_PrivacyProfile_Name] ADD CONSTRAINT [FK_CIC_ImportEntry_PrivacyProfile_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry_PrivacyProfile_Name] TO [cioc_login_role]
GO
