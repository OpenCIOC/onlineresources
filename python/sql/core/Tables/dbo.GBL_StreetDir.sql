CREATE TABLE [dbo].[GBL_StreetDir]
(
[Dir] [varchar] (2) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StreetDir] ADD CONSTRAINT [PK_GBL_StreetDir] PRIMARY KEY CLUSTERED  ([Dir]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_StreetDir] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_StreetDir] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_StreetDir] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_StreetDir] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_StreetDir] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_StreetDir] TO [cioc_vol_search_role]
GO
