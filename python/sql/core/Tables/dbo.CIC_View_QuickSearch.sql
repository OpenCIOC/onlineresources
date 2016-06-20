CREATE TABLE [dbo].[CIC_View_QuickSearch]
(
[QuickSearchID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[PageName] [varchar] (255) COLLATE Latin1_General_100_CS_AS NOT NULL,
[PromoteToTab] [bit] NOT NULL CONSTRAINT [DF_Table_1_PromotToTab] DEFAULT ((0)),
[QueryParameters] [varchar] (1000) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_QuickSearch_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_QuickSearch] ADD CONSTRAINT [PK_CIC_View_QuickSearch] PRIMARY KEY CLUSTERED  ([QuickSearchID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_QuickSearch] ADD CONSTRAINT [FK_CIC_View_QuickSearch_GBL_PageInfo] FOREIGN KEY ([PageName]) REFERENCES [dbo].[GBL_PageInfo] ([PageName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_QuickSearch] ADD CONSTRAINT [FK_CIC_View_QuickSearch_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
