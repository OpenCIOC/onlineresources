CREATE TABLE [dbo].[GBL_Schedule_Name]
(
[SchedID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Label] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Schedule_Name] ADD CONSTRAINT [PK_GBL_Schedule_Name] PRIMARY KEY CLUSTERED  ([SchedID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Schedule_Name] ADD CONSTRAINT [FK_GBL_Schedule_Name_GBL_Schedule] FOREIGN KEY ([SchedID]) REFERENCES [dbo].[GBL_Schedule] ([SchedID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GBL_Schedule_Name] ADD CONSTRAINT [FK_GBL_Schedule_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_Schedule_Name] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[GBL_Schedule_Name] TO [cioc_login_role]
GO
GRANT DELETE ON  [dbo].[GBL_Schedule_Name] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_Schedule_Name] TO [cioc_login_role]
GO
