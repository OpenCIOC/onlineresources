CREATE TABLE [dbo].[CIC_View_UpdateField]
(
[UpdateFieldID] [int] NOT NULL IDENTITY(1, 1),
[FieldID] [int] NOT NULL,
[DisplayFieldGroupID] [int] NOT NULL,
[RT_ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_UpdateField] ADD CONSTRAINT [PK_CIC_View_UpdateField] PRIMARY KEY CLUSTERED  ([UpdateFieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_UpdateField_UniquePair] ON [dbo].[CIC_View_UpdateField] ([FieldID], [DisplayFieldGroupID], [RT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_UpdateField] ADD CONSTRAINT [FK_CIC_View_UpdateField_CIC_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[CIC_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_UpdateField] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_UpdateField_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_UpdateField] ADD CONSTRAINT [FK_CIC_View_UpdateField_CIC_RecordType] FOREIGN KEY ([RT_ID]) REFERENCES [dbo].[CIC_RecordType] ([RT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
