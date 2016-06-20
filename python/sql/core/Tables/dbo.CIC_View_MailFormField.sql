CREATE TABLE [dbo].[CIC_View_MailFormField]
(
[MailFormFieldID] [int] NOT NULL IDENTITY(1, 1),
[FieldID] [int] NOT NULL,
[DisplayFieldGroupID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_MailFormField] ADD CONSTRAINT [PK_CIC_View_MailFormField] PRIMARY KEY CLUSTERED  ([MailFormFieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_MailFormField_UniquePair] ON [dbo].[CIC_View_MailFormField] ([FieldID], [DisplayFieldGroupID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_MailFormField] ADD CONSTRAINT [FK_CIC_View_MailFormField_CIC_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[CIC_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_MailFormField] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_MailFormField_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
