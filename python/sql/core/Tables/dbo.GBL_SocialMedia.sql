CREATE TABLE [dbo].[GBL_SocialMedia]
(
[SM_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[GeneralURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_GBL_SocialMedia_Active] DEFAULT ((0)),
[IconURL16] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[IconURL24] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SocialMedia] ADD CONSTRAINT [PK_GBL_SocialMedia] PRIMARY KEY CLUSTERED ([SM_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_SocialMedia_Name] ON [dbo].[GBL_SocialMedia] ([DefaultName]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_SocialMedia] TO [cioc_cic_search_role]
GO
GRANT DELETE ON  [dbo].[GBL_SocialMedia] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[GBL_SocialMedia] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_SocialMedia] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_SocialMedia] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_SocialMedia] TO [cioc_vol_search_role]
GO
