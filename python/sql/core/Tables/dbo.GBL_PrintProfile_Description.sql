CREATE TABLE [dbo].[GBL_PrintProfile_Description]
(
[ProfileID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[MemberID_Cache] [int] NOT NULL,
[ProfileName] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[PageTitle] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Header] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Footer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultMsg] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Description] ADD CONSTRAINT [PK_GBL_PrintProfile_Description] PRIMARY KEY CLUSTERED  ([ProfileID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_PrintProfile_Description_UniqueName] ON [dbo].[GBL_PrintProfile_Description] ([MemberID_Cache], [LangID], [ProfileName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Description] ADD CONSTRAINT [FK_GBL_PrintProfile_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Description] ADD CONSTRAINT [FK_GBL_PrintProfile_Description_STP_Member] FOREIGN KEY ([MemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Description] ADD CONSTRAINT [FK_GBL_PrintProfile_Description_GBL_PrintProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_PrintProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
