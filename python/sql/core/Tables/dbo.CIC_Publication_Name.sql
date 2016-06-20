CREATE TABLE [dbo].[CIC_Publication_Name]
(
[PB_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Notes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Publication_Name] ADD CONSTRAINT [CK_CIC_Publication_Name] CHECK (([Name] IS NOT NULL OR [Notes] IS NOT NULL))
GO
ALTER TABLE [dbo].[CIC_Publication_Name] ADD CONSTRAINT [PK_CIC_Publication_Name] PRIMARY KEY CLUSTERED  ([PB_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Publication_Name] ADD CONSTRAINT [FK_CIC_Publication_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_Publication_Name] ADD CONSTRAINT [FK_CIC_Publication_Name_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Publication_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Publication_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Publication_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Publication_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Publication_Name] TO [cioc_login_role]
GO
