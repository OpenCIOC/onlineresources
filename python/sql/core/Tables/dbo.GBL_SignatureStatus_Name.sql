CREATE TABLE [dbo].[GBL_SignatureStatus_Name]
(
[SIG_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SignatureStatus_Name] ADD CONSTRAINT [PK_GBL_SignatureStatus_Name] PRIMARY KEY CLUSTERED  ([SIG_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SignatureStatus_Name] ADD CONSTRAINT [FK_GBL_SignatureStatus_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_SignatureStatus_Name] ADD CONSTRAINT [FK_GBL_SignatureStatus_Name_GBL_SignatureStatus] FOREIGN KEY ([SIG_ID]) REFERENCES [dbo].[GBL_SignatureStatus] ([SIG_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_SignatureStatus_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_SignatureStatus_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_SignatureStatus_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_SignatureStatus_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_SignatureStatus_Name] TO [cioc_login_role]
GO
