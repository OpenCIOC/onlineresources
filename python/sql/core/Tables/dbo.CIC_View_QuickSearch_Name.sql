CREATE TABLE [dbo].[CIC_View_QuickSearch_Name]
(
[QuickSearchID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_QuickSearch_Name] ADD CONSTRAINT [PK_CIC_View_QuickSearch_Name] PRIMARY KEY CLUSTERED  ([QuickSearchID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_QuickSearch_Name] ADD CONSTRAINT [FK_CIC_View_QuickSearch_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_QuickSearch_Name] ADD CONSTRAINT [FK_CIC_View_QuickSearch_Name_CIC_View_QuickSearch] FOREIGN KEY ([QuickSearchID]) REFERENCES [dbo].[CIC_View_QuickSearch] ([QuickSearchID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
