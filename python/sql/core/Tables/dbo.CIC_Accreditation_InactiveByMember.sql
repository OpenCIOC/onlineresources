CREATE TABLE [dbo].[CIC_Accreditation_InactiveByMember]
(
[ACR_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Accreditation_InactiveByMember] ADD CONSTRAINT [PK_CIC_Accreditation_InactiveByMember] PRIMARY KEY CLUSTERED  ([ACR_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Accreditation_InactiveByMember] ADD CONSTRAINT [FK_CIC_Accreditation_InactiveByMember_CIC_Accreditation] FOREIGN KEY ([ACR_ID]) REFERENCES [dbo].[CIC_Accreditation] ([ACR_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Accreditation_InactiveByMember] ADD CONSTRAINT [FK_CIC_Accreditation_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Accreditation_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Accreditation_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Accreditation_InactiveByMember] TO [cioc_login_role]
GO
