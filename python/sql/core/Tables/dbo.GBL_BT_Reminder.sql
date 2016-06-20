CREATE TABLE [dbo].[GBL_BT_Reminder]
(
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ReminderID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_Reminder] ADD CONSTRAINT [PK_GBL_BT_Reminder] PRIMARY KEY CLUSTERED  ([ReminderID], [NUM]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_Reminder] ADD CONSTRAINT [FK_GBL_BT_Reminder_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_Reminder] ADD CONSTRAINT [FK_GBL_BT_Reminder_GBL_Reminder] FOREIGN KEY ([ReminderID]) REFERENCES [dbo].[GBL_Reminder] ([ReminderID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_BT_Reminder] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BT_Reminder] TO [cioc_login_role]
GO
