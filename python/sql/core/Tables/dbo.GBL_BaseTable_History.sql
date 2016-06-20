CREATE TABLE [dbo].[GBL_BaseTable_History]
(
[HST_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_GBL_BaseTable_History_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[FieldID] [int] NOT NULL,
[FieldDisplay] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_History_HSTIDNUMLangID] ON [dbo].[GBL_BaseTable_History] ([HST_ID], [NUM], [LangID]) WITH (FILLFACTOR=80) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_History_MODIFIEDDATEHSTIDNUMLangID] ON [dbo].[GBL_BaseTable_History] ([MODIFIED_DATE], [HST_ID], [NUM], [LangID]) WITH (FILLFACTOR=80) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_History_NUMFieldIDHSTIDInclLangID] ON [dbo].[GBL_BaseTable_History] ([NUM], [FieldID], [HST_ID]) INCLUDE ([LangID]) WITH (FILLFACTOR=80) ON [PRIMARY]

GO
ALTER TABLE [dbo].[GBL_BaseTable_History] ADD CONSTRAINT [PK_GBL_BaseTable_History] PRIMARY KEY CLUSTERED  ([HST_ID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GBL_BaseTable_History] ADD CONSTRAINT [FK_GBL_BaseTable_History_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BaseTable_History] ADD CONSTRAINT [FK_GBL_BaseTable_History_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_BaseTable_History] ADD CONSTRAINT [FK_GBL_BaseTable_History_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_BaseTable_History] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BaseTable_History] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_BaseTable_History] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_BaseTable_History] TO [cioc_login_role]
GO
