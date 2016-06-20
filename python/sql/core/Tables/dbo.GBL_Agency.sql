CREATE TABLE [dbo].[GBL_Agency]
(
[AgencyID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[AgencyCode] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[RecordOwnerCIC] [bit] NOT NULL CONSTRAINT [DF_GBL_Agency_RecordOwnerCIC] DEFAULT ((0)),
[UpdateEmailCIC] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[UpdatePhoneCIC] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[InquiryPhoneCIC] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[AgencyNUMCIC] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[RecordOwnerVOL] [bit] NOT NULL CONSTRAINT [DF_GBL_Agency_RecordOwnerVOL] DEFAULT ((0)),
[UpdateEmailVOL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[UpdatePhoneVOL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[InquiryPhoneVOL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[AgencyNUMVOL] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[EnforceReqFields] [bit] NOT NULL CONSTRAINT [DF_GBL_Agency_EnforceReqFields] DEFAULT ((0)),
[UpdateAccountEmail] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[UpdateAccountDefault] [bit] NOT NULL CONSTRAINT [DF_GBL_Agency_UpdateAccountDefault] DEFAULT ((1)),
[UpdatePasswordDefault] [bit] NOT NULL CONSTRAINT [DF_GBL_Agency_UpdatePasswordDefault] DEFAULT ((1)),
[UpdateAccountLangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_Agency_UpdateAccountLangID] DEFAULT ((0)),
[NUMSize] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Agency_NUMSize] DEFAULT ((4)),
[GetInvolvedUser] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GetInvolvedToken] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GetInvolvedCommunitySet] [int] NULL,
[GetInvolvedSite] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[VNUMSize] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Agency_VNUMSize] DEFAULT ((4))
) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Agency] WITH NOCHECK ADD
CONSTRAINT [FK_GBL_Agency_GBL_BaseTable_AgencyNUMVOL] FOREIGN KEY ([AgencyNUMVOL]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) NOT FOR REPLICATION
ALTER TABLE [dbo].[GBL_Agency] NOCHECK CONSTRAINT [FK_GBL_Agency_GBL_BaseTable_AgencyNUMVOL]
GO
ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [CK_GBL_Agency_AgencyCode] CHECK (([AgencyCode] like '[A-Z][A-Z][A-Z]'))
GO
ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [CK_GBL_Agency_NUMSize] CHECK (([NUMSize]=(4) OR [NUMSize]=(5)))
GO
ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [PK_Agency] PRIMARY KEY CLUSTERED  ([AgencyID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [IX_Agency] UNIQUE NONCLUSTERED  ([AgencyCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Agency] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Agency_GBL_BaseTable_AgencyNUMCIC] FOREIGN KEY ([AgencyNUMCIC]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) NOT FOR REPLICATION
GO

ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [FK_GBL_Agency_VOL_CommunitySet] FOREIGN KEY ([GetInvolvedCommunitySet]) REFERENCES [dbo].[VOL_CommunitySet] ([CommunitySetID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [FK_GBL_Agency_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_Agency] ADD CONSTRAINT [FK_GBL_Agency_STP_Language] FOREIGN KEY ([UpdateAccountLangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_Agency] NOCHECK CONSTRAINT [FK_GBL_Agency_GBL_BaseTable_AgencyNUMCIC]
GO
GRANT SELECT ON  [dbo].[GBL_Agency] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Agency] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Agency] TO [cioc_vol_search_role]
GO
