CREATE TABLE [dbo].[TAX_Source]
(
[TAX_SRC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Source] ADD CONSTRAINT [PK_TAX_SourceType] PRIMARY KEY CLUSTERED  ([TAX_SRC_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TAX_Source] TO [cioc_cic_search_role]
GO
