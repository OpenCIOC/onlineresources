CREATE TABLE [dbo].[CIC_FiscalYearEnd_InactiveByMember]
(
[FYE_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_FiscalYearEnd_InactiveByMember] ADD CONSTRAINT [PK_CIC_FiscalYearEnd_InactiveByMember] PRIMARY KEY CLUSTERED  ([FYE_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_FiscalYearEnd_InactiveByMember] ADD CONSTRAINT [FK_CIC_FiscalYearEnd_InactiveByMember_CIC_FiscalYearEnd] FOREIGN KEY ([FYE_ID]) REFERENCES [dbo].[CIC_FiscalYearEnd] ([FYE_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_FiscalYearEnd_InactiveByMember] ADD CONSTRAINT [FK_CIC_FiscalYearEnd_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_FiscalYearEnd_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_FiscalYearEnd_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_FiscalYearEnd_InactiveByMember] TO [cioc_login_role]
GO
