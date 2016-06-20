CREATE TABLE [dbo].[CIC_BT_ACT_Notes]
(
[BT_ACT_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[ActivityName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ActivityDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Notes] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_ACT_Notes] ADD CONSTRAINT [PK_CIC_BT_ACT_Notes] PRIMARY KEY CLUSTERED  ([BT_ACT_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_ACT_Notes] ADD CONSTRAINT [FK_CIC_BT_ACT_Notes_CIC_BT_ACT] FOREIGN KEY ([BT_ACT_ID]) REFERENCES [dbo].[CIC_BT_ACT] ([BT_ACT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_ACT_Notes] ADD CONSTRAINT [FK_CIC_BT_ACT_Notes_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_BT_ACT_Notes] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_ACT_Notes] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_ACT_Notes] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_ACT_Notes] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BT_ACT_Notes] TO [cioc_login_role]
GO
