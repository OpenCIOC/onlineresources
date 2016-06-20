CREATE TABLE [dbo].[VOL_Skill_InactiveByMember]
(
[SK_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill_InactiveByMember] ADD CONSTRAINT [PK_VOL_Skill_InactiveByMember] PRIMARY KEY CLUSTERED  ([SK_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill_InactiveByMember] ADD CONSTRAINT [FK_VOL_Skill_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Skill_InactiveByMember] ADD CONSTRAINT [FK_VOL_Skill_InactiveByMember_VOL_Skill] FOREIGN KEY ([SK_ID]) REFERENCES [dbo].[VOL_Skill] ([SK_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Skill_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Skill_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Skill_InactiveByMember] TO [cioc_login_role]
GO
