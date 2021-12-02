CREATE TABLE [dbo].[GBL_Redirect]
(
[MemberID] [int] NOT NULL,
[slug] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Redirect_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Redirect_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DM] [tinyint] NOT NULL,
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[url] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Redirect] ADD CONSTRAINT [PK_GBL_Redirect] PRIMARY KEY CLUSTERED ([MemberID], [slug]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Redirect] ON [dbo].[GBL_Redirect] ([MemberID], [slug], [url]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Redirect] ADD CONSTRAINT [FK_GBL_Redirect_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Redirect] ADD CONSTRAINT [FK_GBL_Redirect_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
