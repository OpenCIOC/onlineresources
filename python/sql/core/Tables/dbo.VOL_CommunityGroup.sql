CREATE TABLE [dbo].[VOL_CommunityGroup]
(
[CommunityGroupID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CommunitySetID] [int] NOT NULL,
[BallID] [int] NULL,
[ImageURL] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunityGroup] ADD CONSTRAINT [IX_VOL_CommunityGroup_Ball] UNIQUE NONCLUSTERED  ([BallID], [ImageURL], [CommunitySetID]) ON [PRIMARY]

GO


ALTER TABLE [dbo].[VOL_CommunityGroup] ADD
CONSTRAINT [FK_VOL_CommunityGroup_VOL_CommunitySet] FOREIGN KEY ([CommunitySetID]) REFERENCES [dbo].[VOL_CommunitySet] ([CommunitySetID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_CommunityGroup] ADD CONSTRAINT [CK_VOL_CommunityGroup] CHECK ((([BallID] IS NOT NULL OR [ImageURL] IS NOT NULL) AND ([BallID] IS NULL OR [ImageURL] IS NULL)))
GO
ALTER TABLE [dbo].[VOL_CommunityGroup] ADD CONSTRAINT [PK_VOL_CommunityGroup] PRIMARY KEY CLUSTERED  ([CommunityGroupID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VOL_CommunityGroup] WITH NOCHECK ADD CONSTRAINT [FK_VOL_CommunityGroup_VOL_Ball] FOREIGN KEY ([BallID]) REFERENCES [dbo].[VOL_Ball] ([BallID]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_CommunityGroup] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_CommunityGroup] TO [cioc_vol_search_role]
GO
