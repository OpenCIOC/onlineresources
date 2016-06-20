CREATE TABLE [dbo].[TAX_Term_ParentList]
(
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ParentCode] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Term_ParentList] ADD CONSTRAINT [PK_TAX_Term_ParentList] PRIMARY KEY CLUSTERED  ([Code], [ParentCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAX_Term_ParentList_CodeInclParentCode] ON [dbo].[TAX_Term_ParentList] ([Code]) INCLUDE ([ParentCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAX_Term_ParentList_ParentCode] ON [dbo].[TAX_Term_ParentList] ([ParentCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Term_ParentList] ADD CONSTRAINT [FK_TAX_Term_ParentList_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[TAX_Term_ParentList] ADD CONSTRAINT [FK_TAX_Term_ParentList_TAX_Term_Parent] FOREIGN KEY ([ParentCode]) REFERENCES [dbo].[TAX_Term] ([Code])
GO
GRANT SELECT ON  [dbo].[TAX_Term_ParentList] TO [cioc_login_role]
GO
