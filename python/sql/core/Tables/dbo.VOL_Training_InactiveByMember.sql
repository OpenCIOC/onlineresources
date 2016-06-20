CREATE TABLE [dbo].[VOL_Training_InactiveByMember]
(
[TRN_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Training_InactiveByMember] ADD CONSTRAINT [PK_VOL_Training_InactiveByMember] PRIMARY KEY CLUSTERED  ([TRN_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Training_InactiveByMember] ADD CONSTRAINT [FK_VOL_Training_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Training_InactiveByMember] ADD CONSTRAINT [FK_VOL_Training_InactiveByMember_VOL_Training] FOREIGN KEY ([TRN_ID]) REFERENCES [dbo].[VOL_Training] ([TRN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Training_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Training_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Training_InactiveByMember] TO [cioc_login_role]
GO
