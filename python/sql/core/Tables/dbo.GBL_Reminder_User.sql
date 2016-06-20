CREATE TABLE [dbo].[GBL_Reminder_User]
(
[ReminderID] [int] NOT NULL,
[User_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder_User] ADD CONSTRAINT [PK_GBL_Reminder_User] PRIMARY KEY CLUSTERED  ([ReminderID], [User_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder_User] ADD CONSTRAINT [FK_GBL_Reminder_User_GBL_Reminder] FOREIGN KEY ([ReminderID]) REFERENCES [dbo].[GBL_Reminder] ([ReminderID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Reminder_User] ADD CONSTRAINT [FK_GBL_Reminder_User_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
