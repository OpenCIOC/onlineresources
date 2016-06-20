CREATE TABLE [dbo].[CIC_BT_EXTRA_WWW]
(
[BT_EXT_ID] [int] NOT NULL IDENTITY(1, 1),
[FieldName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[Value] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Protocol] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_CIC_BT_EXTRA_WWW_Protocol] DEFAULT ('http://')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_EXTRA_WWW] ADD CONSTRAINT [PK_CIC_BT_EXTRA_WWW] PRIMARY KEY CLUSTERED  ([BT_EXT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_EXTRA_WWW_UniqueField] ON [dbo].[CIC_BT_EXTRA_WWW] ([FieldName], [NUM], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_EXTRA_WWW] ADD CONSTRAINT [FK_CIC_BT_EXTRA_WWW_GBL_FieldOption] FOREIGN KEY ([FieldName]) REFERENCES [dbo].[GBL_FieldOption] ([FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_EXTRA_WWW] ADD CONSTRAINT [FK_CIC_BT_EXTRA_WWW_CIC_BaseTable_Description] FOREIGN KEY ([NUM], [LangID]) REFERENCES [dbo].[CIC_BaseTable_Description] ([NUM], [LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BT_EXTRA_WWW] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_EXTRA_WWW] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_EXTRA_WWW] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_EXTRA_WWW] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BT_EXTRA_WWW] TO [cioc_login_role]
GO
