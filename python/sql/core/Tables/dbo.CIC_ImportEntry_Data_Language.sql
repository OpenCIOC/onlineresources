CREATE TABLE [dbo].[CIC_ImportEntry_Data_Language]
(
[ER_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[NON_PUBLIC] [bit] NULL,
[DELETION_DATE] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Data_Language] ADD CONSTRAINT [PK_GBL_ImportLoad_Data_Language] PRIMARY KEY CLUSTERED  ([ER_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Data_Language] ADD CONSTRAINT [FK_CIC_ImportEntry_Data_Language_CIC_ImportEntry_Data] FOREIGN KEY ([ER_ID]) REFERENCES [dbo].[CIC_ImportEntry_Data] ([ER_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Data_Language] ADD CONSTRAINT [FK_CIC_ImportEntry_Data_Language_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry_Data_Language] TO [cioc_login_role]
GO
