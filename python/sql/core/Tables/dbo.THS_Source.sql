CREATE TABLE [dbo].[THS_Source]
(
[SRC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_THS_Source_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_THS_Source_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Source] ADD CONSTRAINT [PK_THS_Source] PRIMARY KEY CLUSTERED  ([SRC_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[THS_Source] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Source] TO [cioc_login_role]
GO
