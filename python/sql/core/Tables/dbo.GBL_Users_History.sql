CREATE TABLE [dbo].[GBL_Users_History]
(
[User_HST_ID] [int] NOT NULL IDENTITY(1, 1),
[User_ID] [int] NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[UserName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SL_ID_CIC] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SL_ID_VOL] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[StartModule] [tinyint] NULL,
[StartLanguage] [smallint] NULL,
[Agency] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[FirstName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[LastName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Initials] [varchar] (6) COLLATE Latin1_General_100_CI_AI NULL,
[Email] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[PasswordChange] [bit] NOT NULL,
[SavedSearchQuota] [tinyint] NULL,
[SingleLogin] [bit] NULL,
[CanUpdateAccount] [bit] NULL,
[CanUpdatePassword] [bit] NULL,
[Inactive] [bit] NULL,
[NewAccount] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_History_NewAccount] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users_History] ADD CONSTRAINT [PK_GBL_Users_History] PRIMARY KEY CLUSTERED  ([User_HST_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users_History] ADD CONSTRAINT [FK_GBL_Users_History_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
GRANT SELECT ON  [dbo].[GBL_Users_History] TO [cioc_login_role]
GO
