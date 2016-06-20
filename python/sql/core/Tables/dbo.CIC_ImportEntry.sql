CREATE TABLE [dbo].[CIC_ImportEntry]
(
[EF_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[FileName] [varchar] (255) COLLATE Latin1_General_100_CI_AS NOT NULL,
[DisplayName] [varchar] (255) COLLATE Latin1_General_100_CI_AS NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_GBL_ImportEntry_LoadDate] DEFAULT (getdate()),
[LoadedBy] [varchar] (50) COLLATE Latin1_General_100_CI_AS NULL,
[QDate] [datetime] NULL,
[QBy] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[QOwnerConflict] [smallint] NULL,
[QImportSourceDbInfo] [bit] NOT NULL CONSTRAINT [DF_CIC_ImportEntry_QImportSourceDbInfo] DEFAULT ((0)),
[QUnmappedPrivacySkipFields] [bit] NOT NULL CONSTRAINT [DF_CIC_ImportEntry_QUnmappedProfileSkipFields] DEFAULT ((0)),
[QPrivacyProfileConflict] [smallint] NULL,
[QAutoAddPubs] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[QPublicConflict] [smallint] NULL,
[QDeletedConflict] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_CIC_ImportEntry_MemberID] ON [dbo].[CIC_ImportEntry] ([MemberID]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CIC_ImportEntry] ADD CONSTRAINT [CK_CIC_ImportEntry] CHECK (([QOwnerConflict] IS NULL OR [QOwnerConflict]>=(0) AND [QOwnerConflict]<=(2)))
GO
ALTER TABLE [dbo].[CIC_ImportEntry] ADD CONSTRAINT [PK_GBL_ImportEntry] PRIMARY KEY CLUSTERED  ([EF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry] ADD CONSTRAINT [FK_CIC_ImportEntry_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ImportEntry] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ImportEntry] TO [cioc_login_role]
GO
