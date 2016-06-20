CREATE TABLE [dbo].[THS_Category]
(
[SubjCat_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Category] ADD CONSTRAINT [PK_THS_Category] PRIMARY KEY CLUSTERED  ([SubjCat_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[THS_Category] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Category] TO [cioc_login_role]
GO
