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
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [PK_CIC_Stats_RSN] PRIMARY KEY CLUSTERED ([Log_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_AccessDate] ON [dbo].[CIC_Stats_RSN] ([AccessDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_IPAddress] ON [dbo].[CIC_Stats_RSN] ([IPAddress]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_MemberIDAccessDateViewTypeIPAddress_incLogIDRSNUserIDNUM] ON [dbo].[CIC_Stats_RSN] ([MemberID], [AccessDate], [ViewType], [IPAddress]) INCLUDE ([Log_ID], [RSN], [User_ID], [NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_MemberIDViewTypeRSN_incAccessDateUserID] ON [dbo].[CIC_Stats_RSN] ([MemberID], [ViewType], [RSN]) INCLUDE ([AccessDate], [User_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_Stats_RSN_RobotID] ON [dbo].[CIC_Stats_RSN] ([RobotID]) ON [PRIMARY]
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_AccessDateRSNLogID] ON [dbo].[CIC_Stats_RSN] ([AccessDate], [RSN], [Log_ID])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_IPAddressMemberIDAccessDate] ON [dbo].[CIC_Stats_RSN] ([IPAddress], [MemberID], [AccessDate])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_MemberIDAccessDateUserID] ON [dbo].[CIC_Stats_RSN] ([MemberID], [AccessDate], [User_ID])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_MemberIDUserIDLogID] ON [dbo].[CIC_Stats_RSN] ([MemberID], [User_ID], [Log_ID], [RSN])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_NUMMemberIDAccessDateRSN] ON [dbo].[CIC_Stats_RSN] ([NUM], [MemberID], [AccessDate], [RSN])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_NUMMemberIDAccessDateUserID] ON [dbo].[CIC_Stats_RSN] ([NUM], [MemberID], [AccessDate], [User_ID])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNAccessDate] ON [dbo].[CIC_Stats_RSN] ([RSN], [AccessDate])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNMemberIDAccessDate] ON [dbo].[CIC_Stats_RSN] ([RSN], [MemberID], [AccessDate])
GO
CREATE STATISTICS [IX_CIC_Stats_RSN_RSNMemberIDAccessDateIPAddress] ON [dbo].[CIC_Stats_RSN] ([RSN], [MemberID], [AccessDate], [IPAddress])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNMemberIDAccessDateLogIDIPAddress] ON [dbo].[CIC_Stats_RSN] ([RSN], [MemberID], [AccessDate], [Log_ID], [IPAddress])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNMemberIDLogID] ON [dbo].[CIC_Stats_RSN] ([RSN], [MemberID], [Log_ID])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNMemberIDViewType] ON [dbo].[CIC_Stats_RSN] ([RSN], [MemberID], [ViewType])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNNUMAccessDate] ON [dbo].[CIC_Stats_RSN] ([RSN], [NUM], [AccessDate])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNNUMMemberID] ON [dbo].[CIC_Stats_RSN] ([RSN], [NUM], [MemberID])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNUserIDMemberIDAccessDate] ON [dbo].[CIC_Stats_RSN] ([RSN], [User_ID], [MemberID], [AccessDate])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNUserIDNUMAccessDateMemberID] ON [dbo].[CIC_Stats_RSN] ([RSN], [User_ID], [NUM], [AccessDate], [MemberID])
GO
CREATE STATISTICS [IX_CIC_Stats_RSN_RSNUserIDNUMMemberID] ON [dbo].[CIC_Stats_RSN] ([RSN], [User_ID], [NUM], [MemberID])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_RSNViewtype] ON [dbo].[CIC_Stats_RSN] ([RSN], [ViewType])
GO
CREATE STATISTICS [ST_CIC_Stats_RSN_ViewTypeMemberID] ON [dbo].[CIC_Stats_RSN] ([ViewType], [MemberID])
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] WITH NOCHECK ADD CONSTRAINT [FK_CIC_Stats_RSN_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE SET NULL NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [FK_CIC_Stats_RSN_GBL_BaseTable] FOREIGN KEY ([RSN]) REFERENCES [dbo].[GBL_BaseTable] ([RSN]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] WITH NOCHECK ADD CONSTRAINT [FK_CIC_Stats_RSN_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [FK_CIC_Stats_RSN_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] ADD CONSTRAINT [FK_CIC_Stats_RSN_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] NOCHECK CONSTRAINT [FK_CIC_Stats_RSN_CIC_View]
GO
ALTER TABLE [dbo].[CIC_Stats_RSN] NOCHECK CONSTRAINT [FK_CIC_Stats_RSN_GBL_Users]
GO
GRANT SELECT ON  [dbo].[CIC_Stats_RSN] TO [cioc_cic_search_role]
GO
GRANT SELECT ON  [dbo].[CIC_Stats_RSN] TO [cioc_login_role]
GO
