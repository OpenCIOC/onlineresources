CREATE TABLE [dbo].[VOL_CommunityGroup_Name]
(
[CommunityGroupID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CommunityGroupName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_Name] ADD CONSTRAINT [PK_VOL_CommunityGroup_Name_1] PRIMARY KEY CLUSTERED  ([CommunityGroupID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_Name] ADD CONSTRAINT [FK_VOL_CommunityGroup_Name_VOL_CommunityGroup] FOREIGN KEY ([CommunityGroupID]) REFERENCES [dbo].[VOL_CommunityGroup] ([CommunityGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_CommunityGroup_Name] ADD CONSTRAINT [FK_VOL_CommunityGroup_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
