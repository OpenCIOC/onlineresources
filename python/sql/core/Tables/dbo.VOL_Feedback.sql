CREATE TABLE [dbo].[VOL_Feedback]
(
[FB_ID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[FEEDBACK_OWNER] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_VOL_Feedback_Equivalent] DEFAULT ((0)),
[SUBMIT_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_VOL_Feedback_SUBMIT_DATE] DEFAULT (getdate()),
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[User_ID] [int] NULL,
[ViewType] [int] NULL,
[AccessURL] [varchar] (160) COLLATE Latin1_General_100_CI_AI NULL,
[FULL_UPDATE] [bit] NOT NULL CONSTRAINT [DF_VOL_Feedback_FULL_UPDATE] DEFAULT ((0)),
[NO_CHANGES] [bit] NOT NULL CONSTRAINT [DF_VOL_Feedback_NO_CHANGES] DEFAULT ((0)),
[REMOVE_RECORD] [bit] NOT NULL CONSTRAINT [DF_VOL_Feedback_REMOVE_RECORD] DEFAULT ((0)),
[FB_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[FBKEY] [varchar] (6) COLLATE Latin1_General_100_CI_AI NULL,
[NUM] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[ACCESSIBILITY] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ADDITIONAL_REQUIREMENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[APPLICATION_DEADLINE] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[BENEFITS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CLIENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[COMMITMENT_LENGTH] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_EMAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[COST] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DISPLAY_UNTIL] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[DUTIES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[END_DATE] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[INTERACTION_LEVEL] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[INTERESTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[INTERNAL_MEMO] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LOCATION] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[LIABILITY_INSURANCE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[MAX_AGE] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MIN_AGE] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MINIMUM_HOURS] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MINIMUM_HOURS_PER] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MORE_INFO_URL] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[NO_UPDATE_EMAIL] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[NON_PUBLIC] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[NUM_NEEDED] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NUM_NEEDED_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NUM_NEEDED_TOTAL] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_NAME] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[OSSD] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[POLICE_CHECK] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[POSITION_TITLE] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[PUBLIC_COMMENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[REQUEST_DATE] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[SCHEDULE_GRID] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SCHEDULE_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SEASONS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SOCIAL_MEDIA] [xml] NULL,
[SOURCE_EMAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PUBLICATION_DATE] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PHONE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PUBLICATION] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SKILLS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[START_DATE_FIRST] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[START_DATE_LAST] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[SUITABILITY] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TRAINING] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TRANSPORTATION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UPDATE_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[VOL_Feedback] ADD 
CONSTRAINT [PK_VOL_Feedback] PRIMARY KEY CLUSTERED  ([FB_ID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VOL_Feedback] ADD CONSTRAINT [FK_VOL_Feedback_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Feedback] ADD CONSTRAINT [FK_VOL_Feedback_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Feedback] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Feedback_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Feedback] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Feedback_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Feedback] ADD CONSTRAINT [FK_VOL_Feedback_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[VOL_Feedback] NOCHECK CONSTRAINT [FK_VOL_Feedback_GBL_Users]
GO
GRANT SELECT ON  [dbo].[VOL_Feedback] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Feedback] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Feedback] TO [cioc_vol_search_role]
GRANT INSERT ON  [dbo].[VOL_Feedback] TO [cioc_vol_search_role]
GO
