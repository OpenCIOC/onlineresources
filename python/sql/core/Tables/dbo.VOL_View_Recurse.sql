CREATE TABLE [dbo].[VOL_View_Recurse]
(
[ViewRelID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[CanSee] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_Recurse] ADD CONSTRAINT [PK_VOL_View_Recurse] PRIMARY KEY CLUSTERED  ([ViewRelID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_Recurse] ADD CONSTRAINT [IX_VOL_View_Recurse_UniquePair] UNIQUE NONCLUSTERED  ([ViewType], [CanSee]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_Recurse] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_Recurse_VOL_View1] FOREIGN KEY ([CanSee]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
ALTER TABLE [dbo].[VOL_View_Recurse] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_Recurse_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_View_Recurse] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_View_Recurse] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_View_Recurse] TO [cioc_login_role]
GO
