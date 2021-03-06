CREATE TABLE [dbo].[CIC_Page_View]
(
[PageID] [int] NOT NULL,
[ViewType] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Page_View] ADD CONSTRAINT [PK_CIC_Page_View] PRIMARY KEY CLUSTERED  ([PageID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Page_View] ADD CONSTRAINT [FK_CIC_Page_View_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CIC_Page_View] ADD CONSTRAINT [FK_CIC_Page_View_GBL_Page] FOREIGN KEY ([PageID]) REFERENCES [dbo].[GBL_Page] ([PageID]) ON DELETE CASCADE
GO
