CREATE TABLE [dbo].[GBL_Reminder_User_Note]
(
[ReminderID] [int] NOT NULL,
[User_ID] [int] NOT NULL,
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_Reminder_User_Note_CREATED_DATE] DEFAULT (getdate()),
[Note] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder_User_Note] ADD CONSTRAINT [PK_GBL_Reminder_User_Note] PRIMARY KEY CLUSTERED  ([ReminderID], [User_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder_User_Note] ADD CONSTRAINT [FK_GBL_Reminder_User_Note_GBL_Reminder] FOREIGN KEY ([ReminderID]) REFERENCES [dbo].[GBL_Reminder] ([ReminderID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Reminder_User_Note] ADD CONSTRAINT [FK_GBL_Reminder_User_Note_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
