CREATE TABLE [dbo].[VOL_MinHoursPer_Name]
(
[HPER_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_MinHoursPer_Name] ADD CONSTRAINT [PK_VOL_MinHoursPer_Name] PRIMARY KEY CLUSTERED  ([HPER_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_MinHoursPer_Name] ADD CONSTRAINT [FK_VOL_MinHoursPer_Name_VOL_MinHoursPer] FOREIGN KEY ([HPER_ID]) REFERENCES [dbo].[VOL_MinHoursPer] ([HPER_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_MinHoursPer_Name] ADD CONSTRAINT [FK_VOL_MinHoursPer_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
