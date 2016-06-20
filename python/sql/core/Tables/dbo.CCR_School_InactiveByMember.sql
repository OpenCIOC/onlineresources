CREATE TABLE [dbo].[CCR_School_InactiveByMember]
(
[SCH_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_School_InactiveByMember] ADD CONSTRAINT [PK_CCR_School_InactiveByMember] PRIMARY KEY CLUSTERED  ([SCH_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_School_InactiveByMember] ADD CONSTRAINT [FK_CCR_School_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CCR_School_InactiveByMember] ADD CONSTRAINT [FK_CCR_School_InactiveByMember_CCR_School] FOREIGN KEY ([SCH_ID]) REFERENCES [dbo].[CCR_School] ([SCH_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CCR_School_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_School_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_School_InactiveByMember] TO [cioc_login_role]
GO
