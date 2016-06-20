CREATE TABLE [dbo].[THS_Source_Name]
(
[SRC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[SourceName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Source_Name] ADD CONSTRAINT [PK_THS_Source_Name] PRIMARY KEY CLUSTERED  ([SRC_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Source_Name] ADD CONSTRAINT [FK_THS_Source_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[THS_Source_Name] ADD CONSTRAINT [FK_THS_Source_Name_THS_Source] FOREIGN KEY ([SRC_ID]) REFERENCES [dbo].[THS_Source] ([SRC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_Source_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Source_Name] TO [cioc_login_role]
GO
