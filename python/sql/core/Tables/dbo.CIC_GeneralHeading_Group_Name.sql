CREATE TABLE [dbo].[CIC_GeneralHeading_Group_Name]
(
[GroupID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Group_Name] ADD CONSTRAINT [PK_CIC_GeneralHeading_Group_Name] PRIMARY KEY CLUSTERED  ([GroupID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Group_Name] ADD CONSTRAINT [FK_CIC_GeneralHeading_Group_Name_CIC_GeneralHeading_Group] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[CIC_GeneralHeading_Group] ([GroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Group_Name] ADD CONSTRAINT [FK_CIC_GeneralHeading_Group_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Group_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Group_Name] TO [cioc_login_role]
GO
