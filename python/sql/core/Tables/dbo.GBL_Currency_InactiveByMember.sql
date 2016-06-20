CREATE TABLE [dbo].[GBL_Currency_InactiveByMember]
(
[CUR_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Currency_InactiveByMember] ADD CONSTRAINT [PK_GBL_Currency_InactiveByMember] PRIMARY KEY CLUSTERED  ([CUR_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Currency_InactiveByMember] ADD CONSTRAINT [FK_GBL_Currency_InactiveByMember_GBL_Currency] FOREIGN KEY ([CUR_ID]) REFERENCES [dbo].[GBL_Currency] ([CUR_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Currency_InactiveByMember] ADD CONSTRAINT [FK_GBL_Currency_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_Currency_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Currency_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Currency_InactiveByMember] TO [cioc_login_role]
GO
