CREATE TABLE [dbo].[VOL_InteractionLevel_InactiveByMember]
(
[IL_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_InteractionLevel_InactiveByMember] ADD CONSTRAINT [PK_VOL_InteractionLevel_InactiveByMember] PRIMARY KEY CLUSTERED  ([IL_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_InteractionLevel_InactiveByMember] ADD CONSTRAINT [FK_VOL_InteractionLevel_InactiveByMember_VOL_InteractionLevel] FOREIGN KEY ([IL_ID]) REFERENCES [dbo].[VOL_InteractionLevel] ([IL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_InteractionLevel_InactiveByMember] ADD CONSTRAINT [FK_VOL_InteractionLevel_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_InteractionLevel_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_InteractionLevel_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_InteractionLevel_InactiveByMember] TO [cioc_login_role]
GO
