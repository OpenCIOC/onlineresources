CREATE TABLE [dbo].[GBL_DownloadURL_Name]
(
[URL_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[MemberID_Cache] [int] NOT NULL,
[Name] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_DownloadURL_Name] ADD CONSTRAINT [PK_GBL_DownloadURL_Name] PRIMARY KEY CLUSTERED  ([URL_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_DownloadURL_Name] ADD CONSTRAINT [FK_GBL_DownloadURL_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_DownloadURL_Name] ADD CONSTRAINT [FK_GBL_DownloadURL_Name_STP_Member] FOREIGN KEY ([MemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_DownloadURL_Name] ADD CONSTRAINT [FK_GBL_DownloadURL_Name_GBL_DownloadURL] FOREIGN KEY ([URL_ID]) REFERENCES [dbo].[GBL_DownloadURL] ([URL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
