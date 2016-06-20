CREATE TABLE [dbo].[THS_SBJ_BroaderTerm]
(
[BDTerm_ID] [int] NOT NULL IDENTITY(1, 1),
[Subj_ID] [int] NOT NULL,
[BroaderSubj_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_BroaderTerm] ADD CONSTRAINT [CK_THS_SBJ_BroaderTerm] CHECK (([Subj_ID]<>[BroaderSubj_ID]))
GO
ALTER TABLE [dbo].[THS_SBJ_BroaderTerm] ADD CONSTRAINT [PK_THS_SBJ_BroaderTerm] PRIMARY KEY CLUSTERED  ([BDTerm_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_BroaderTerm] ADD CONSTRAINT [IX_THS_SBJ_BroaderTerm_UniquePair] UNIQUE NONCLUSTERED  ([Subj_ID], [BroaderSubj_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_BroaderTerm] ADD CONSTRAINT [FK_THS_SBJ_BroaderTerm_THS_Subject1] FOREIGN KEY ([BroaderSubj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID])
GO
ALTER TABLE [dbo].[THS_SBJ_BroaderTerm] ADD CONSTRAINT [FK_THS_SBJ_BroaderTerm_THS_Subject] FOREIGN KEY ([Subj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_SBJ_BroaderTerm] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_SBJ_BroaderTerm] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[THS_SBJ_BroaderTerm] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[THS_SBJ_BroaderTerm] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[THS_SBJ_BroaderTerm] TO [cioc_login_role]
GO
