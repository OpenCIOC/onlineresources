CREATE TABLE [dbo].[VOL_View_DisplayFieldGroup]
(
[DisplayFieldGroupID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[DisplayOrder] [smallint] NOT NULL CONSTRAINT [DF_VOL_View_DisplayFieldGroup_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayFieldGroup] ADD CONSTRAINT [PK_VOL_View_DisplayFieldGroup] PRIMARY KEY CLUSTERED ([DisplayFieldGroupID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_DisplayFieldGroup] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_DisplayFieldGroup_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
