CREATE TABLE [dbo].[GBL_BillingAddressType_Name]
(
[AddressTypeID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BillingAddressType_Name] ADD CONSTRAINT [PK_GBL_BillingAddressType_Name] PRIMARY KEY CLUSTERED  ([AddressTypeID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BillingAddressType_Name] ADD CONSTRAINT [FK_GBL_BillingAddressType_Name_GBL_BillingAddressType] FOREIGN KEY ([AddressTypeID]) REFERENCES [dbo].[GBL_BillingAddressType] ([AddressTypeID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BillingAddressType_Name] ADD CONSTRAINT [FK_GBL_BillingAddressType_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_BillingAddressType_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BillingAddressType_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_BillingAddressType_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_BillingAddressType_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_BillingAddressType_Name] TO [cioc_login_role]
GO
