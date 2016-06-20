CREATE TABLE [dbo].[VOL_View_UpdateField]
(
[UpdateFieldID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_UpdateField] ADD CONSTRAINT [PK_VOL_View_UpdateField] PRIMARY KEY CLUSTERED  ([UpdateFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_UpdateField] ADD CONSTRAINT [IX_VOL_View_UpdateField_UniquePair] UNIQUE NONCLUSTERED  ([ViewType], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_UpdateField] ADD CONSTRAINT [FK_VOL_View_UpdateField_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_UpdateField] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_UpdateField_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
