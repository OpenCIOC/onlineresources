CREATE TABLE [dbo].[CIC_View_Community]
(
[SRCH_CM_ID] [int] NOT NULL IDENTITY(1, 1),
[CM_ID] [int] NOT NULL,
[ViewType] [int] NOT NULL,
[DisplayOrder] [smallint] NOT NULL CONSTRAINT [DF_CIC_View_Community_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Community] ADD CONSTRAINT [PK_CIC_View_Community] PRIMARY KEY CLUSTERED  ([SRCH_CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Community] ADD CONSTRAINT [IX_CIC_View_Community_UniquePair] UNIQUE NONCLUSTERED  ([CM_ID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Community] ADD CONSTRAINT [FK_CIC_View_Community_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_Community] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_Community_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
