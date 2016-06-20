CREATE TABLE [dbo].[VOL_Skill_GetInvolved_Map]
(
[SK_ID] [int] NOT NULL,
[GISkillID] [int] NULL,
[GIInterestID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill_GetInvolved_Map] ADD CONSTRAINT [FK_VOL_Skill_GetInvolved_Map_VOL_GetInvolved_Interest] FOREIGN KEY ([GIInterestID]) REFERENCES [dbo].[VOL_GetInvolved_Interest] ([GIInterestID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Skill_GetInvolved_Map] ADD CONSTRAINT [FK_VOL_Skill_GetInvolved_Map_VOL_GetInvolved_Skill] FOREIGN KEY ([GISkillID]) REFERENCES [dbo].[VOL_GetInvolved_Skill] ([GISkillID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Skill_GetInvolved_Map] ADD CONSTRAINT [FK_VOL_Skill_GetInvolved_Map_VOL_Skill] FOREIGN KEY ([SK_ID]) REFERENCES [dbo].[VOL_Skill] ([SK_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
