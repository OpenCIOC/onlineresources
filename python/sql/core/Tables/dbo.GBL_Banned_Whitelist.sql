CREATE TABLE [dbo].[GBL_Banned_Whitelist]
(
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AddedBy_MemberID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Banned_Whitelist] ADD CONSTRAINT [PK__GBL_Banned] PRIMARY KEY CLUSTERED  ([IPAddress]) ON [PRIMARY]
GO
