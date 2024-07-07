CREATE TABLE [dbo].[VOL_View_DisplayField]
(
[DisplayFieldID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[FieldID] [int] NOT NULL,
[DisplayFieldGroupID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayField] ADD CONSTRAINT [PK_VOL_View_DisplayField] PRIMARY KEY CLUSTERED ([DisplayFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayField] ADD CONSTRAINT [IX_VOL_View_DisplayField_UniquePair] UNIQUE NONCLUSTERED ([ViewType], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayField] ADD CONSTRAINT [FK_VOL_View_DisplayField_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_DisplayField] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_DisplayField_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
ALTER TABLE [dbo].[VOL_View_DisplayField] ADD CONSTRAINT [FK_VOL_View_DisplayField_VOL_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[VOL_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE SET NULL ON UPDATE SET NULL
GO
