CREATE TABLE [dbo].[CIC_FeeType_InactiveByMember]
(
[FT_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_FeeType_InactiveByMember] ADD CONSTRAINT [PK_CIC_FeeType_InactiveByMember] PRIMARY KEY CLUSTERED  ([FT_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_FeeType_InactiveByMember] ADD CONSTRAINT [FK_CIC_FeeType_InactiveByMember_CIC_FeeType] FOREIGN KEY ([FT_ID]) REFERENCES [dbo].[CIC_FeeType] ([FT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_FeeType_InactiveByMember] ADD CONSTRAINT [FK_CIC_FeeType_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_FeeType_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_FeeType_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_FeeType_InactiveByMember] TO [cioc_login_role]
GO
