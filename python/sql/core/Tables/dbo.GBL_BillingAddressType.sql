CREATE TABLE [dbo].[GBL_BillingAddressType]
(
[AddressTypeID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultType] [bit] NOT NULL CONSTRAINT [DF_GBL_BillingAddressType_Default] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BillingAddressType] ADD CONSTRAINT [PK_GBL_BillingAddressType] PRIMARY KEY CLUSTERED  ([AddressTypeID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_BillingAddressType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BillingAddressType] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_BillingAddressType] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_BillingAddressType] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_BillingAddressType] TO [cioc_login_role]
GO
