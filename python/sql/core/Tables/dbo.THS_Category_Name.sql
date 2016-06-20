CREATE TABLE [dbo].[THS_Category_Name]
(
[SubjCat_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Category] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Category_Name] ADD CONSTRAINT [PK_THS_Category_Name] PRIMARY KEY CLUSTERED  ([SubjCat_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Category_Name] ADD CONSTRAINT [FK_THS_Category_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[THS_Category_Name] ADD CONSTRAINT [FK_THS_Category_Name_THS_Category] FOREIGN KEY ([SubjCat_ID]) REFERENCES [dbo].[THS_Category] ([SubjCat_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_Category_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Category_Name] TO [cioc_login_role]
GO
