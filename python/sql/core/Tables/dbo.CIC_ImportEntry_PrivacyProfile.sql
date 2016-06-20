CREATE TABLE [dbo].[CIC_ImportEntry_PrivacyProfile]
(
[ER_ID] [int] NOT NULL IDENTITY(1, 1),
[EF_ID] [int] NOT NULL,
[FieldNames] [varchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[QPrivacyMap] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_PrivacyProfile] ADD CONSTRAINT [PK_CIC_ImportEntry_PrivacyProfile] PRIMARY KEY CLUSTERED  ([ER_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_PrivacyProfile] ADD CONSTRAINT [FK_CIC_ImportEntry_PrivacyProfile_CIC_ImportEntry] FOREIGN KEY ([EF_ID]) REFERENCES [dbo].[CIC_ImportEntry] ([EF_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ImportEntry_PrivacyProfile] ADD CONSTRAINT [FK_CIC_ImportEntry_PrivacyProfile_GBL_PrivacyProfile] FOREIGN KEY ([QPrivacyMap]) REFERENCES [dbo].[GBL_PrivacyProfile] ([ProfileID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry_PrivacyProfile] TO [cioc_login_role]
GO
