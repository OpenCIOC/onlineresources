CREATE TABLE [dbo].[VOL_ApplicationSurvey]
(
[APP_ID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_ApplicationSurvey_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_ApplicationSurvey_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[ARCHIVED_DATE] [smalldatetime] NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Title] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion1] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion2] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion3] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion1Help] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion2Help] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion3Help] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Help] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Help] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Help] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Opt1] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Opt2] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Opt3] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Opt4] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Opt5] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Opt6] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Opt1] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Opt2] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Opt3] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Opt4] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Opt5] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Opt6] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Opt1] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Opt2] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Opt3] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Opt4] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Opt5] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Opt6] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ApplicationSurvey] ADD CONSTRAINT [PK_VOL_ApplicationSurvey] PRIMARY KEY NONCLUSTERED ([APP_ID]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_VOL_ApplicationSurvey_UniqueName] ON [dbo].[VOL_ApplicationSurvey] ([MemberID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ApplicationSurvey] ADD CONSTRAINT [FK_VOL_ApplicationSurvey_STP_Language] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
