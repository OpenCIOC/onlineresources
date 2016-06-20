CREATE TABLE [dbo].[VOL_OP_Reminder]
(
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ReminderID] [int] NOT NULL,
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_Reminder] ADD CONSTRAINT [PK_VOL_OP_Reminder] PRIMARY KEY CLUSTERED  ([ReminderID], [VNUM]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_Reminder] ADD CONSTRAINT [FK_VOL_OP_Reminder_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_Reminder] ADD CONSTRAINT [FK_VOL_OP_Reminder_GBL_Reminder] FOREIGN KEY ([ReminderID]) REFERENCES [dbo].[GBL_Reminder] ([ReminderID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_Reminder] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_Reminder] TO [cioc_vol_search_role]
GO
