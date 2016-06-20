CREATE TABLE [dbo].[VOL_View_ChkField]
(
[ChkFieldID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_ChkField] ADD CONSTRAINT [PK_VOL_View_ChkField] PRIMARY KEY CLUSTERED  ([ChkFieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_View_ChkField_UniquePair] ON [dbo].[VOL_View_ChkField] ([ViewType], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_ChkField] ADD CONSTRAINT [FK_VOL_View_ChkField_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_ChkField] ADD CONSTRAINT [FK_VOL_View_ChkField_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_View_ChkField] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_View_ChkField] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_View_ChkField] TO [cioc_login_role]
GO
