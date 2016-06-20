CREATE TABLE [dbo].[VOL_Interest_GetInvolved_Map]
(
[AI_ID] [int] NOT NULL,
[GISkillID] [int] NULL,
[GIInterestID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Interest_GetInvolved_Map] ADD CONSTRAINT [FK_VOL_Interest_GetInvolved_Map_VOL_Interest] FOREIGN KEY ([AI_ID]) REFERENCES [dbo].[VOL_Interest] ([AI_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Interest_GetInvolved_Map] ADD CONSTRAINT [FK_VOL_Interest_GetInvolved_Map_VOL_GetInvolved_Interest] FOREIGN KEY ([GIInterestID]) REFERENCES [dbo].[VOL_GetInvolved_Interest] ([GIInterestID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Interest_GetInvolved_Map] ADD CONSTRAINT [FK_VOL_Interest_GetInvolved_Map_VOL_GetInvolved_Skill] FOREIGN KEY ([GISkillID]) REFERENCES [dbo].[VOL_GetInvolved_Skill] ([GISkillID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
