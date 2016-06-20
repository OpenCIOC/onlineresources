CREATE TABLE [dbo].[GBL_Users]
(
[User_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID_Cache] [int] NOT NULL,
[UserUID] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_GBL_Users_UserUID] DEFAULT (newid()),
[UserName] [varchar] (50) COLLATE Latin1_General_100_CS_AS NOT NULL,
[TechAdmin] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_TechAdmin] DEFAULT ((0)),
[SL_ID_CIC] [int] NULL,
[SL_ID_VOL] [int] NULL,
[StartModule] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Users_StartModule] DEFAULT ((0)),
[StartLanguage] [smallint] NOT NULL CONSTRAINT [DF_GBL_Users_StartLanguage] DEFAULT ((0)),
[Agency] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[FirstName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LastName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Initials] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Email] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[PasswordHashRepeat] [int] NOT NULL,
[PasswordHashSalt] [char] (44) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PasswordHash] [char] (44) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SavedSearchQuota] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Users_SavedSearchQuota] DEFAULT ((50)),
[SingleLogin] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_SingleLogin] DEFAULT ((0)),
[SingleLoginKey] [char] (44) COLLATE Latin1_General_100_CI_AI NULL,
[CanUpdateAccount] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_CanUpdateAccount] DEFAULT ((1)),
[CanUpdatePassword] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_CanUpdateAccount1] DEFAULT ((1)),
[Inactive] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Inactive] DEFAULT ((0)),
[ActiveStatusChanged] [smalldatetime] NULL,
[ActiveStatusChangedBy] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[PasswordChanged] [smalldatetime] NULL,
[PasswordChangedBy] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[LastSuccessfulLogin] [datetime] NULL,
[LastSuccessfulLoginIP] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[LoginAttempts] [tinyint] NULL,
[LastLoginAttempt] [datetime] NULL,
[LastLoginAttemptIP] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users] WITH NOCHECK ADD CONSTRAINT [CK_GBL_Users] CHECK (([StartModule]>(0) AND [StartModule]<=(2)))
GO
ALTER TABLE [dbo].[GBL_Users] ADD CONSTRAINT [PK_GBL_Users] PRIMARY KEY CLUSTERED  ([User_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users] ADD CONSTRAINT [IX_GBL_Users_UniqueUserName] UNIQUE NONCLUSTERED  ([MemberID_Cache], [UserName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users] ADD CONSTRAINT [FK_GBL_Users_GBL_Agency] FOREIGN KEY ([Agency]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Users] ADD CONSTRAINT [FK_GBL_Users_STP_Member] FOREIGN KEY ([MemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_Users] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Users_CIC_SecurityLevel] FOREIGN KEY ([SL_ID_CIC]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID])
GO
ALTER TABLE [dbo].[GBL_Users] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Users_VOL_SecurityLevel] FOREIGN KEY ([SL_ID_VOL]) REFERENCES [dbo].[VOL_SecurityLevel] ([SL_ID])
GO
ALTER TABLE [dbo].[GBL_Users] ADD CONSTRAINT [FK_GBL_Users_STP_Language] FOREIGN KEY ([StartLanguage]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ([User_ID]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([UserName]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([SL_ID_CIC]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([SL_ID_VOL]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([Agency]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([FirstName]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([LastName]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([Initials]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([Email]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ([Inactive]) ON [dbo].[GBL_Users] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Users] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Users] TO [cioc_vol_search_role]
GO
