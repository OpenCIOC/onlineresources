CREATE TABLE [dbo].[GBL_OrgLocationService]
(
[OLS_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_BUS_OrgLocationService_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_OrgLocationService] ADD CONSTRAINT [PK_GBL_OrgLocationService] PRIMARY KEY CLUSTERED  ([OLS_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_OrgLocationService] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_OrgLocationService] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_OrgLocationService] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_OrgLocationService] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_OrgLocationService] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_OrgLocationService] TO [cioc_vol_search_role]
GO
