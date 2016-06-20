CREATE TABLE [dbo].[CIC_View_DisplayFieldGroup]
(
[DisplayFieldGroupID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[DisplayOrder] [smallint] NOT NULL CONSTRAINT [DF_CIC_View_DisplayFieldGroup_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_DisplayFieldGroup] ADD CONSTRAINT [PK_CIC_View_DisplayFieldGroup] PRIMARY KEY CLUSTERED  ([DisplayFieldGroupID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_DisplayFieldGroup] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_DisplayFieldGroup_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_DisplayFieldGroup] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_DisplayFieldGroup] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_DisplayFieldGroup] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_View_DisplayFieldGroup] TO [cioc_login_role]
GO
