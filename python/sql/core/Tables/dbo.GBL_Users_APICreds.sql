CREATE TABLE [dbo].[GBL_Users_APICreds]
(
[CredID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_GBL_Users_APICreds_CredID] DEFAULT (newid()),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[User_ID] [int] NOT NULL,
[PasswordHashRepeat] [int] NOT NULL,
[PasswordHashSalt] [char] (44) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PasswordHash] [char] (44) COLLATE Latin1_General_100_CI_AI NOT NULL,
[UsageNotes] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users_APICreds] ADD CONSTRAINT [PK_GBL_Users_APICreds] PRIMARY KEY CLUSTERED  ([CredID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Users_APICreds] ADD CONSTRAINT [FK_GBL_Users_APICreds_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
