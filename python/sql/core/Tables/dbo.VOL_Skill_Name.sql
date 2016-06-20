CREATE TABLE [dbo].[VOL_Skill_Name]
(
[SK_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill_Name] ADD CONSTRAINT [PK_VOL_Skill_Name] PRIMARY KEY CLUSTERED  ([SK_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Skill_Name_UniqueName] ON [dbo].[VOL_Skill_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill_Name] ADD CONSTRAINT [FK_VOL_Skill_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Skill_Name] ADD CONSTRAINT [FK_VOL_Skill_Name_VOL_Skill] FOREIGN KEY ([SK_ID]) REFERENCES [dbo].[VOL_Skill] ([SK_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Skill_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Skill_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Skill_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Skill_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Skill_Name] TO [cioc_vol_search_role]
GO
