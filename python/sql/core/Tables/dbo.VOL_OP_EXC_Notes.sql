CREATE TABLE [dbo].[VOL_OP_EXC_Notes]
(
[OP_EXC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Notes] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_EXC_Notes] ADD CONSTRAINT [PK_VOL_OP_EXC_Notes] PRIMARY KEY CLUSTERED  ([OP_EXC_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_EXC_Notes] ADD CONSTRAINT [FK_VOL_OP_EXC_Notes_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_OP_EXC_Notes] ADD CONSTRAINT [FK_VOL_OP_EXC_Notes_VOL_OP_EXC] FOREIGN KEY ([OP_EXC_ID]) REFERENCES [dbo].[VOL_OP_EXC] ([OP_EXC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_EXC_Notes] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_OP_EXC_Notes] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_OP_EXC_Notes] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_OP_EXC_Notes] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_EXC_Notes] TO [cioc_vol_search_role]
GO
