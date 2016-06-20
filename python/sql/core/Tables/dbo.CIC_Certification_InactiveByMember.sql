CREATE TABLE [dbo].[CIC_Certification_InactiveByMember]
(
[CRT_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Certification_InactiveByMember] ADD CONSTRAINT [PK_CIC_Certification_InactiveByMember] PRIMARY KEY CLUSTERED  ([CRT_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Certification_InactiveByMember] ADD CONSTRAINT [FK_CIC_Certification_InactiveByMember_CIC_Certification] FOREIGN KEY ([CRT_ID]) REFERENCES [dbo].[CIC_Certification] ([CRT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Certification_InactiveByMember] ADD CONSTRAINT [FK_CIC_Certification_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Certification_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Certification_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Certification_InactiveByMember] TO [cioc_login_role]
GO
