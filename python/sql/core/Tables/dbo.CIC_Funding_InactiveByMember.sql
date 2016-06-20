CREATE TABLE [dbo].[CIC_Funding_InactiveByMember]
(
[FD_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Funding_InactiveByMember] ADD CONSTRAINT [PK_CIC_Funding_InactiveByMember] PRIMARY KEY CLUSTERED  ([FD_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Funding_InactiveByMember] ADD CONSTRAINT [FK_CIC_Funding_InactiveByMember_CIC_Funding] FOREIGN KEY ([FD_ID]) REFERENCES [dbo].[CIC_Funding] ([FD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Funding_InactiveByMember] ADD CONSTRAINT [FK_CIC_Funding_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Funding_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Funding_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Funding_InactiveByMember] TO [cioc_login_role]
GO
