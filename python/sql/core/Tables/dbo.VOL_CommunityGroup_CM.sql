CREATE TABLE [dbo].[VOL_CommunityGroup_CM]
(
[CG_CM_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CommunityGroupID] [int] NOT NULL,
[CM_ID] [int] NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_CommunityGroup_CM_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_CM] ADD CONSTRAINT [PK_VOL_CommunityGroup_CM] PRIMARY KEY CLUSTERED  ([CG_CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_CM] ADD CONSTRAINT [IX_VOL_CommunityGroup_CM] UNIQUE NONCLUSTERED  ([CommunityGroupID], [CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_CM] ADD CONSTRAINT [FK_VOL_CommunityGroup_CM_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_CM] WITH NOCHECK ADD CONSTRAINT [FK_VOL_CommunityGroup_CM_VOL_CommunityGroup] FOREIGN KEY ([CommunityGroupID]) REFERENCES [dbo].[VOL_CommunityGroup] ([CommunityGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_CommunityGroup_CM] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_CommunityGroup_CM] TO [cioc_vol_search_role]
GO
