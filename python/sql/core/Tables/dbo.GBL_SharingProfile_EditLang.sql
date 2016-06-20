CREATE TABLE [dbo].[GBL_SharingProfile_EditLang]
(
[ProfileID] [int] NOT NULL,
[LangID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_EditLang] ADD CONSTRAINT [PK_GBL_SharingProfile_EditLang] PRIMARY KEY CLUSTERED  ([ProfileID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_EditLang] ADD CONSTRAINT [FK_GBL_SharingProfile_EditLang_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_SharingProfile_EditLang] ADD CONSTRAINT [FK_GBL_SharingProfile_EditLang_GBL_SharingProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_SharingProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
