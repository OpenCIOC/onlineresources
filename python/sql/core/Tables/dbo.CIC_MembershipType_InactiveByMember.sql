CREATE TABLE [dbo].[CIC_MembershipType_InactiveByMember]
(
[MT_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_MembershipType_InactiveByMember] ADD CONSTRAINT [PK_CIC_MembershipType_InactiveByMember] PRIMARY KEY CLUSTERED  ([MT_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_MembershipType_InactiveByMember] ADD CONSTRAINT [FK_CIC_MembershipType_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_MembershipType_InactiveByMember] ADD CONSTRAINT [FK_CIC_MembershipType_InactiveByMember_CIC_MembershipType] FOREIGN KEY ([MT_ID]) REFERENCES [dbo].[CIC_MembershipType] ([MT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_MembershipType_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_MembershipType_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_MembershipType_InactiveByMember] TO [cioc_login_role]
GO
