CREATE TABLE [dbo].[VOL_ApplicationSurvey_Referral]
(
[APP_REF_ID] [smalldatetime] NOT NULL,
[SURVEY_DATE] [smalldatetime] NULL,
[APP_ID] [int] NOT NULL,
[ApplicantCity] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion1Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion2Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TextQuestion3Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion1Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion2Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DDQuestion3Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ApplicationSurvey_Referral] ADD CONSTRAINT [PK_VOL_ApplicationSurvey_Referral] PRIMARY KEY CLUSTERED ([APP_REF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ApplicationSurvey_Referral] ADD CONSTRAINT [FK_VOL_ApplicationSurvey_Referral_VOL_ApplicationSurvey] FOREIGN KEY ([APP_ID]) REFERENCES [dbo].[VOL_ApplicationSurvey] ([APP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
