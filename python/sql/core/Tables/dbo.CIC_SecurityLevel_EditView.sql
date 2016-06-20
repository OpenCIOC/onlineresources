CREATE TABLE [dbo].[CIC_SecurityLevel_EditView]
(
[SL_ID] [int] NOT NULL,
[ViewType] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditView] ADD CONSTRAINT [PK_CIC_SecurityLevel_EditView] PRIMARY KEY CLUSTERED  ([SL_ID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditView] ADD CONSTRAINT [FK_CIC_SecurityLevel_EditView_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditView] WITH NOCHECK ADD CONSTRAINT [FK_CIC_SecurityLevel_EditView_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType])
GO
