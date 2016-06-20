CREATE TABLE [dbo].[CIC_BT_PB_Description]
(
[BT_PB_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_PB_Description] ADD CONSTRAINT [PK_CIC_BT_PB_Description] PRIMARY KEY CLUSTERED  ([BT_PB_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_PB_Description] ADD CONSTRAINT [FK_CIC_BT_PB_Description_CIC_BT_PB] FOREIGN KEY ([BT_PB_ID]) REFERENCES [dbo].[CIC_BT_PB] ([BT_PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_PB_Description] ADD CONSTRAINT [FK_CIC_BT_PB_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_BT_PB_Description] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_PB_Description] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_PB_Description] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_PB_Description] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BT_PB_Description] TO [cioc_login_role]
GO
