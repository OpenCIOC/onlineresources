CREATE TABLE [dbo].[GBL_Banned]
(
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LoginBanOnly] [bit] NOT NULL CONSTRAINT [DF_GBL_Banned_LoginBanOnly] DEFAULT ((0))
) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Banned] ADD 
CONSTRAINT [PK_GBL_Banned] PRIMARY KEY CLUSTERED  ([IPAddress]) ON [PRIMARY]
GO
