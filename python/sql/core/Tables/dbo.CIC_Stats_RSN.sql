CREATE TABLE [dbo].[CIC_Stats_RSN]
(
[Log_ID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[AccessDate] [smalldatetime] NOT NULL CONSTRAINT [DF_CIC_Stats_RSN_AccessDate] DEFAULT (getdate()),
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[RSN] [int] NULL,
[LangID] [smallint] NOT NULL,
[User_ID] [int] NULL,
[ViewType] [int] NULL,
[RobotID] [int] NULL,
[API] [bit] NOT NULL CONSTRAINT [DF_CIC_Stats_RSN_API] DEFAULT ((0)),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_MemberIDAccessDateLogID] ON [dbo].[CIC_Stats_RSN] ([MemberID], [AccessDate], [Log_ID]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_MemberIDRSN] ON [dbo].[CIC_Stats_RSN] ([MemberID], [RSN], [User_ID]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [PK_CIC_Stats_RSN] PRIMARY KEY CLUSTERED  ([Log_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_AccessDate] ON [dbo].[CIC_Stats_RSN] ([AccessDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_IPAddress] ON [dbo].[CIC_Stats_RSN] ([IPAddress]) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_RobotID] ON [dbo].[CIC_Stats_RSN] ([RobotID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_RSN] ON [dbo].[CIC_Stats_RSN] ([RSN]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [FK_CIC_Stats_RSN_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [FK_CIC_Stats_RSN_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [FK_CIC_Stats_RSN_GBL_BaseTable] FOREIGN KEY ([RSN]) REFERENCES [dbo].[GBL_BaseTable] ([RSN]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] WITH NOCHECK ADD CONSTRAINT [FK_CIC_Stats_RSN_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] WITH NOCHECK ADD CONSTRAINT [FK_CIC_Stats_RSN_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE SET NULL NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] NOCHECK CONSTRAINT [FK_CIC_Stats_RSN_GBL_Users]
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] NOCHECK CONSTRAINT [FK_CIC_Stats_RSN_CIC_View]
GO
GRANT SELECT ON  [dbo].[CIC_Stats_RSN] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Stats_RSN] TO [cioc_login_role]
GO
