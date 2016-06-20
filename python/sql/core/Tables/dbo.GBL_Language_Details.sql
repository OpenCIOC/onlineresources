CREATE TABLE [dbo].[GBL_Language_Details]
(
[LND_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Language_Details_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_Details] ADD CONSTRAINT [PK_GBL_Language_Details] PRIMARY KEY CLUSTERED  ([LND_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_Language_Details] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Language_Details] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Language_Details] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Language_Details] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Language_Details] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Language_Details] TO [cioc_vol_search_role]
GO
