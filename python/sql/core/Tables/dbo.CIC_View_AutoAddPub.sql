CREATE TABLE [dbo].[CIC_View_AutoAddPub]
(
[AutoAddPubID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[PB_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_AutoAddPub] ADD CONSTRAINT [PK_CIC_View_AutoAddPub] PRIMARY KEY CLUSTERED  ([AutoAddPubID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_AutoAddPub] ON [dbo].[CIC_View_AutoAddPub] ([PB_ID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_AutoAddPub] ADD CONSTRAINT [FK_CIC_View_AutoAddPub_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_AutoAddPub] ADD CONSTRAINT [FK_CIC_View_AutoAddPub_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_AutoAddPub] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_AutoAddPub] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_AutoAddPub] TO [cioc_login_role]
GO
