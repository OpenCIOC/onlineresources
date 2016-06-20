CREATE TABLE [dbo].[CIC_BusRoute_InactiveByMember]
(
[BR_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BusRoute_InactiveByMember] ADD CONSTRAINT [PK_CIC_BusRoute_InactiveByMember] PRIMARY KEY CLUSTERED  ([BR_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BusRoute_InactiveByMember] ADD CONSTRAINT [FK_CIC_BusRoute_InactiveByMember_CIC_BusRoute] FOREIGN KEY ([BR_ID]) REFERENCES [dbo].[CIC_BusRoute] ([BR_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BusRoute_InactiveByMember] ADD CONSTRAINT [FK_CIC_BusRoute_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_BusRoute_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BusRoute_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BusRoute_InactiveByMember] TO [cioc_login_role]
GO
