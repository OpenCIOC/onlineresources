CREATE TABLE [dbo].[CIC_RecordType_Name]
(
[RT_ID] [int] NOT NULL CONSTRAINT [DF_CIC_RecordType_Name_RT_ID] DEFAULT ((0)),
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_RecordType_Name] ADD CONSTRAINT [PK_CIC_RecordType_Name] PRIMARY KEY CLUSTERED  ([RT_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_RecordType_Name_UniqueName] ON [dbo].[CIC_RecordType_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_RecordType_Name] ADD CONSTRAINT [FK_CIC_RecordType_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_RecordType_Name] ADD CONSTRAINT [FK_CIC_RecordType_Name_CIC_RecordType_Name] FOREIGN KEY ([RT_ID]) REFERENCES [dbo].[CIC_RecordType] ([RT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_RecordType_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_RecordType_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_RecordType_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_RecordType_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_RecordType_Name] TO [cioc_login_role]
GO
