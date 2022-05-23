CREATE TABLE [dbo].[GBL_FeedbackEntry]
(
[FB_ID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[FEEDBACK_OWNER] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_FeedbackEntry_Equivalent] DEFAULT ((0)),
[SUBMIT_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_FeedbackEntry_SUBMIT_DATE] DEFAULT (getdate()),
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[User_ID] [int] NULL,
[ViewType] [int] NULL,
[AccessURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[FBKEY] [varchar] (6) COLLATE Latin1_General_100_CI_AI NULL,
[FULL_UPDATE] [bit] NOT NULL CONSTRAINT [DF_GBL_FeedbackEntry_FULL_UPDATE] DEFAULT ((0)),
[NO_CHANGES] [bit] NOT NULL CONSTRAINT [DF_GBL_FeedbackEntry_NO_CHANGES] DEFAULT ((0)),
[REMOVE_RECORD] [bit] NOT NULL CONSTRAINT [DF_GBL_FeedbackEntry_REMOVE_RECORD] DEFAULT ((0)),
[AUTH_INQUIRY] [bit] NULL CONSTRAINT [DF_GBL_FeedbackEntry_AUTH_INQUIRY] DEFAULT ((0)),
[AUTH_ONLINE] [bit] NULL CONSTRAINT [DF_GBL_FeedbackEntry_AUTH_ONLINE] DEFAULT ((0)),
[AUTH_PRINT] [bit] NULL CONSTRAINT [DF_GBL_FeedbackEntry_AUTH_PRINT] DEFAULT ((0)),
[AUTH_TYPE] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[FB_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_TITLE] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PHONE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_EMAIL] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_BUILDING] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_ADDRESS] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_CITY] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PROVINCE] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_POSTAL_CODE] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] ADD CONSTRAINT [PK_GBL_FeedbackEntry] PRIMARY KEY CLUSTERED ([FB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] ADD CONSTRAINT [FK_GBL_FeedbackEntry_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] WITH NOCHECK ADD CONSTRAINT [FK_GBL_FeedbackEntry_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] ADD CONSTRAINT [FK_GBL_FeedbackEntry_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] ADD CONSTRAINT [FK_GBL_FeedbackEntry_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] ADD CONSTRAINT [FK_GBL_FeedbackEntry_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_FeedbackEntry] NOCHECK CONSTRAINT [FK_GBL_FeedbackEntry_GBL_BaseTable]
GO
GRANT INSERT ON  [dbo].[GBL_FeedbackEntry] TO [cioc_cic_search_role]
GO
GRANT SELECT ON  [dbo].[GBL_FeedbackEntry] TO [cioc_cic_search_role]
GO
GRANT INSERT ON  [dbo].[GBL_FeedbackEntry] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_FeedbackEntry] TO [cioc_login_role]
GO
