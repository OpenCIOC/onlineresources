CREATE TABLE [dbo].[CCR_TypeOfCare_InactiveByMember]
(
[TOC_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfCare_InactiveByMember] ADD CONSTRAINT [PK_CCR_TypeOfCare_InactiveByMember] PRIMARY KEY CLUSTERED  ([TOC_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfCare_InactiveByMember] ADD CONSTRAINT [FK_CCR_TypeOfCare_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CCR_TypeOfCare_InactiveByMember] ADD CONSTRAINT [FK_CCR_TypeOfCare_InactiveByMember_CCR_TypeOfCare] FOREIGN KEY ([TOC_ID]) REFERENCES [dbo].[CCR_TypeOfCare] ([TOC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CCR_TypeOfCare_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_TypeOfCare_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_TypeOfCare_InactiveByMember] TO [cioc_login_role]
GO
