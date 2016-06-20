CREATE TABLE [dbo].[CIC_RecordType_InactiveByMember]
(
[RT_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_RecordType_InactiveByMember] ADD CONSTRAINT [PK_CIC_RecordType_InactiveByMember] PRIMARY KEY CLUSTERED  ([RT_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_RecordType_InactiveByMember] ADD CONSTRAINT [FK_CIC_RecordType_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_RecordType_InactiveByMember] ADD CONSTRAINT [FK_CIC_RecordType_InactiveByMember_CIC_RecordType] FOREIGN KEY ([RT_ID]) REFERENCES [dbo].[CIC_RecordType] ([RT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_RecordType_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_RecordType_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_RecordType_InactiveByMember] TO [cioc_login_role]
GO
