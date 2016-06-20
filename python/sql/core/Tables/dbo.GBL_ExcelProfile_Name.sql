CREATE TABLE [dbo].[GBL_ExcelProfile_Name]
(
[ProfileID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Name] ADD CONSTRAINT [PK_GBL_ExcelProfile_Name] PRIMARY KEY CLUSTERED  ([ProfileID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Name] ADD CONSTRAINT [FK_GBL_ExcelProfile_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Name] ADD CONSTRAINT [FK_GBL_ExcelProfile_Name_GBL_ExcelProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_ExcelProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_ExcelProfile_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_ExcelProfile_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_ExcelProfile_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_ExcelProfile_Name] TO [cioc_login_role]
GO
