CREATE TABLE [dbo].[GBL_PaymentMethod_InactiveByMember]
(
[PAY_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentMethod_InactiveByMember] ADD CONSTRAINT [PK_GBL_PaymentMethod_InactiveByMember] PRIMARY KEY CLUSTERED  ([PAY_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentMethod_InactiveByMember] ADD CONSTRAINT [FK_GBL_PaymentMethod_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_PaymentMethod_InactiveByMember] ADD CONSTRAINT [FK_GBL_PaymentMethod_InactiveByMember_GBL_PaymentMethod] FOREIGN KEY ([PAY_ID]) REFERENCES [dbo].[GBL_PaymentMethod] ([PAY_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_PaymentMethod_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_PaymentMethod_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_PaymentMethod_InactiveByMember] TO [cioc_login_role]
GO
