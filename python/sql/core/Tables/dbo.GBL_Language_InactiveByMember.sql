CREATE TABLE [dbo].[GBL_Language_InactiveByMember]
(
[LN_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_InactiveByMember] ADD CONSTRAINT [PK_GBL_Language_InactiveByMember] PRIMARY KEY CLUSTERED  ([LN_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_InactiveByMember] ADD CONSTRAINT [FK_GBL_Language_InactiveByMember_GBL_Language] FOREIGN KEY ([LN_ID]) REFERENCES [dbo].[GBL_Language] ([LN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Language_InactiveByMember] ADD CONSTRAINT [FK_GBL_Language_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_Language_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Language_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Language_InactiveByMember] TO [cioc_login_role]
GO
