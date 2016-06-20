CREATE TABLE [dbo].[CIC_SecurityLevel_EditLang]
(
[SL_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditLang] ADD CONSTRAINT [PK_CIC_SecurityLevel_EditLang] PRIMARY KEY CLUSTERED  ([SL_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditLang] ADD CONSTRAINT [FK_CIC_SecurityLevel_EditLang_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditLang] ADD CONSTRAINT [FK_CIC_SecurityLevel_EditLang_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
