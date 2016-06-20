CREATE TABLE [dbo].[VOL_Transportation_InactiveByMember]
(
[TRP_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Transportation_InactiveByMember] ADD CONSTRAINT [PK_VOL_Transportation_InactiveByMember] PRIMARY KEY CLUSTERED  ([TRP_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Transportation_InactiveByMember] ADD CONSTRAINT [FK_VOL_Transportation_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Transportation_InactiveByMember] ADD CONSTRAINT [FK_VOL_Transportation_InactiveByMember_VOL_Transportation] FOREIGN KEY ([TRP_ID]) REFERENCES [dbo].[VOL_Transportation] ([TRP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Transportation_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Transportation_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Transportation_InactiveByMember] TO [cioc_login_role]
GO
