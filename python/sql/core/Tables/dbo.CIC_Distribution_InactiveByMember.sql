CREATE TABLE [dbo].[CIC_Distribution_InactiveByMember]
(
[DST_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Distribution_InactiveByMember] ADD CONSTRAINT [PK_CIC_Distribution_InactiveByMember] PRIMARY KEY CLUSTERED  ([DST_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Distribution_InactiveByMember] ADD CONSTRAINT [FK_CIC_Distribution_InactiveByMember_CIC_Distribution] FOREIGN KEY ([DST_ID]) REFERENCES [dbo].[CIC_Distribution] ([DST_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Distribution_InactiveByMember] ADD CONSTRAINT [FK_CIC_Distribution_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Distribution_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Distribution_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Distribution_InactiveByMember] TO [cioc_login_role]
GO
