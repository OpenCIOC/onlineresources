CREATE TABLE [dbo].[GBL_Reminder_Agency]
(
[ReminderID] [int] NOT NULL,
[AgencyID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder_Agency] ADD CONSTRAINT [PK_GBL_Reminder_Agency] PRIMARY KEY CLUSTERED  ([ReminderID], [AgencyID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Reminder_Agency] ADD CONSTRAINT [FK_GBL_Reminder_Agency_GBL_Agency] FOREIGN KEY ([AgencyID]) REFERENCES [dbo].[GBL_Agency] ([AgencyID])
GO
ALTER TABLE [dbo].[GBL_Reminder_Agency] ADD CONSTRAINT [FK_GBL_Reminder_Agency_GBL_Reminder] FOREIGN KEY ([ReminderID]) REFERENCES [dbo].[GBL_Reminder] ([ReminderID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
