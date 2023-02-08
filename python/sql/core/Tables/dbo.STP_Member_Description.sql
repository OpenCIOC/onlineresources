CREATE TABLE [dbo].[STP_Member_Description]
(
[MemberID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DatabaseNameCIC] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_STP_Member_Description_DatabaseNameCIC] DEFAULT ('Community Information Database'),
[MemberName] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MemberNameCIC] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[FeedbackMsgCIC] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_STP_Member_Description_FeedbackMsgCIC] DEFAULT ('Thank you for your submission. Your suggestions will be processed within 10 business days.<BR>If you provided an e-mail address, you will be notified by email once your suggestions have been processed.'),
[DatabaseNameVOL] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_STP_Member_Description_DatabaseNameVOL] DEFAULT ('Volunteer Database'),
[MemberNameVOL] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[FeedbackMsgVOL] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_STP_Member_Description_FeedbackMsgVOL] DEFAULT ('Thank you for your submission. Your suggestions will be processed within 10 business days.<BR>If you provided an e-mail address, you will be notified by email once your suggestions have been processed.'),
[VolProfilePrivacyPolicy] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VolProfilePrivacyPolicyOrgName] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SubsidyNamedProgram] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SubsidyNamedProgramDesc] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[SubsidyNamedProgramSearchLabel] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Member_Description] ADD CONSTRAINT [PK_STP_Member_Description] PRIMARY KEY CLUSTERED ([MemberID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Member_Description] ADD CONSTRAINT [FK_STP_Member_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[STP_Member_Description] ADD CONSTRAINT [FK_STP_Member_Description_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ([MemberID]) ON [dbo].[STP_Member_Description] TO [cioc_cic_search_role]
GO
GRANT SELECT ([LangID]) ON [dbo].[STP_Member_Description] TO [cioc_cic_search_role]
GO
GRANT SELECT ([SubsidyNamedProgram]) ON [dbo].[STP_Member_Description] TO [cioc_cic_search_role]
GO
GRANT SELECT ([SubsidyNamedProgramDesc]) ON [dbo].[STP_Member_Description] TO [cioc_cic_search_role]
GO
GRANT SELECT ([SubsidyNamedProgramSearchLabel]) ON [dbo].[STP_Member_Description] TO [cioc_cic_search_role]
GO
GRANT INSERT ON  [dbo].[STP_Member_Description] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[STP_Member_Description] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[STP_Member_Description] TO [cioc_login_role]
GO
