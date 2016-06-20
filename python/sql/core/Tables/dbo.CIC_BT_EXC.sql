CREATE TABLE [dbo].[CIC_BT_EXC]
(
[BT_EXC_ID] [int] NOT NULL IDENTITY(1, 1),
[FieldName_Cache] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[EXC_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_EXC] ADD CONSTRAINT [PK_CIC_BT_EXC] PRIMARY KEY CLUSTERED  ([BT_EXC_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_EXC_UniquePair] ON [dbo].[CIC_BT_EXC] ([NUM], [EXC_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_EXC] ADD CONSTRAINT [FK_CIC_BT_EXC_CIC_ExtraCheckList] FOREIGN KEY ([EXC_ID], [FieldName_Cache]) REFERENCES [dbo].[CIC_ExtraCheckList] ([EXC_ID], [FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_EXC] ADD CONSTRAINT [FK_CIC_BT_EXC_CIC_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[CIC_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BT_EXC] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_EXC] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_EXC] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_EXC] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BT_EXC] TO [cioc_login_role]
GO
