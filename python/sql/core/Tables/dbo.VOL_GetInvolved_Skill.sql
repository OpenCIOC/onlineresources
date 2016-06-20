CREATE TABLE [dbo].[VOL_GetInvolved_Skill]
(
[GISkillID] [int] NOT NULL IDENTITY(1, 1),
[GISkillName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_GetInvolved_Skill] ADD CONSTRAINT [PK_VOL_GetInvolved_Skill] PRIMARY KEY CLUSTERED  ([GISkillID]) ON [PRIMARY]
GO
