CREATE TABLE [dbo].[CIC_View_QuickListPub]
(
[QuickListPubID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[PB_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_QuickListPub] ADD CONSTRAINT [PK_CIC_View_QuickListPub] PRIMARY KEY CLUSTERED  ([QuickListPubID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_QuickListPub] ON [dbo].[CIC_View_QuickListPub] ([PB_ID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_QuickListPub] ADD CONSTRAINT [FK_CIC_View_QuickListPub_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_QuickListPub] ADD CONSTRAINT [FK_CIC_View_QuickListPub_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_QuickListPub] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_QuickListPub] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_QuickListPub] TO [cioc_login_role]
GO
