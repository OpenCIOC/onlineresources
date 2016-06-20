CREATE TABLE [dbo].[GBL_SharingProfile]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[ShareMemberID] [int] NULL,
[Domain] [int] NULL,
[CanUseAnyView] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanUseAnyView] DEFAULT ((1)),
[CanUpdateRecords] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanUpdateRecords] DEFAULT ((0)),
[CanUsePrint] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanUsePrint] DEFAULT ((1)),
[CanUseExport] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanUseExport] DEFAULT ((1)),
[CanUpdatePubs] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanUpdatePubs] DEFAULT ((1)),
[CanViewFeedback] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanViewFeedback] DEFAULT ((1)),
[CanViewPrivate] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_CanViewPrivate] DEFAULT ((0)),
[RevocationPeriod] [smallint] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_RevocationPeriod] DEFAULT ((7)),
[ReadyToAccept] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_ReadyToAccept] DEFAULT ((0)),
[SentDate] [datetime] NULL,
[SentBy] [int] NULL,
[AcceptedDate] [datetime] NULL,
[AcceptedBy] [int] NULL,
[RevokedDate] [datetime] NULL,
[RevokedBy] [int] NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_GBL_SharingProfile_Active] DEFAULT ((0)),
[NotifyEmailAddresses] [varchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[ShareNotifyEmailAddresses] [varchar] (1000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [CK_GBL_SharingProfile] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [CK_GBL_SharingProfile_Active] CHECK (([dbo].[fn_GBL_SharingProfile_CheckActive]([AcceptedDate],[RevokedDate],[Active])=(1)))
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [PK_GBL_SharingProfile] PRIMARY KEY CLUSTERED  ([ProfileID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_SharingProfile_ProfileIDShareMemberID] ON [dbo].[GBL_SharingProfile] ([ProfileID], [ShareMemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [FK_GBL_SharingProfile_GBL_Users_AcceptedUser] FOREIGN KEY ([AcceptedBy]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [FK_GBL_SharingProfile_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [FK_GBL_SharingProfile_GBL_Users_RevokedUser] FOREIGN KEY ([RevokedBy]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
ALTER TABLE [dbo].[GBL_SharingProfile] ADD CONSTRAINT [FK_GBL_SharingProfile_STP_Member1] FOREIGN KEY ([ShareMemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_SharingProfile] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_SharingProfile] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_SharingProfile] TO [cioc_vol_search_role]
GO
