CREATE TABLE [dbo].[GBL_RecordNote_Type_Name]
(
[NoteTypeID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_RecordNote_Type_Name] ADD CONSTRAINT [PK_GBL_NoteType_Name] PRIMARY KEY CLUSTERED  ([NoteTypeID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_RecordNote_Type_Name] ADD CONSTRAINT [FK_GBL_NoteType_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_RecordNote_Type_Name] ADD CONSTRAINT [FK_GBL_RecordNote_Type_Name_GBL_RecordNote_Type] FOREIGN KEY ([NoteTypeID]) REFERENCES [dbo].[GBL_RecordNote_Type] ([NoteTypeID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_RecordNote_Type_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_RecordNote_Type_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_RecordNote_Type_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_RecordNote_Type_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_RecordNote_Type_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_RecordNote_Type_Name] TO [cioc_vol_search_role]
GO
