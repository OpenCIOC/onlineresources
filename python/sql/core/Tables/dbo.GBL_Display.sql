CREATE TABLE [dbo].[GBL_Display]
(
[DD_ID] [int] NOT NULL IDENTITY(1, 1),
[Domain] [int] NOT NULL,
[User_ID] [int] NULL,
[ViewTypeCIC] [int] NULL,
[ViewTypeVOL] [int] NULL,
[ShowID] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_ID] DEFAULT ((0)),
[ShowOwner] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_Owner] DEFAULT ((0)),
[ShowAlert] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_Alert] DEFAULT ((0)),
[ShowOrg] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_Org] DEFAULT ((1)),
[ShowCommunity] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_Community] DEFAULT ((1)),
[ShowUpdateSchedule] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_UpdateSchedule] DEFAULT ((0)),
[LinkUpdate] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_Update] DEFAULT ((0)),
[LinkEmail] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_LinkEmail] DEFAULT ((0)),
[LinkSelect] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_LinkSelect] DEFAULT ((0)),
[LinkWeb] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_BLinkCat] DEFAULT ((0)),
[LinkListAdd] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_LinkCTAdd] DEFAULT ((0)),
[OrderBy] [int] NOT NULL CONSTRAINT [DF_GBL_Users_Display_OrderBy] DEFAULT ((0)),
[OrderByCustom] [int] NULL,
[OrderByDesc] [bit] NOT NULL CONSTRAINT [DF_GBL_Display_OrderByDesc] DEFAULT ((0)),
[GLinkMail] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_GLinkMail] DEFAULT ((0)),
[GLinkPub] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_CLinkPub] DEFAULT ((0)),
[VShowTable] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_VShowTable] DEFAULT ((0)),
[VShowPosition] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_VShowPosition] DEFAULT ((1)),
[VShowDuties] [bit] NOT NULL CONSTRAINT [DF_GBL_Users_Display_VShowDuties] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [CK_GBL_Display_CIC] CHECK (([Domain]=(1) OR [ViewTypeCIC] IS NULL))
GO
ALTER TABLE [dbo].[GBL_Display] WITH NOCHECK ADD CONSTRAINT [CK_GBL_Display_Domain] CHECK (([Domain]=(1) OR [Domain]=(2)))
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [CK_GBL_Display_Purpose] CHECK (([User_ID] IS NOT NULL OR [ViewTypeCIC] IS NOT NULL OR [ViewTypeVOL] IS NOT NULL))
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [CK_GBL_Display_User_1] CHECK (([User_ID] IS NULL OR [ViewTypeCIC] IS NULL))
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [CK_GBL_Display_User_2] CHECK (([User_ID] IS NULL OR [ViewTypeVOL] IS NULL))
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [CK_GBL_Display_Volunteer] CHECK (([Domain]=(2) OR [ViewTypeVOL] IS NULL))
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [PK_GBL_Display] PRIMARY KEY CLUSTERED  ([DD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [IX_GBL_Display] UNIQUE NONCLUSTERED  ([Domain], [User_ID], [ViewTypeCIC], [ViewTypeVOL]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Display] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Display_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [FK_GBL_Display_CIC_View] FOREIGN KEY ([ViewTypeCIC]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GBL_Display] ADD CONSTRAINT [FK_GBL_Display_VOL_View] FOREIGN KEY ([ViewTypeVOL]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
