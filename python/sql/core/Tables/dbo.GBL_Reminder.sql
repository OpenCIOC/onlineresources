CREATE TABLE [dbo].[GBL_Reminder]
(
[ReminderID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Reminder_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Reminder_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[UserID] [int] NOT NULL,
[LangID] [smallint] NULL,
[NoteTypeID] [int] NULL,
[ActiveDate] [smalldatetime] NULL,
[DueDate] [smalldatetime] NULL,
[Notes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DismissForAll] [bit] NOT NULL CONSTRAINT [DF_GBL_Reminder_DismissForAll] DEFAULT ((0)),
[Dismissed] [bit] NOT NULL CONSTRAINT [DF_GBL_Reminder_Dismissed] DEFAULT ((0)),
[DismissalDate] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder] ADD CONSTRAINT [PK_GBL_Reminder] PRIMARY KEY CLUSTERED  ([ReminderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder] ADD CONSTRAINT [FK_GBL_Reminder_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_Reminder] ADD CONSTRAINT [FK_GBL_Reminder_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_Reminder] ADD CONSTRAINT [FK_GBL_Reminder_GBL_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
GRANT SELECT ON  [dbo].[GBL_Reminder] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Reminder] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Reminder] TO [cioc_vol_search_role]
GO
