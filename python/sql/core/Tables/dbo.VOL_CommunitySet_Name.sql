CREATE TABLE [dbo].[VOL_CommunitySet_Name]
(
[CommunitySetID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[SetName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AreaServed] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunitySet_Name] ADD CONSTRAINT [PK_VOL_CommunitySet_Name] PRIMARY KEY CLUSTERED  ([CommunitySetID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_CommunitySet_Name] ON [dbo].[VOL_CommunitySet_Name] ([LangID], [SetName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunitySet_Name] ADD CONSTRAINT [FK_VOL_CommunitySet_Name_VOL_CommunitySet] FOREIGN KEY ([CommunitySetID]) REFERENCES [dbo].[VOL_CommunitySet] ([CommunitySetID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_CommunitySet_Name] ADD CONSTRAINT [FK_VOL_CommunitySet_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
