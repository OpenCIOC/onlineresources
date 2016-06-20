CREATE TABLE [dbo].[GBL_StandardEmailUpdate_Description]
(
[EmailID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[MemberID_Cache] [int] NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[StdSubject] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdSubject] DEFAULT ('Update your database listing - are we current?'),
[StdGreetingStart] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdGreetingStart] DEFAULT ('Hello from'),
[StdGreetingEnd] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[StdMessageBody] [nvarchar] (1500) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdMessageBody] DEFAULT ('The above record is listed in our database with your E-mail address. Our goal is to ensure that the information we are providing is accurate. Please take the time to read your entry as it appears and suggest any changes that will make this information more complete or accurate.'),
[StdDetailDesc] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdDetailDesc] DEFAULT ('Check this URL for your current listing:'),
[StdFeedbackDesc] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdFeedbackDesc] DEFAULT ('Go to this URL to suggest changes:'),
[StdSuggestOppDesc] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdSuggestOppDesc] DEFAULT ('Go to this URL to suggest a new opportunity with this organization:'),
[StdOrgOppsDesc] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdOrgOppsDesc] DEFAULT ('Go to this URL to view other opportunities listed for this organization:'),
[StdContact] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_Description_StdContact] DEFAULT ('if you have any questions regarding the information contained within this message, please contact:')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate_Description] ADD CONSTRAINT [PK_GBL_StandardEmailUpdate_Description] PRIMARY KEY CLUSTERED  ([EmailID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_StandardEmailUpdate_Description] ON [dbo].[GBL_StandardEmailUpdate_Description] ([MemberID_Cache], [LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate_Description] ADD CONSTRAINT [FK_GBL_StandardEmailUpdate_Description_GBL_StandardEmailUpdate] FOREIGN KEY ([EmailID]) REFERENCES [dbo].[GBL_StandardEmailUpdate] ([EmailID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate_Description] ADD CONSTRAINT [FK_GBL_StandardEmailUpdate_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate_Description] ADD CONSTRAINT [FK_GBL_StandardEmailUpdate_Description_STP_Member] FOREIGN KEY ([MemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
