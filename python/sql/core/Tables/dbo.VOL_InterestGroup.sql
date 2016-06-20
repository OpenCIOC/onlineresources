CREATE TABLE [dbo].[VOL_InterestGroup]
(
[IG_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_InterestGroup_DisplayOrder] DEFAULT ((0)),
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_InterestGroup] ADD CONSTRAINT [PK_VOL_InterestGroup] PRIMARY KEY CLUSTERED  ([IG_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[VOL_InterestGroup] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_InterestGroup] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_InterestGroup] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_InterestGroup] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_InterestGroup] TO [cioc_vol_search_role]
GO
