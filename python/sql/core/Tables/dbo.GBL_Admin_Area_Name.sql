CREATE TABLE [dbo].[GBL_Admin_Area_Name]
(
[AdminAreaID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Admin_Area_Name] ADD CONSTRAINT [PK_GBL_Admin_Area_Name] PRIMARY KEY CLUSTERED  ([AdminAreaID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Admin_Area_Name] ADD CONSTRAINT [FK_GBL_Admin_Area_Name_GBL_Admin_Area] FOREIGN KEY ([AdminAreaID]) REFERENCES [dbo].[GBL_Admin_Area] ([AdminAreaID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Admin_Area_Name] ADD CONSTRAINT [FK_GBL_Admin_Area_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
