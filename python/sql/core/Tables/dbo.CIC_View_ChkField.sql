CREATE TABLE [dbo].[CIC_View_ChkField]
(
[ChkFieldID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_ChkField] ADD CONSTRAINT [PK_CIC_View_ChkField] PRIMARY KEY CLUSTERED  ([ChkFieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_ChkField_UniquePair] ON [dbo].[CIC_View_ChkField] ([ViewType], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_ChkField] ADD CONSTRAINT [FK_CIC_View_ChkField_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_ChkField] ADD CONSTRAINT [FK_CIC_View_ChkField_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_ChkField] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_ChkField] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_ChkField] TO [cioc_login_role]
GO
