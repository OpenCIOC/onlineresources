CREATE TABLE [dbo].[VOL_Interest]
(
[AI_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_Interest_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Interest] ADD CONSTRAINT [PK_VOL_Interest] PRIMARY KEY CLUSTERED ([AI_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VOL_Interest] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[VOL_Interest] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_Interest] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[VOL_Interest] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_Interest] TO [cioc_vol_search_role]
GO
