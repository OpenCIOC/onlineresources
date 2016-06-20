CREATE TABLE [dbo].[VOL_OP_SB_Notes]
(
[OP_SB_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Notes] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SB_Notes] ADD CONSTRAINT [PK_VOL_OP_SB_Notes] PRIMARY KEY CLUSTERED  ([OP_SB_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SB_Notes] ADD CONSTRAINT [FK_VOL_OP_SB_Notes_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_OP_SB_Notes] ADD CONSTRAINT [FK_VOL_OP_SB_Notes_VOL_OP_SB] FOREIGN KEY ([OP_SB_ID]) REFERENCES [dbo].[VOL_OP_SB] ([OP_SB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_SB_Notes] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_OP_SB_Notes] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_OP_SB_Notes] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_OP_SB_Notes] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_SB_Notes] TO [cioc_vol_search_role]
GO
