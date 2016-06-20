CREATE TABLE [dbo].[GBL_PaymentTerms_InactiveByMember]
(
[PYT_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentTerms_InactiveByMember] ADD CONSTRAINT [PK_GBL_PaymentTerms_InactiveByMember] PRIMARY KEY CLUSTERED  ([PYT_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentTerms_InactiveByMember] ADD CONSTRAINT [FK_GBL_PaymentTerms_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_PaymentTerms_InactiveByMember] ADD CONSTRAINT [FK_GBL_PaymentTerms_InactiveByMember_GBL_PaymentTerms] FOREIGN KEY ([PYT_ID]) REFERENCES [dbo].[GBL_PaymentTerms] ([PYT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_PaymentTerms_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_PaymentTerms_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_PaymentTerms_InactiveByMember] TO [cioc_login_role]
GO
