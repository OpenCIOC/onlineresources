CREATE TABLE [dbo].[CIC_ExportProfile]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[SubmitChangesToAccessURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[IncludePrivacyProfiles] [bit] NOT NULL CONSTRAINT [DF_CIC_ExportProfile_IncludePrivacyProfile] DEFAULT ((0)),
[ConvertLine1Line2Addresses] [bit] NOT NULL CONSTRAINT [DF_CIC_ExportProfile_ConvertLine1Line2Addresses] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile] ADD CONSTRAINT [PK_CIC_ExportProfile] PRIMARY KEY CLUSTERED ([ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile] ADD CONSTRAINT [FK_CIC_ExportProfile_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_ExportProfile] TO [cioc_cic_search_role]
GO
