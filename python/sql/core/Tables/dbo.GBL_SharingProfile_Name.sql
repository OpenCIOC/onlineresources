CREATE TABLE [dbo].[GBL_SharingProfile_Name]
(
[ProfileID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_Name] ADD CONSTRAINT [PK_GBL_SharingProfile_Name] PRIMARY KEY CLUSTERED  ([ProfileID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_Name] ADD CONSTRAINT [FK_GBL_SharingProfile_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_SharingProfile_Name] ADD CONSTRAINT [FK_GBL_SharingProfile_Name_GBL_SharingProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_SharingProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_SharingProfile_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_SharingProfile_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_SharingProfile_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_SharingProfile_Name] TO [cioc_login_role]
GO
