CREATE TABLE [dbo].[VOL_View_DisplayFieldGroup_Name]
(
[DisplayFieldGroupID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayFieldGroup_Name] ADD CONSTRAINT [PK_VOL_View_DisplayFieldGroup_Name] PRIMARY KEY CLUSTERED ([DisplayFieldGroupID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayFieldGroup_Name] ADD CONSTRAINT [FK_VOL_View_DisplayFieldGroup_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_View_DisplayFieldGroup_Name] ADD CONSTRAINT [FK_VOL_View_DisplayFieldGroup_Name_VOL_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[VOL_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
