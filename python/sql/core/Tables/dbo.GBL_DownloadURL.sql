CREATE TABLE [dbo].[GBL_DownloadURL]
(
[URL_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[Domain] [tinyint] NOT NULL,
[ResourceURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_DownloadURL] WITH NOCHECK ADD CONSTRAINT [CK_GBL_DownloadURL_Domain] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_DownloadURL] ADD CONSTRAINT [PK_GBL_DownloadURL] PRIMARY KEY CLUSTERED ([URL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_DownloadURL] ADD CONSTRAINT [IX_GBL_DownloadURL_URL] UNIQUE NONCLUSTERED ([MemberID], [Domain], [ResourceURL]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_DownloadURL] ADD CONSTRAINT [FK_GBL_DownloadURL_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
