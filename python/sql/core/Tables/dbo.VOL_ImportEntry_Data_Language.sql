CREATE TABLE [dbo].[VOL_ImportEntry_Data_Language]
(
[ER_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[NON_PUBLIC] [bit] NULL,
[DELETION_DATE] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ImportEntry_Data_Language] ADD CONSTRAINT [PK_VOL_ImportEntry_Data_Language] PRIMARY KEY CLUSTERED  ([ER_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ImportEntry_Data_Language] ADD CONSTRAINT [FK_VOL_ImportEntry_Data_Language_VOL_ImportEntry_Data] FOREIGN KEY ([ER_ID]) REFERENCES [dbo].[VOL_ImportEntry_Data] ([ER_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_ImportEntry_Data_Language] ADD CONSTRAINT [FK_VOL_ImportEntry_Data_Language_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
