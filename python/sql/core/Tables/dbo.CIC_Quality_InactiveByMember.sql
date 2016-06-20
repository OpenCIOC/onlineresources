CREATE TABLE [dbo].[CIC_Quality_InactiveByMember]
(
[RQ_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Quality_InactiveByMember] ADD CONSTRAINT [PK_CIC_Quality_InactiveByMember] PRIMARY KEY CLUSTERED  ([RQ_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Quality_InactiveByMember] ADD CONSTRAINT [FK_CIC_Quality_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Quality_InactiveByMember] ADD CONSTRAINT [FK_CIC_Quality_InactiveByMember_CIC_Quality] FOREIGN KEY ([RQ_ID]) REFERENCES [dbo].[CIC_Quality] ([RQ_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Quality_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Quality_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Quality_InactiveByMember] TO [cioc_login_role]
GO
