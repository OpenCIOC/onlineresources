CREATE TABLE [dbo].[GBL_Accessibility_InactiveByMember]
(
[AC_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Accessibility_InactiveByMember] ADD CONSTRAINT [PK_GBL_Accessibility_InactiveByMember] PRIMARY KEY CLUSTERED  ([AC_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Accessibility_InactiveByMember] ADD CONSTRAINT [FK_GBL_Accessibility_InactiveByMember_GBL_Accessibility] FOREIGN KEY ([AC_ID]) REFERENCES [dbo].[GBL_Accessibility] ([AC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Accessibility_InactiveByMember] ADD CONSTRAINT [FK_GBL_Accessibility_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_Accessibility_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Accessibility_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Accessibility_InactiveByMember] TO [cioc_login_role]
GO
