CREATE TABLE [dbo].[GBL_MappingSystem]
(
[MAP_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[NewWindow] [bit] NOT NULL CONSTRAINT [DF_GBL_MappingSystems_NewWindow] DEFAULT ((0)),
[DefaultProvince] [char] (2) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_MappingSystems_DefaultProvince] DEFAULT ('ON'),
[DefaultCountry] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_MappingSystems_DefaultCountry] DEFAULT ('Canada')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_MappingSystem_u] ON [dbo].[GBL_MappingSystem]
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(NewWindow) OR
	UPDATE(DefaultProvince) OR
	UPDATE(DefaultCountry) BEGIN
UPDATE btd
	SET CMP_SiteAddressWeb = dbo.fn_GBL_FullAddress(bt.NUM,bt.RSN,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,btd.SITE_SUFFIX,btd.SITE_CITY,btd.SITE_PROVINCE,btd.SITE_COUNTRY,bt.SITE_POSTAL_CODE,NULL,NULL,NULL,bt.LATITUDE,bt.LONGITUDE,btd.LangID,1)
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM
	INNER JOIN GBL_BT_MAP pr
		ON btd.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.MAP_ID=i.MAP_ID
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_MappingSystem] ADD CONSTRAINT [PK_GBL_MappingSystem] PRIMARY KEY CLUSTERED  ([MAP_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_MappingSystem] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_MappingSystem] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_MappingSystem] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_MappingSystem] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_MappingSystem] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_MappingSystem] TO [cioc_vol_search_role]
GO
