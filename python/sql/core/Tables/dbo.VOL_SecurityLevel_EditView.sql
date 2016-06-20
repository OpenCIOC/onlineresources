CREATE TABLE [dbo].[VOL_SecurityLevel_EditView]
(
[SL_ID] [int] NOT NULL,
[ViewType] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_EditView] ADD CONSTRAINT [PK_VOL_SecurityLevel_EditView] PRIMARY KEY CLUSTERED  ([SL_ID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_EditView] ADD CONSTRAINT [FK_VOL_SecurityLevel_EditView_VOL_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[VOL_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_EditView] WITH NOCHECK ADD CONSTRAINT [FK_VOL_SecurityLevel_EditView_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
