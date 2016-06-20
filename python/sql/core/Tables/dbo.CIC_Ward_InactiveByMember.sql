CREATE TABLE [dbo].[CIC_Ward_InactiveByMember]
(
[WD_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Ward_InactiveByMember] ADD CONSTRAINT [PK_CIC_Ward_InactiveByMember] PRIMARY KEY CLUSTERED  ([WD_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Ward_InactiveByMember] ADD CONSTRAINT [FK_CIC_Ward_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Ward_InactiveByMember] ADD CONSTRAINT [FK_CIC_Ward_InactiveByMember_CIC_Ward] FOREIGN KEY ([WD_ID]) REFERENCES [dbo].[CIC_Ward] ([WD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Ward_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Ward_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Ward_InactiveByMember] TO [cioc_login_role]
GO
