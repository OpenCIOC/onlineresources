CREATE TABLE [dbo].[VOL_Stats_OPID_Accumulator]
(
[Log_ID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[AccessDate] [datetime] NOT NULL CONSTRAINT [DF_VOL_Stats_OPID_Accumulator_AccessDate] DEFAULT (getdate()),
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[OP_ID] [int] NULL,
[LangID] [smallint] NOT NULL,
[User_ID] [int] NULL,
[ViewType] [int] NULL,
[RobotID] [int] NULL,
[API] [bit] NOT NULL CONSTRAINT [DF_VOL_Stats_OPID_Accumulator_API] DEFAULT ((0)),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] ADD CONSTRAINT [PK_VOL_Stats_OPID_Accumulator] PRIMARY KEY CLUSTERED  ([Log_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] ADD CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] ADD CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_VOL_Opportunity] FOREIGN KEY ([OP_ID]) REFERENCES [dbo].[VOL_Opportunity] ([OP_ID]) ON DELETE SET NULL ON UPDATE CASCADE NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE SET NULL NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] NOCHECK CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_VOL_Opportunity]
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] NOCHECK CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_GBL_Users]
GO
ALTER TABLE [dbo].[VOL_Stats_OPID_Accumulator] NOCHECK CONSTRAINT [FK_VOL_Stats_OPID_Accumulator_VOL_View]
GO
GRANT SELECT ON  [dbo].[VOL_Stats_OPID_Accumulator] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Stats_OPID_Accumulator] TO [cioc_vol_search_role]
GO
