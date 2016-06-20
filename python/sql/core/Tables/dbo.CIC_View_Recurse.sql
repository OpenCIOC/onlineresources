CREATE TABLE [dbo].[CIC_View_Recurse]
(
[ViewRelID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[CanSee] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Recurse] ADD CONSTRAINT [PK_CIC_View_Recurse] PRIMARY KEY CLUSTERED  ([ViewRelID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Recurse] ADD CONSTRAINT [IX_CIC_View_Recurse_UniquePair] UNIQUE NONCLUSTERED  ([ViewType], [CanSee]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Recurse] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_Recurse_CIC_View1] FOREIGN KEY ([CanSee]) REFERENCES [dbo].[CIC_View] ([ViewType])
GO
ALTER TABLE [dbo].[CIC_View_Recurse] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_Recurse_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_Recurse] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_Recurse] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_Recurse] TO [cioc_login_role]
GO
