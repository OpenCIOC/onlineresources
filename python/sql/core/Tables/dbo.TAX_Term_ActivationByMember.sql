CREATE TABLE [dbo].[TAX_Term_ActivationByMember]
(
[MemberID] [int] NOT NULL,
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Term_ActivationByMember] ADD CONSTRAINT [PK_TAX_Term_ActivationByMember] PRIMARY KEY CLUSTERED  ([MemberID], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAX_Term_ActivationByMember_Code] ON [dbo].[TAX_Term_ActivationByMember] ([Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAX_Term_ActivationByMember_CodeMemberID] ON [dbo].[TAX_Term_ActivationByMember] ([Code], [MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAX_Term_ActivationByMember_MemberID] ON [dbo].[TAX_Term_ActivationByMember] ([MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Term_ActivationByMember] ADD CONSTRAINT [FK_TAX_Term_ActivationByMember_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[TAX_Term_ActivationByMember] ADD CONSTRAINT [FK_TAX_Term_ActivationByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[TAX_Term_ActivationByMember] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[TAX_Term_ActivationByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[TAX_Term_ActivationByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[TAX_Term_ActivationByMember] TO [cioc_login_role]
GO
