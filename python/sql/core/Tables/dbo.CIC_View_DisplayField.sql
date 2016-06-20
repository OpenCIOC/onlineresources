CREATE TABLE [dbo].[CIC_View_DisplayField]
(
[DisplayFieldID] [int] NOT NULL IDENTITY(1, 1),
[DisplayFieldGroupID] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_DisplayField] ADD CONSTRAINT [PK_CIC_View_DisplayField] PRIMARY KEY CLUSTERED  ([DisplayFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_DisplayField] ADD CONSTRAINT [IX_CIC_View_DisplayField_UniquePair] UNIQUE NONCLUSTERED  ([DisplayFieldGroupID], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_DisplayField] ADD CONSTRAINT [FK_CIC_View_DisplayField_CIC_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[CIC_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_DisplayField] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_DisplayField_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
