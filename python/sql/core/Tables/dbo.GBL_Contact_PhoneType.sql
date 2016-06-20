CREATE TABLE [dbo].[GBL_Contact_PhoneType]
(
[PhoneType] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_ContactPhoneType_LangID] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Contact_PhoneType] ADD CONSTRAINT [PK_GBL_ContactPhoneType] PRIMARY KEY CLUSTERED  ([PhoneType], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Contact_PhoneType] ADD CONSTRAINT [FK_GBL_ContactPhoneType_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_Contact_PhoneType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Contact_PhoneType] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Contact_PhoneType] TO [cioc_vol_search_role]
GO
