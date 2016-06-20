CREATE TABLE [dbo].[GBL_Language_Details_Name]
(
[LND_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[HelpText] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_Details_Name] ADD CONSTRAINT [PK_GBL_Language_Details_Name] PRIMARY KEY CLUSTERED  ([LND_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_Details_Name] ADD CONSTRAINT [FK_GBL_Language_Details_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_Language_Details_Name] ADD CONSTRAINT [FK_GBL_Language_Details_Name_GBL_Language_Details] FOREIGN KEY ([LND_ID]) REFERENCES [dbo].[GBL_Language_Details] ([LND_ID])
GO
GRANT SELECT ON  [dbo].[GBL_Language_Details_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Language_Details_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Language_Details_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Language_Details_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Language_Details_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Language_Details_Name] TO [cioc_vol_search_role]
GO
