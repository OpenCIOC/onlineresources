CREATE TABLE [dbo].[GBL_PrivacyProfile]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile] ADD CONSTRAINT [PK_CIC_PrivacyProfile] PRIMARY KEY CLUSTERED  ([ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile] ADD CONSTRAINT [FK_GBL_PrivacyProfile_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_PrivacyProfile] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_PrivacyProfile] TO [cioc_login_role]
GO
