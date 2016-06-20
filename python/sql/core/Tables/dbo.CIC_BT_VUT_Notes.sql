CREATE TABLE [dbo].[CIC_BT_VUT_Notes]
(
[BT_VUT_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[ServiceTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Notes] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_VUT_Notes] ADD CONSTRAINT [PK_CIC_BT_VUT_Notes] PRIMARY KEY CLUSTERED  ([BT_VUT_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_VUT_Notes] ON [dbo].[CIC_BT_VUT_Notes] ([BT_VUT_ID], [LangID]) INCLUDE ([Notes]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_VUT_Notes] ADD CONSTRAINT [FK_CIC_BT_VUT_Notes_CIC_BT_VUT] FOREIGN KEY ([BT_VUT_ID]) REFERENCES [dbo].[CIC_BT_VUT] ([BT_VUT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_VUT_Notes] ADD CONSTRAINT [FK_CIC_BT_VUT_Notes_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_BT_VUT_Notes] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_VUT_Notes] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_VUT_Notes] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_VUT_Notes] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BT_VUT_Notes] TO [cioc_login_role]
GO
